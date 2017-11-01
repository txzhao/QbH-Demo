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

%% initialize HMM and training and k-fold cross-validation
k = 5;
nStates = 10; 
nGaussians = 8;
va_acc = zeros(1, NUM_OF_SONG);
va_acc_all = zeros(1, NUM_OF_SONG);
confuse_mat = zeros(NUM_OF_SONG);
targets = zeros(NUM_OF_SONG, size(stSeq, 1)*size(stSeq, 2)); 
outputs = zeros(NUM_OF_SONG, size(stSeq, 1)*size(stSeq, 2));

for n = 1 : k
    [tr_data, va_data, tr_len, va_len] = k_fold(stSeq, k, n);
    
    for i = 1 : NUM_OF_SONG
        gmms(i) = MakeGMM(nGaussians, tr_data{i, :});
        hmms(i) = MakeLeftRightHMM(nStates, gmms(i), tr_data{i, :}, tr_len(i, :));

        acc_tmp = 0;
        for j = 1 : size(va_len, 2)
            lP = logprob(hmms, va_data{i, j});
            [~, idx] = max(lP);
            confuse_mat(idx, i) = confuse_mat(idx, i) + 1;
            acc_tmp = acc_tmp + (idx == i);
            targets(i, (n - 1)*size(va_len, 1)*size(va_len, 2) + (i - 1)*size(va_len, 2) + j) = 1;
            outputs(idx, (n - 1)*size(va_len, 1)*size(va_len, 2) + (i - 1)*size(va_len, 2) + j) = 1;
        end
        va_acc(i) = va_acc(i) + acc_tmp/size(va_len, 2);
    end
    va_acc_all = va_acc_all + va_acc;
    save(['trained_hmm/hmms_' num2str(n) '.mat'], 'hmms');
end

va_acc_all = va_acc_all/k;

disp('HMM validation ok!');

%% results output
plotconfusion(targets, outputs)

disp('results output ok!');