% generate qc stats and plots
function [Ind_pre,Ind_post,trainThresh,epsilon]...
    = evalMod(mparams,block,stim,cho,rew)
% Parameters
sigma = mparams(1);
theta = mparams(2);
effEpsMax = mparams(3);
p = mparams(4); 
s = mparams(5);
gA = mparams(6);
gH = mparams(7);

% Learn
[~, ~, ~, w, a] = mod1_4(block,stim,cho,rew,mparams);

% Calculate value some diagnostics
for i=1:15 
    %preW(i,1) = 2/(1+exp(s*(p-i)))-1; %angry (first column)
    %preW(i,2) = 2/(1+exp(s*(i-p)))-1; %happy (second column)
    preW(i,1) = s*(i-p); %angry (first column)
    preW(i,2) = s*(p-i); %happy (second column)
end

preChoP=zeros(15,2);
postChoP=zeros(15,2); 
for i=1:15
    output = a(i,:) * preW; 
    preChoP(i,1)=(1-gA-gH)*(exp(theta*output(1))/sum(exp(theta*output)))+gH; 
    preChoP(i,2)=(1-gA-gH)*(exp(theta*output(2))/sum(exp(theta*output)))+gH;
    
    output = a(i,:) * w; 
    postChoP(i,1)=(1-gA-gH)*(exp(theta*output(1))/sum(exp(theta*output)))+gH; 
    postChoP(i,2)=(1-gA-gH)*(exp(theta*output(2))/sum(exp(theta*output)))+gH;
end

% Linear estimate pre- and post-training indifference points
% Use default linear interpolation
%   spline fits resulted in bizarre estimates
try
    [x,index] = unique(preChoP(:,1));
    Ind_pre = interp1(x,index,0.5);
catch ME
    % disp(ME.message);
    Ind_pre = NaN;
end

try
    [x,index] = unique(postChoP(:,1));
    Ind_post = interp1(x,index,0.5);
catch ME
    % disp(ME.message);
    Ind_post = NaN;
end

% Calculate training threshold
% Determine category by choice and reward as feedback is deterministic
cat = cho; 
cat(block > 0 & rew==0 & cho==1) = 0; 
cat(block > 0 & rew==0 & cho==0) = 1; 
trainThresh = max(unique(stim(block > 0 & cat==0))); 
% Stimuli <= trainThresh should be cat 0.
% The true training threshold is trainThresh - 0.5 on the stimulus scale.
% For example, where 9+ are angry, this will return 8, but the training
% threshold is 8.5 because 9+ are angry and 8- are happy.

% Calculate epsilon
epsilon = effEpsMax/sum(exp(-(8-(1:15)).^2/(sigma^2)));
end