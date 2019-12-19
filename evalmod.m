% generate qc stats and plots
function [Ind_pre,Ind_post,trainThresh] = evalmod(mparams,block,stim,cho,rew)
% Parameters
theta = mparams(2);
p = mparams(4); 
s = mparams(5); 
g= mparams(6);

% Learn
[~, ~, ~, w, a] = mod1(block,stim,cho,rew,mparams);

% Calculate value some diagnostics
for i=1:15 
    preW(i,1) = s*(i-p); 
    preW(i,2) = s*(p-i); 
end

preChoP=zeros(15,2);
postChoP=zeros(15,2); 
for i=1:15
    output = a(i,:) * preW; 
    preChoP(i,1)=(1-2*g)*(exp(theta*output(1))/sum(exp(theta*output)))+g; 
    preChoP(i,2)=(1-2*g)*(exp(theta*output(2))/sum(exp(theta*output)))+g;
    
    output = a(i,:) * w; 
    postChoP(i,1)=(1-2*g)*(exp(theta*output(1))/sum(exp(theta*output)))+g; 
    postChoP(i,2)=(1-2*g)*(exp(theta*output(2))/sum(exp(theta*output)))+g;
end

% Linear estimate pre- and post-training indifference points
% Use default linear interpolation
%   spline fits resulted in bizarre estimates
try
    [x,index] = unique(preChoP(:,1));
    Ind_pre = interp1(x,index,0.5);
catch ME
    disp(ME.message);
    Ind_pre = NaN;
end

try
    [x,index] = unique(postChoP(:,1));
    Ind_post = interp1(x,index,0.5);
catch ME
    disp(ME.message);
    Ind_post = NaN;
end

% Calculate training threshold
% Determine category by choice and reward as feedback is deterministic
cat = cho; 
cat(block > 0 & rew==0 & cho==1) = 0; 
cat(block > 0 & rew==0 & cho==0) = 1; 
trainThresh = max(unique(stim(block > 0 & cat==0))); 
% Stimuli <= trainThresh should be cat 0.

end