clear;
addpath(genpath('GetMusicFeatures'));
addpath(genpath('Songs'));

[Y1, FS1] = audioread('melody_1.wav');
[Y2, FS2] = audioread('melody_2.wav');
[Y3, FS3] = audioread('melody_3.wav');

winlen = 0.03;
frIseq1 = GetMusicFeatures(Y1, FS1, winlen);
frIseq2 = GetMusicFeatures(Y2, FS2, winlen);
frIseq3 = GetMusicFeatures(Y3, FS3, winlen);

% rescale pitch track by a factor
factor = [1.5; 1; 1];
st1 = PostProcess(frIseq1.*repmat(factor, 1, size(frIseq1, 2)), false);
st2 = PostProcess(frIseq2.*repmat(factor, 1, size(frIseq2, 2)), false);
st3 = PostProcess(frIseq3.*repmat(factor, 1, size(frIseq3, 2)), false);

% convert numbers of window into time
t1 = 0 : winlen : (size(frIseq1, 2) - 1)*winlen;
t2 = 0 : winlen : (size(frIseq2, 2) - 1)*winlen;
t3 = 0 : winlen : (size(frIseq3, 2) - 1)*winlen;

% pitch profile
figure;
ax1 = subplot(3, 1, 1);
plot(t1, st1); grid on;
title('Feature series from melody 1');
xlabel('time (s)'); ylabel('feature');
ax2 = subplot(3, 1, 2);
plot(t2, st2); grid on;
title('Feature series from melody 2');
xlabel('time (s)'); ylabel('feature');
ax3 = subplot(3, 1, 3);
plot(t3, st3); grid on;
title('Feature series from melody 3');
xlabel('time (s)'); ylabel('feature');
set([ax1 ax2 ax3], 'YLim', [0 4]);

% similarity
Dist12 = dtw(st1, st2);
Dist13 = dtw(st1, st3);
Dist23 = dtw(st2, st3);
disp('------------ sequence similarity ------------');
disp(['Distance between feature seq 1 and 2: ' num2str(Dist12)]);
disp(['Distance between feature seq 1 and 3: ' num2str(Dist13)]);
disp(['Distance between feature seq 2 and 3: ' num2str(Dist23)]);
fprintf('\r');