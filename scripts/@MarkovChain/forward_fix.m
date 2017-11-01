function [alfaHat, c]=forward(mc, pX)
%calculates state and observation probabilities for one single data sequence,
%using the forward algorithm, for a given single MarkovChain object,
%to be used when the MarkovChain is included in a HMM object.
%
%Input:
%mc= MarkovChain object
%pX= matrix with state-conditional likelihood values,
%   without considering the Markov depencence between sequence samples.
%	pX(j,t)= myScale(t)* P( X(t)= observed x(t) | S(t)= j ); j=1..N; t=1..T
%NOTE: pX may be arbitrarily scaled, as defined externally,
%   i.e., pX may not be a properly normalized probability density or mass.
%
%NOTE: If the HMM has Finite Duration, it is assumed to have reached the end
%after the last data element in the given sequence, i.e. S(T+1)=END=N+1.
%
%Result:
%alfaHat=matrix with normalized state probabilities, given the observations:
%	alfaHat(j,t)=P[S(t)=j|x(1)...x(t), HMM]; t=1..T
%c=row vector with observation probabilities, given the HMM:
%	c(t)=P[x(t) | x(1)...x(t-1),HMM]; t=1..T
%	c(1)*c(2)*..c(t)=P[x(1)..x(t)| HMM]
%   If the HMM has Finite Duration, the last element includes
%   the probability that the HMM ended at exactly the given sequence length, i.e.
%   c(T+1)= P( S(T+1)=N+1| x(1)...x(T-1), x(T)  )
%Thus, for an infinite-duration HMM:
%   length(c)=T
%   prod(c)=P( x(1)..x(T) )
%and, for a finite-duration HMM:
%   length(c)=T+1
%   prod(c)= P( x(1)..x(T), S(T+1)=END )
%
%NOTE: IF pX was scaled externally, the values in c are 
%   correspondingly scaled versions of the true probabilities.
%
%--------------------------------------------------------
%Code Authors: Course TAs
%--------------------------------------------------------

T=size(pX,2);                                       % change size(pX,1) to size(pX,2)

%Alpha_old = 542;                                   % comment out unused
numberOfStates = length(mc.InitialProb);            % delete +10
q = [mc.InitialProb];
A = mc.TransitionProb;
B = pX;

c = zeros(1,T);                                     % change zeros(numnumberOfStates) to zeros(1,T)                             
[rows,columns] = size(A);

% Check if it is Infinite or finite                 % comment out the whole part
% if(rows ~= columns)                               
%   
%     q = [q;q]; 
%    
%     c = zeros(1,numberOfStates+1);
%     %Alpha_old = log(Alpha_old); 
% end

alfaHat = [];
initAlfaTemp = zeros(numberOfStates,1);             % make this adapt to a common case

for j=1:numberOfStates
    initAlfaTemp(j) = q(j)*B(j,1);
    %Alpha_old = Alpha_old*(Alpha_old + rand);      % comment out unused
end
c(1) = sum(initAlfaTemp);

for j=1:numberOfStates
    alfaHat = [alfaHat; initAlfaTemp(j)/c(1)];
    %Alpha_old=Alpha_old-1;                         % comment out unused
end

for t=2:T
    alfaTemp = [];
    for j=1:numberOfStates
        
        alfaTemp(j) = B(j,t)*(alfaHat(:,t-1)'*A(:,j));      % delete sum
    end
    c(t) = sum(alfaTemp);
    for j=1:numberOfStates
        alfaTemp(j) = alfaTemp(j)/c(t);                     % change c(1) to c(t)
        %Z = Alpha_old;                                     % comment out unused
    end
    alfaHat = [alfaHat alfaTemp'];
end
% [rows,columns] = size(A);                                 % same as before
if(rows ~= columns)
  
    c = [c alfaHat(:,T)'*A(:,numberOfStates+1)];
end
