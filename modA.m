% For version 1.3
% Core learning model, 1, with assymmetric learning as a demonstration.

% Because mod1 was originally written with assymmetric learning, simply
% assigning epsilon as an array instead of a scalar (line 35) will work 
% to generate two learning rates (line 81).

% This will readily fit IBT, but that is not the ideal task design as 
% A and H responses are collinear.

% Learn by gradient decent on delta^2 for
% difference between output and weight matrix. Allowing generalization
% between stimuli.

% Inputs
% Task data
% block = training block (0=pretraining, 2:6 training)
% stim = face label, 1-15 (happy to angry)
% cho = answered happy(0) or angry(1)
% rew = actual feedback (0=negative / 1=positive)
% params array, see fitibt.m for full description.

% Outputs
% choiceprob - the trialwise choice probability of an angry choice
% trlwt - the trialwise weight at the trial stimulus
% trlout - the trialwise output at the trial stimulus
% w - final weight matrix
% a = final activation matrix

%% modA
function [choiceprob, trlwt, trlout, w, a] = modA(block,stim,cho,rew,params)
% Parameters
sigma = params(1); %standard deviation of generalization gradient
theta = params(2); %inverse temperature for softmax
epsilon = params(3:4); %learning rate for output nodes
p = params(5); %initialization balance point
s = params(6); %initialization steepness
g = params(7); %initialization guessing probability

% Prep task data for model. Deterministic feedback.
cat = cho; %n vector of correct categories (happy=0, angry=1)
%in training blocks, switch wrong angry answer to happy
cat(block>0 & rew==0 & cho==1) = 0;
%in training blocks, switch wrong happy to angry
cat(block>0 & rew==0 & cho==0) = 1;
n = length(stim);% number of trials

% Initialize activation matrix
a = zeros(15,15); %possible stimuli x input nodes
for i=1:15 %loop through stimuli
    a(i,:) = exp(-(i-(1:15)).^2/(2*sigma^2)); %Gaussian centered on i
    %a(i,:) = a(i,:)/sum(a(i,:)); % Alternative: normalize
end

%Create initial weight matrix
w=zeros(15,2); %possible nodes
for i=1:15 %loop through stimuli
    w(i,1) = s*(i-p); %angry (first column)
    w(i,2) = s*(p-i); %happy (second column)
end

%Simulate learning
choiceprob = zeros(n,1); %initialize vector of model choice probabilities
trlwt = zeros(n,2); %initialize matrix of trialwise weights
trlout = zeros(n,2); %initialize matrix of trialwise values
for t=1:n %loop through trials
    output = a(stim(t),:) * w; %input activation times weight matrix (2x1)
    trlout(t,:) = output;
    % Choice probability is going to be softmax with guessing param g
    choiceprob(t) = (1-2*g)*(exp(theta*output(1))/sum(exp(theta*output)))+g;
    %learn only on training blocks
    if block(t)>0
        if cat(t)==1 %target answer is angry
            feedback = [1 -1]; %positive for angry, negative for happy
        else %target answer is happy
            feedback = [-1 1]; %negative for angry, positive for angry
        end
        delta = feedback-output; %prediction error (2x1)
        % go trial by trial and monitor weight change- another bug?
        % Answer the question- how does the weight difference get positive.
        w = w + a(stim(t),:)'*(epsilon.*delta); %update weights
    end
    % Record trialwise weights w_{i_angry} and w_{i_happy} for stimulus(t)
    trlwt(t,:) = w(stim(t),:);
end

end

