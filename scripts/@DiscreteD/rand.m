function R = rand(pD, nData)
%R=rand(pD,nData) returns random scalars drawn from given Discrete Distribution.
%
%Input:
%pD=    DiscreteD object
%nData= scalar defining number of wanted random data elements
%
%Result:
%R= row vector with integer random data drawn from the DiscreteD object pD
%   (size(R)= [1, nData]
%
%----------------------------------------------------
%Code Authors: Tianxiao Zhao
%----------------------------------------------------

if numel(pD) > 1
    error('Method works only for a single DiscreteD object');
end;

% generate cumulative probability and draw scalars from it
R = zeros(1, nData);
rands = rand(1, nData);
cum_prob = cumsum(pD.ProbMass);
for i = 1 : nData
    R(i) = find(rands(i) < cum_prob, 1);
end
    
    

