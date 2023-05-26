% Run after generating a set of learnings parameters to estimate their SE
% in fitibt V1.3.

% Data are from LearnParamsPostfMRI.txt with columns:
% Obs, SubjID, Session, Condition, sigma, theta, epsilon,p,s,g,LL,
% eIP_pre,eIP_post,trainThresh,duration

% Obs numbers are integers unique to the training session
% Initialize
iters = 1000;

X=readmatrix('LearnParamsPostfMRI_mod1_gA_gH.txt'); % omit header row

for h = 1:max(unique(X(:,1)))
    if ~ismember(h,X(:,1)) % Allow nonsequential or missing integers in Obs
        continue
    end
    k = X(:,1)==h;
    demograph=X(k,1:4);
    mpheight=zeros(iters,15);
    for j=1:iters
        fprintf('%s%i%s%i\n','Obs:',h,' Iter:',j);
        disp('Input Params');
        disp(X(k,[5:11,15]));
        sData = simData(X(k,[5:11,15]));
        [mparams,fit,Ind_pre,Ind_post,trainThresh] = ...
            fitibt_mod1_gA_gH(h,'off',sData(:,1),sData(:,2),sData(:,3),sData(:,4));
        disp('Output Params');
        disp([mparams,trainThresh]);
        mpheight(j,:)=[demograph(1,:),mparams,fit,Ind_pre,Ind_post,trainThresh];
        mparams=[];
    end
    % Save parameters to a folder
    status = mkdir(sprintf('%s%i','Bootstrap/'));
    fname=sprintf('%s%i%s','Bootstrap/',h,'_mParams');
    dlmwrite(fname,mpheight(mpheight(:,1)~=0,:));
end
