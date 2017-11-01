%[frIsequence] = GetMusicFeatures(signal,fs)
%or
%[frIsequence] = GetMusicFeatures(signal,fs,winlength)
%
%Method to calculate features for melody recognition
%
%Usage:
%First load a sound file using wavread or similar, then use this function
%to extract pitch and energy contours of the melody in the sound. This
%information can be used to compute a sequence of feature values or
%vectors for melody recognition. Note that the pitch estimation is
%unreliable (typically giving very high values) in silent segments, and
%may not work at all for polyphonic sounds.
%
%Input:
%signal=      Vector containing sampled signal values (must be mono).
%fs=          Sampling frequency of signal in Hz.
%winlength=   Length of the analysis window in seconds (default 0.03).
%             Square ("boxcar") analysis windows with 50% overlap are used.
%
%Output:
%frIsequence= Matrix containing pitch, correlation, and intensity estimates
%             for use in creating features for melody recognition. Each column
%             represents one frame in the analysis. Elements in the first
%             row are pitch estimates in Hz (80--1100 Hz), the second row
%             estimates the correlation coefficient (rho) between adjacent
%             pitch periods, while the third row contains corresponding
%             estimates of per-sample intensity.
%
%References:
%This method is based on a pitch estimator provided by Obada Alhaj Moussa.
%
%Gustav Eje Henter 2010-09-15 tested
%Gustav Eje Henter 2011-10-25 tested

function [frIsequence] = GetMusicFeatures(signal,fs,winlength)

% Wikipedia: "human voices are roughly in the range of 80 Hz to 1100 Hz"
minpitch = 80;
maxpitch = 1100;

signal = real(double(signal)); % Make sure the signal is a real double

sigsize = size(signal);
if (min(sigsize) > 2) || (length(sigsize) > 2),
    error('Multichannel signals are not supported. Use only mono sounds!');
end

if (sigsize(1) == 2),
    signal = (signal(1,:)' + signal(2,:)')/2;
elseif (sigsize(2) == 2),
    signal = (signal(:,1) + signal(:,2))/2;
end
signal = signal - mean(signal); % Remove DC, which can disturb intesities

if fs <= 0
    fs = 44100; % Replace illegal fs-values with a standard sampling freq.
end

% Compute the pitch periods in samples for the human voice range
minlag = round(fs/maxpitch);
maxlag = round(fs/minpitch);

if (nargin > 2) && ~isempty(winlength),
    winlength = abs(winlength(1)); % Make winlength a real scalar
else
    winlength = 0.030; % Default 30 ms
end

winlength = round(winlength*fs); % Convert to number of samples
winlength = max(winlength+mod(winlength,2),...
    2*minlag); % Make windows sufficiently long and an even sample number

winstep = winlength/2;
nsteps = floor(length(signal)/winstep) - 1;
if (nsteps < 1)
    error(['Signal too short. Use at least ' int2str(winlength)...
        ' samples!']);
end

frIsequence = zeros(3,nsteps); % Initialize output variable to correct size

for n = 0:(nsteps-1),
    
    % Cut out a segment of the signal starting at offset n*winlength sec
    window = signal(n*winstep+(1:winlength));
    
    % Estimate the pitch (sampling frequency/pitch period), between-period
    % correlation coefficient, and intensity
    [pprd,maxcorr] = yin_pitch(window,minlag,maxlag);
    frIsequence(:,n+1) = [fs/pprd;maxcorr;norm(window/sqrt(numel(window)))];
    
end

% Below is the pitch period estimation sub-routine.
% The estimate is based on the autocorrelation function.
function [pprd,maxcorr] = yin_pitch(signal,minlag,maxlag)

N = length(signal);
%minlag = 40;
%maxlag = 200;
dif = zeros(maxlag - minlag + 1, 1);
for idx = minlag : maxlag
    seg1 = signal(idx + 1 : N);
    seg2 = signal(1 : N - idx);
    
    % Estimate correlation ("dif") at lag idx
    dif(idx - minlag + 1) = sum((seg1 - seg2).^2) / (N - idx);
end
thresh = (max(dif) - min(dif)) * 0.1 + min(dif);

% Locate the first minimum of dif, which is the first maximum of the
% correlation; the corresponding lag is the pitch period.

idx = minlag;
while idx <= maxlag
    if dif(idx - minlag + 1) <= thresh
        pprd = idx;
        break;
    end
    idx = idx + 1;
end

% Allow the procedure to find the first minimum to roll over small "bumps"
% in the autocorrelation functions, that are below than a 10% threshold.
while idx <= maxlag
    if dif(idx - minlag + 1) >= thresh
        break;
    end
    if dif(idx - minlag + 1) < dif(pprd - minlag + 1)
        pprd = idx;
    end
    idx = idx + 1;
end

%difmin = dif(pprd - minlag + 1);
seg1 = signal(pprd + 1 : N);
seg2 = signal(1 : N - pprd);
maxcorr = corr(reshape(seg1,numel(seg1),1),reshape(seg2,numel(seg1),1));