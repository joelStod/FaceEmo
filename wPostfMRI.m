% Data are in ImportData.txt with columns:
% Obs, SubjID, Session, Condition, Block, Trial, Face, Choice,
% Feedback, Training Threshold, BalancePoint

% Obs numbers are integers unique to the training session

X=dlmread('NIMH_PostfMRI_04.02.19_Block0-6.txt','\t',1,0); % omit header row

for h = 1:max(unique(X(:,1)))
    if ~ismember(h,X(:,1)) % Allow nonsequential or missing integers in Obs
        continue
    end
    
    k = X(:,1)==h;
    disp('Observation Number');
    disp(h);
    time1 = datetime;
    
    % Pass the face morph task data
    %       block (k,5) = block 0 = pretraining, 1:6 training
    %       face (k,7) = morph condition (1-15)
    %       choice (k,8) = answered happy(0) or angry(1)
    %       feedback (k,9) = actual feedback (0=negative / 1=positive)
    [mparams,fit,Ind_pre,Ind_post,trainThresh] = ...
        fitibt(h,'on',X(k,5),X(k,7),X(k,8),X(k,9));
    demograph=X(k,1:4);
    % demograph = Obs, SubjID, Session, Group
    % mparams = sigma, theta, epsilon angry, p, s, g
    % fit is the fit statistic from fitmod
    % Ind_pre is the interpolated difference point based on starting values
    % Ind_post is the interpolated difference point based on final values
    % trainThresh is the category boundary
  
    % duration in seconds
    time2 = datetime;
    dur = seconds(time2-time1);
    
    % Write demograph, mparams, duration (s)
    mpheight(h,:)=[demograph(1,:),mparams,fit,Ind_pre,Ind_post,trainThresh,dur];
    clear mparams; clear out; clear fit; clear demograph;
end

%Write entries with Obs ~= 0
dlmwrite('LearnParamsPostfMRI.txt',mpheight(mpheight(:,1)~=0,:));