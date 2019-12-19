% Run after generating a set of learnings parameters to estimate their SE
% in fitibt V1.3.

% Data are from LearnParamsPostfMRI.txt with columns:
% Obs, SubjID, Session, Condition, sigma, theta, epsilon,p,s,g,LL,
% eIP_pre,eIP_post,trainThresh,duration

% Obs numbers are integers unique to the training session
% Initialize
iters = 1000;

X=readmatrix('LearnParamsPostfMRI.txt'); % omit header row

for h = 1:max(unique(X(:,1)))
    if ~ismember(h,X(:,1)) % Allow nonsequential or missing integers in Obs
        continue
    end
    k = X(:,1)==h;
    demograph=X(k,1:4);
    mpheight=zeros(iters,14);
    for j=1:iters
        disp(sprintf('%s%i%s%i','Obs:',h,' Iter:',j));
        disp('Input Params');
        disp(X(k,[5:10,14]));
        sData = simData(X(k,[5:10,14]));
        [mparams,fit,Ind_pre,Ind_post,trainThresh] = ...
            fitibt(h,'off',sData(:,1),sData(:,2),sData(:,3),sData(:,4));
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
