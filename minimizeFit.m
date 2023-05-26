%% Version 1.4

% Dependencies:
%   Requires Optimization toolbox for fmincon function.
%   Requires Matlab R2019b or more recent.

% History:
% 1.1       Initial attempt with base code and SOS fitting.
% 1.2rm     Addition of random starts as well as maximum likelihood fit.
%           Bayesean test with beta distribution (failed but left in)
% 1.3       Removal of normalization because normalization emphasizes
%           extreme morphs.
%           Normalization commented out in two places. Noted with 'normalize'.
%           Bound s, epsilon, and sigma starting values avoiding false starts.
%           Add weight, choiceprob, and output graphs by trial for QC. 
%           Refactoring code for maintenance.
% 1.4       Estimation of learning rate is now adjusted by sigma, 
%               yielding the maximimum effective learning rate. 
%           Option: Evaluate estimation of initial weights as a logistic or linear.
%           Option: Select no, one, or two initial response bias parameters. 

%% Input
% Task data for a single session, h
% h = session/person identifier, an integer
% plots = 'on' or 'off' for graphical qcPlots or waitbar
% block = training block (0=pretraining, 2:6 training)
% stim = face label, 1-15 (happy to angry)
% cho = answered happy(0) or angry(1)
% rew = actual feedback (0=negative / 1=positive)

%% Output:
% Fit parameters
%   sigma, generalization, bound 0 to 15
%   theta, inverse temperature, bound 0 to 10
%   effEpsMax, maximum effective learning rate, bound 0 to 1
%   p, initial indifference point, bound 0 to 15
%   s, initial weight slope,  0 to 10, s
%       Note s is comletely unidentifiable with theta on nonlearning trials
%       but diverges on learning trials.
%       The maximum of s is 10, otherwise there is no room to maximize the
%       objective function.
%   gH, prestimulus response bias for happy
%   gA, prestimulus response bias for angry
% Fit statistic calculated by fitStat
%   Currently negative max log likelihood is calculated by fitStat
% QC values of convenience returned by evalMod
%   Ind_pre, model estimate of pretraining indifference point p(A)=.5
%   Ind_post, model estimate of postrainign indifference point p(A)=.5
%   trainThresh = category boundary for happy/angry judgmements
%   epsilon = conversion of effEpsMax to conventional learning rate

%% fitibt
function [mparams,fit,numFit,Ind_pre,Ind_post,trainThresh,epsilon] = ...
    minimizeFit(obs,plots,block,stim,cho,rew)

niter = 500;
allparams = nan(niter,8); % 7 parameters, 1 fit

if strcmp(plots,'on')
    wb=waitbar(0,'Starting random starts.');
end

% init fmincon
A=[]; b=[]; Aeq=[]; beq=[]; nonlcon=[]; % no nonlinear constraints
% limits of parameters- lower bound (lb) and upper bound (ub)
lb=[0,0,0,0,0,0,0]; %sigma, theta, effEpsMax, p, s, gA, gH
up=[15,10,1,15,1,0.5,0.5];

% niter randomly started fits
for ni = 1:niter
    % Reasonable starts, see file "bounds of s" to prevent
    % aberrant model behavior due to extreme initialized weights.
    p_0=rand*10+3;
    if p_0 >= 7.5 && p_0 <= 8.5
        s_0 = rand; % the limit of s_0 is 1
    else
        % the start limit of s_0 depends on how far p_0 is from the center
        s_0 = rand*(1/(abs(abs(sum((1:15)-p_0))-max(15-(p_0-1),p_0))));
    end
    params_0 = [rand*3,...      % sigma
        rand*10,...             % theta
        rand*0.5,...            % effEpsMax
        p_0,...                 % p
        s_0,...                 % s
        rand*0.25,...           % gA
        rand*0.25];             % gH
    try
        options = optimoptions('fmincon','Display','notify-detailed');
        [iparams,ifit] = fmincon(@(params)fitStat(block,stim,cho,rew,params),...
            params_0, A, b, Aeq, beq, lb, up, nonlcon, options);
    catch ME
        % disp(ME.message); % for debugging
        % disp(params_0);
        continue; % jump to the next iteration of i
    end
    allparams(ni,:) = [iparams, ifit];
    if strcmp(plots,'on')
        waitbar(ni/niter,wb,'Cycling through random starts.')
    end
end
if strcmp(plots,'on'), close(wb), end

% Output best fit parameters
allparams = allparams(any(allparams,2),:); % remove rows with NaN or 0s
allparams = sortrows(allparams,8); % sort ascending by fit
mparams = allparams(1,1:7);
fit = allparams(1,8);
[~,ia,~]=unique(round(allparams(:,8),1),'stable');
numFit = ia(2)-ia(1);

% Diagnostics
[Ind_pre,Ind_post,trainThresh,epsilon]=...
    evalMod(mparams,block,stim,cho,rew);
if strcmp(plots,'on')
    figH(1) = figure(1); clf,plot(sort(allparams(:,8),'descend'));
    title('Neg ML over all Iterations');
    xlabel('Iteration');
    figH = qcPlots(figH,mparams,block,stim,cho,rew);
    % % Save figures to a folder
    warning('off','MATLAB:MKDIR:DirectoryExists');
    mkdir(sprintf('%s','Plots/'));
    fname=sprintf('%s%i%s','Plots/',obs,'_FitPlots');
    savefig(figH,fname,'compact');
end

end