% semitone = PostProcess(frIseq, verbose)
%
% method to post-process features obtained from "GetMusicFeatures.m"
%
% Input:    frIseq      - feature matrix (3*T) from "GetMusicFeatures.m"
%           verbose     - plot flag (boolean)
%
% Output:   semitone    - post-processed feature vector (1*T)
%
% Usage: 
% This function works for post-processing features extracted from
% "GetMusicFeatures.m". Specifically, pitch information is first filtered
% based on correlation coefficient (r) and intensity (I), and then
% converted into semitones using the relation - semitone =
% 12*log2(p/base_p) + 1. The newly-derived feature semitone is continuous,
% and ranges between (0, 13). Silent and noisy regions are filled with
% random values around 0 to 0.5.

function semitone = PostProcess(frIseq, verbose)

% post-process features
p = log(frIseq(1, :));
r = frIseq(2, :);
I = log(frIseq(3, :));

% p = p - min(p);
% p = p/max(p);
% I = I - min(I);
% I = I/max(I);

% detect noisy and silent region
p_thresh_pos = mean(p) + std(p);
p_thresh_neg = mean(p) - std(p);
r_thresh = mean(r);
I_thresh = mean(I);
noise = (p < p_thresh_neg) | (p > p_thresh_pos) | ((I < I_thresh) & (r < r_thresh));

% convert pitch information into semitone (continuous)
base_p = min(p(find(noise == 0)));
semitone = 12*log2(p/base_p) + 1;

% return random values around 0 for noise and pause
semitone(find(noise == 1)) = 0.5*rand(size(find(noise == 1)));


% % partial results output
% % print out threshold selection
% disp('---------- thresholds information ----------');
% disp(['upper pitch threshold: ' num2str(p_thresh_pos)]);
% disp(['lower pitch threshold: ' num2str(p_thresh_neg)]);
% disp(['correlation threshold: ' num2str(r_thresh)]);
% disp(['intensity threshold: ' num2str(I_thresh)]);
% fprintf('\r');

% output plots and thresholds
if verbose == true
    figure;
    subplot(3,1,1)
    plot(p);
    hold on;
    pline_pos = refline(0, p_thresh_pos);
    pline_neg = refline(0, p_thresh_neg);
    pline_pos.Color = 'r'; pline_pos.LineStyle = '--';
    pline_neg.Color = 'k'; pline_neg.LineStyle = '--';
    hold off; grid on;
    title('Information on pitch track');
    xlabel('Number of windows'); ylabel('Logarithmic pitch');
    subplot(3,1,2)
    plot(r)
    hold on; 
    rline = refline(0, r_thresh);
    rline.Color = 'r'; rline.LineStyle = '--';
    hold off; grid on;
    title('Information on correlation-coefficient track');
    xlabel('number of windows'); ylabel('Correlation coefficient');
    subplot(3,1,3)
    plot(I)
    hold on;
    Iline = refline(0, I_thresh);
    Iline.Color = 'r'; Iline.LineStyle = '--';
    hold off; grid on;
    title('Information on intensity track');
    xlabel('number of windows'); ylabel('Logarithmic intensity');
end
