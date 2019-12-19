%% For version 1.3 - Simulated Data

% Input parameters (in order)
% sigma, generalization, 1 to 15, mparams(1)
% theta, inverse temperature, 0 to 10, mparams(2)
% epsilon, learning rate, 0 to 1, mparams(3)
% p, initial indifference point, 0 to 15 mparams(4)
% s, initial weight slope,  0 to 1 mparams(5)
% g, guessing parameter, 0 to 0.5 mparams(6)
% trainThresh, values <= the trainThresh are category 0 mparams(7)

% Output is a synthetic data frame with the following:
% block (:,1) = block 0 = pretraining, 1:6 training
% stim (:,2) = morph condition (1-15)
% cho (:,3) = answered happy(0) or angry(1)
% rew (:,4) = actual feedback (0=negative / 1=positive)

% Procedures
% Use with parameters to synthesize data
% Pretraining (block 0) and training trials (blocks 1 to 6)

%% simData
function [sData] = simData(mparams)
n = 225; % Task length

% Block 0 = 45 trials, blocks 1-6 = 30 trials.
% Stimuli in random order stimuli in the frequency as the original study,
% 3 each in block 1 and 12 each in blocks 1-6.
block = zeros(n,1);
stim = zeros(n,1);
A = [repmat(1:15,1,3)',rand(45,1)];
B = sortrows(A,2);
stim(1:45) = B(:,1);
for i=1:6 % iterate through blocks.
    A = [repmat(1:15,1,2)',rand(30,1)];
    B = sortrows(A,2);
    stim((46+((i-1)*30)):45+(i*30)) = B(:,1);
    block((46+((i-1)*30)):45+(i*30)) = repmat(i,30,1);
end
clear A B

% The model only really cares about the category of the trial stimulus.
% Because feedback is deterministic, the model takes raw choice and
% reward and converts it to category. It only uses category to determine
% feedback. Category is purely dependent on the category boundary, with
% stimuli > trainThresh having an angry response (1). So, if we set reward
% to be 1's then cho == category at the outset.
cho = zeros(n,1);
cho(stim > mparams(7)) = 1;
rew = ones(n,1);

% Generate choice probabilities according to the parameters
choiceprob = mod1(block,stim,cho,rew,mparams(1:6));

for t = 1:n
    % Randomize choice according to the probability of the choice using
    % randsample.
    cho(t) = randsample(0:1,1,'true',[1-choiceprob(t),choiceprob(t)]);
    % Revise reward
    % Is the choice correct based on the category boundary?
    % If the wrong choice for the category, then set reward to 0, incorrect,
    % otherwise, leave as 1, correct.
    if (cho(t) == 0 && stim(t) > mparams(7)) || ...
            (cho(t) == 1 && stim(t) <= mparams(7))
        rew(t) = 0;
    end
end

% Output dataset
sData = [block,stim,cho,rew];
