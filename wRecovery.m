% Outputs a csv file of input parameters and output parameters
% for a recovery test. i = input params, o = output params

% i_sigma, i_theta, i_epsilon, i_p, i_s, i_g, i_trainThresh, 
% o_sigma, o_theta, o_epsilon, o_p, o_s, o_g, o_fit, o_Ind_pre, o_Ind_post,
% o_trainThresh

% Obs numbers are integers unique to the training session
% Initialize
iters = 1000;
mpheight=zeros(iters,17);

parfor h = 1:iters
    % = mean +/- 2SD parameter from 72 learn params.
    p = rand*3+6;       % realistic starting indifference point
    X = [rand*13,...   % sigma
        rand*10,...     % theta
        rand*0.13,...    % epsilon
        p,...           % p
        rand*.64,...     % s
        rand*0.1,...    % g realistic g (allow 20% random response)
        round(p)+2];           % trainThresh
    fprintf('%s%i\n','Obs:',h);
    disp('Input Params');
    disp(X);
    sData = simData(X);
    [mparams,fit,Ind_pre,Ind_post,trainThresh] = ...
        fitibt(h,'off',sData(:,1),sData(:,2),sData(:,3),sData(:,4));
    disp('Output Params');
    disp([mparams,trainThresh]);
    mpheight(h,:)=[X,mparams,fit,Ind_pre,Ind_post,trainThresh];
    mparams=[];
end
% Save parameters to a file
dlmwrite('ParamRecovery.txt',mpheight);