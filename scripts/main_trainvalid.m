clear;
addpath(genpath('../db'));
addpath(genpath('GetMusicFeatures'));

%% read in data
NUM_OF_SONG = 10;
NUM_OF_RECORD = 15;
winlen = 0.03;
Y = {}; stSeq = {};

songs = dir('../db');
for song = songs'
    if strfind(song.name, '#')
        Ys = {}; Seqs = {};
        records = dir(['../db/' song.name '/*.wav']);
        shuffle_id = randperm(numel(records), NUM_OF_RECORD);
        for record = records(shuffle_id)'
            path = ['../db/' song.name '/' strrep(record.name,'.wav','.mat')];
            if ~exist(path)
                wav2mat(strrep(path, '.mat', '.wav'), winlen);
            end
            load(path);
            Ys = [Ys y]; Seqs = [Seqs st];
        end
        Y = [Y; Ys]; stSeq = [stSeq; Seqs];
    end
end

disp('data read-in ok!');

%% initialize HMM and training
k = 5; partion_id = 1;
[tr_data, va_data, tr_len, va_len] = k_fold(stSeq, k, partion_id);

nStates = 10;
nGaussians = 8;
for i = 1 : NUM_OF_SONG
    gmms(i) = MakeGMM(nGaussians, tr_data{i, :});
    hmms(i) = MakeLeftRightHMM(nStates, gmms(i), tr_data{i, :}, tr_len(i, :));
end
save('trained_hmm/hmms.mat', 'hmms');
disp('HMM training ok!');

%% validation
va_acc = zeros(1, NUM_OF_SONG);
confuse_mat = zeros(NUM_OF_SONG);
targets = zeros(NUM_OF_SONG, size(va_len, 1)*size(va_len, 2)); 
outputs = zeros(NUM_OF_SONG, size(va_len, 1)*size(va_len, 2));

for i = 1 : NUM_OF_SONG
    acc_tmp = 0;
    for j = 1 : size(va_len, 2)
        lP = logprob(hmms, va_data{i, j});
        [~, idx] = max(lP);
        confuse_mat(idx, i) = confuse_mat(idx, i) + 1;
        acc_tmp = acc_tmp + (idx == i);
        targets(i, (i - 1)*size(va_len, 2) + j) = 1;
        outputs(idx, (i - 1)*size(va_len, 2) + j) = 1;
    end
    va_acc(i) = acc_tmp/size(va_len, 2);
end

disp('HMM validation ok!');

%% results output
plotconfusion(targets, outputs)

disp('results output ok!');