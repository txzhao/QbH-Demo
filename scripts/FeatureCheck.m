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

% convert numbers of window into time
t1 = 0 : winlen : (size(frIseq1, 2) - 1)*winlen;
t2 = 0 : winlen : (size(frIseq2, 2) - 1)*winlen;
t3 = 0 : winlen : (size(frIseq3, 2) - 1)*winlen;

% pitch profile
figure;
ax1 = subplot(3, 1, 1);
plot(t1, frIseq1(1, :));
title('Pitch profile of melody 1');
xlabel('time (s)'); ylabel('Pitch (Hz)');
ax2 = subplot(3, 1, 2);
plot(t2, frIseq2(1, :));
title('Pitch profile of melody 2');
xlabel('time (s)'); ylabel('Pitch (Hz)');
ax3 = subplot(3, 1, 3);
plot(t3, frIseq3(1, :));
title('Pitch profile of melody 3');
xlabel('time (s)'); ylabel('Pitch (Hz)');
set([ax1 ax2 ax3], 'YScale','log');
set([ax1 ax2 ax3], 'YLim', [100 300]);

% intensity profile
figure;
ax1 = subplot(3, 1, 1);
plot(t1, frIseq1(3, :));
title('Intensity profile of melody 1');
xlabel('time (s)'); ylabel('Intensity');
ax2 = subplot(3, 1, 2);
plot(t2, frIseq2(3, :));
title('Intensity profile of melody 2');
xlabel('time (s)'); ylabel('Intensity');
ax3 = subplot(3, 1, 3);
plot(t3, frIseq3(3, :));
title('Intensity profile of melody 3');
xlabel('time (s)'); ylabel('Intensity');
set([ax1 ax2 ax3], 'YScale','log');

