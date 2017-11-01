%[signal] = MusicFromFeatures(feats,fs)
%or
%[signal] = MusicFromFeatures(feats,fs,winlength)
%or
%[signal] = MusicFromFeatures(feats,fs,winlength,noiseopt)
%
%Method to synthesize a signal from melody recognition features
%
%Usage:
%This function can generate signals from melody recognition features data like
%those given by GetMusicFeatures. Because GetMusicFeatures discards a lot of
%information, the signal cannot be recovered exactly. Instead it is assumed
%that the signal is a sinewave of varying frequency and intensity, possibly with
%some added white noise.
%
%Input:
%feats=     Matrix containing melody features. Each column corresponds to a
%           frame. If there are three rows, the first row is pitch (in Hz), the
%           second row is the correlation coefficient between pitch periods,
%           while the third gives per-sample intensity. If there are two rows,
%           these should be frequency and intensity; rho is assumed to be one.
%fs=        Sampling frequency of synthesized signal in Hz.
%winlength= Length of the analysis window in seconds (default 0.03).
%           This should be the same as used for GetMusicFeatures previously.
%noiseopt=  How to handle noise. Can be either positive, negative, or zero. If
%           negative, we assume no noise, and that all energy is due to the
%           sinusoidal component (equivalent to rho = 1). Otherwise, any
%           occurrences of rho < 1 is assumed to be due to white noise of
%           varying amplitude decreasing the correlation between samples, and
%           energy is allocated to the white noise component as well. However,
%           noise is only included in the output signal if noisopt is greater
%           than zero. The default is positive, meaning that noise is included.
%
%Output:
%signal=    Resynthesized melody waveform based on a sine + noise model.
%
%Gustav Eje Henter 2011-10-25 tested
%Gustav Eje Henter 2012-10-09 tested

function [signal] = MusicFromFeatures(feats,fs,winlength,noiseopt)

[nF T] = size(feats);

if (nF == 2),
    rhos = ones(1,T); % Assume no noise
elseif (nF == 3),
    rhos = feats(2,:);
else
    error('Illegal number of features per time frame!');
end
f = feats(1,:);
Is = feats(end,:);

if (nargin < 2) || isempty(fs),
    fs = 44100; % Default sampling freqeuncy
end

if (nargin < 3)  || isempty(winlength),
    winlength = 0.030; % Default 30 ms
else
    winlength = abs(winlength(1)); % Make winlength a real scalar
end

if (nargin < 4)  || isempty(noiseopt),
    noiseopt = true;
elseif (noiseopt < 0),
    noiseopt = false;
    rhos = ones(1,T); % Assume no noise
else
    noiseopt = (noiseopt > 0);
end

% Sanitize features
f = max(f,0);
Is = max(Is,0);
rhos = min(max(rhos,0),1); % Negative rhos do not make sense under our model

% Compute signal component amplitudes from features, according options
sineamp = Is.*sqrt(2*rhos);
if noiseopt,
    noiseamp = Is.*sqrt(1 - rhos); % Give noise appropriate, nonzero amplitude
else
    noiseamp = zeros(size(sineamp));
end

% Compute frame and sample times in seconds
tframe = (1:T)*(winlength/2);
ts = (0:1:ceil((T+1)*(winlength/2)*fs))/fs;

uselog = true; % Upsample amplitudes on logarithmic scale

% Upsample signal parameters from frame-by-frame to sample-by-sample
f = upsampler(tframe,f,ts,true); % Upsample frequency in logarithmic domain
sineamp = upsampler(tframe,sineamp,ts,uselog);
noiseamp = upsampler(tframe,noiseamp,ts,uselog);

phis = 2*pi*cumsum(f)/fs; % Convert frequency to instantaneous phase

signal = sineamp.*sin(phis) + noiseamp.*randn(size(ts)); % Synthesize output

function yup = upsampler(tdwn,ydwn,tup,uselog)

% Interpolation method
%method = 'linear';
method = 'spline';

if (numel(unique(ydwn)) == 1),
    yup = ydwn(1)*ones(size(tup));
elseif uselog,
    okpts = isfinite(log(ydwn)); % Remove infinite points
    yup = exp(interp1(tdwn(okpts),log(ydwn(okpts)),tup,method,'extrap'));
else
    yup = max(interp1(tdwn,ydwn,tup,method,'extrap'),0); % Min value is 0
end