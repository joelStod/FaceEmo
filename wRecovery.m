% Outputs a csv file of input parameters and output parameters
% for a recovery test. i = input params, o = output params

% i_sigma, i_theta, i_epsilon, i_p, i_s, i_gA, i_gH, i_trainThresh, 
% o_sigma, o_theta, o_epsilon, o_p, o_s, o_gA, o_gH, o_fit, o_Ind_pre, o_Ind_post,
% o_trainThresh

% Obs numbers are integers unique to the training session
% Initialize
iters = 1000;
mpheight=zeros(iters,21);

parfor h = 1:iters
    % Range is 90% interval of 63 youth in the study.
    p=rand*2.34+6.40; % p is used twice so needs an assignment
    % gA and gH are related, 95%ile of gA+gH = 0.32
    gA=rand*0.18;
    gH=rand*(0.39-gA);
    if(gH>0.27)
        gH=rand*0.27;
    end
    X = [rand*14.85 + 0.15,...      % sigma 0.15-15
        rand*9.52 + 0.48,...        % theta 0.48-10
        rand*0.71,...               % effEpsMax 0.00-0.71
        p,...                       % p 6.40-8.75, ok with experiment bounds
        rand*.99+.01,...            % s .01-1.00
        gA,...                      % gA .00-.18
        gH,...                      % gH .00-.27, but max gH+gA=0.39
        round(p)+2];                % rough trainThresh estimate
    fprintf('%s%i\n','Obs:',h);
    try % Some parameter combinations may not be realistic
        sData = simData(X);
    catch ME
        disp(ME.message); % for debugging
        disp(X);
        continue; % jump to the next iteration of h
    end
    [mparams,fit,numFit,Ind_pre,Ind_post,trainThresh,epsilon] = ...
        minimizeFit(h,'off',sData(:,1),sData(:,2),sData(:,3),sData(:,4));
    mpheight(h,:)=[X,mparams,fit,numFit,Ind_pre,Ind_post,trainThresh,epsilon];
    mparams=[];
end
% Save parameters to a file
dlmwrite('ParamRecovery.txt',mpheight);