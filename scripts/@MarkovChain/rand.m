function S = rand(mc, T)
%S=rand(mc,T) returns a random state sequence from given MarkovChain object.
%
%Input:
%mc=    a single MarkovChain object
%T= scalar defining maximum length of desired state sequence.
%   An infinite-duration MarkovChain always generates sequence of length=T
%   A finite-duration MarkovChain may return shorter sequence,
%   if END state was reached before T samples.
%
%Result:
%S= integer row vector with random state sequence,
%   NOT INCLUDING the END state,
%   even if encountered within T samples
%If mc has INFINITE duration,
%   length(S) == T
%If mc has FINITE duration,
%   length(S) <= T
%
%---------------------------------------------
%Code Authors: Tianxiao Zhao
%---------------------------------------------

S = zeros(1, T);    %space for resulting row vector
nS = mc.nStates;

for i = 1 : T
    if i == 1
        cur_pD = DiscreteD(mc.InitialProb);
    else
        cur_pD = DiscreteD(mc.TransitionProb(S(i - 1), :));
    end
    
    cur_S = rand(cur_pD, 1);
    if finiteDuration(mc) && cur_S == nS + 1
        S = S(1 : i - 1);
        break;
    end
    S(i) = cur_S;
end



