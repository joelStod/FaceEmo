% generate fit statistic
function fit = fitmod(block,stim,cho,rew,params)

choiceprob = mod1(block,stim,cho,rew,params);

% ML Fit
% Sum model’s log probability for the subject’s choice in each trial
% Make negative to minimize for fmincon.
fit =   -sum(log(choiceprob(cho==1))) - sum(log(1-choiceprob(cho==0)));

% Alternative: a 0.1 beta distribution prior on epsilon
%   fit =   -sum(log((epsilon).^.1.*(1-epsilon).^.1))...

% Alternative: SOS fit
%   fit = sum((choiceprob-cho).^2);
end