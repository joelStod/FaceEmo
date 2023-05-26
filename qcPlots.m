%% Diagnostic plots, requires Matlab 2019b or greater for tiling.
function figH = qcPlots(figH,mparams,block,stim,cho,rew);
% Parameters
theta = mparams(2);
p = mparams(4); 
s = mparams(5);
gA = mparams(6);
gH = mparams(7);

% Learn
[choiceprob, trlwt, trlout, w, a] = mod1_4(block,stim,cho,rew,mparams);

% Calculate choice probabilties before and after training 
preW=zeros(15,2); %possible nodes
for i=1:15 
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


% Pre-post choice probabilities
figH(2)=figure(2);clf;
t=tiledlayout(2,1);
ax1 = nexttile;
plot(preChoP,'LineWidth',2);
title('Pretraining Tendency towards Angry or Happy Judgments');
legend('Angry','Happy','Location','east');
nexttile;
plot(postChoP,'LineWidth',2);
title('Posttraining Tendency towards Angry or Happy Judgments');
xlabel(t, 'Morph');
ylabel(t, 'Choice Probability');
xticklabels(ax1,{})
t.TileSpacing = 'compact';

% Pre-post training weight matrices
figH(3)=figure(3);clf;
t = tiledlayout(3,1);
ax1 = nexttile;
plot(preW) % pretraining
title('Initial Weight Matrix')
ylabel('Weight')
legend('Angry','Happy','Location','east')
ax2 = nexttile;
plot(w) % final
title('Final Weight Matrix')
ylabel('Weight')
nexttile;
plot(a')
title('Activation Profiles')
ylabel('Activation')
xlabel(t, 'Morph')
xticklabels(ax1,{})
xticklabels(ax2,{})
t.TileSpacing = 'compact';

% Trialwise choice probability, weight, and output.

% Prep plotting variables
% Get sorted
n=length(stim);
[~,Stim_i]=sort(stim);
cho_s = cho(Stim_i);    % _s for sorted b stimulus class
choiceprob_s = choiceprob(Stim_i);
trlwt_d = -diff(trlwt,[],2); % plot weight differences, angry - happy here
trlwt_d_s = trlwt_d(Stim_i);
% rescale choice for plotting with weights
cho_s_w = cho_s;
cho_s_w(cho_s==1) = max(trlwt_d_s);
cho_s_w(cho_s==0) = min(trlwt_d_s);
trlout_s = trlout(Stim_i,1); % symmetric so just the first (angry) column
% rescale choice for plotting with outputs
cho_s_o = cho_s;
cho_s_o(cho_s==1) = max(trlout_s);
cho_s_o(cho_s==0) = min(trlout_s);
choices = [cho_s; choiceprob_s];
weights = [cho_s_w; trlwt_d_s];  % rescale choice (0,1) for plotting
outputs = [cho_s_o; trlout_s];
grp=[repmat('c',n,1); repmat('p',n,1)];

figH(4)=figure(4);clf;
t=tiledlayout(3,1);
ax1=nexttile;
gscatter([1:n 1:n]',choices,grp,'rb','..',10,'off');
% scatter of stimuli x response probability
ylim([0 1]);
xlim([0 n]);
xticks(0:15:n);
xticklabels(0:1:15);
for i=0:15:n
    if ~ismember(i,[0 n])
        xline(i);
    end
end
title('Choice Probabilities Across the Task');
ylabel('Choice Probability');

ax2=nexttile;
gscatter([1:n 1:n]',weights,grp,'rb','..',10,'off');
xlim([0 n]);
xticks(0:15:n);
xticklabels(0:1:15);
for i=0:15:n
    if ~ismember(i,[0 n])
        xline(i);
    end
end
yline(0);
title('Weight Differences Across the Task');
ylabel('Angry-Happy Weight');

nexttile;
gscatter([1:n 1:n]',outputs,grp,'rb','..',10,'off');
xlim([0 n]);
xticks(0:15:n);
xticklabels(0:1:15);
for i=0:15:n
    if ~ismember(i,[0 n])
        xline(i);
    end
end
title('Angry Outputs Across the Task');
ylabel('Angry Output');
xlabel(t, 'Morph')
xticklabels(ax1,{})
xticklabels(ax2,{})
t.TileSpacing = 'compact';

end
