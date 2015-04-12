close all
clear

addpath ../ksvdbox
addpath ../ompbox/
 
 
SPAMS_DIR='/home/peng/Documents/MATLAB/spams-matlab/build'; % E.g.: 'SPAMS/release/mkl64'
addpath(SPAMS_DIR);

% dataset = 'AR_ALL';
% data_DIR='../dataset/AR/data_AR_ALL.mat';

dataset = 'YaleB';
data_DIR='../dataset/YaleB/data_YaleB.mat';


fprintf([dataset ':\n']);
DIM=[32 32];

%%%%% Configuration
addpath minFunc;
rfSize = 6;
numBases=1600;


algs = {'patches','K_MEANS','ksvd', 'sc'};
encoders = { 'thresh', 'sc',  'LLC', 'RR', 'triangle','VQ'};


alpha = 0.25;  %% CV-chosen value for soft-threshold function.
lambda = 1;  %% CV-chosen sparse coding penalty.
knn = 5;

for ix_alg =  4
    alg = algs{ix_alg};
    fprintf(['Dictionary training: ' alg ' on ' dataset '\n']);
    
    f1 = load(data_DIR);
    %% dictionary learning
    data_for_dict = double(f1.data_train.A');
    numPatches = 50000;
    patches = zeros(numPatches, rfSize*rfSize);
    for i=1:numPatches
        if (mod(i,10000) == 0) fprintf('Extracting patch: %d / %d\n', i, numPatches); end
        r = random('unid', DIM(1) - rfSize + 1);
        c = random('unid', DIM(2) - rfSize + 1);
        patch = reshape(data_for_dict(random('unid', size(data_for_dict,1)),:), DIM);
        patch = patch(r:r+rfSize-1,c:c+rfSize-1,:);
        patches(i,:) = patch(:)';
    end
    
    % normalize for contrast
    patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
    
    % ZCA whitening (with low-pass)
    C = cov(patches);
    M = mean(patches);
    [V,D] = eig(C);
    P = V * diag(sqrt(1./(diag(D) + 0.1))) * V';
    patches = bsxfun(@minus, patches, M) * P;
    
    % run training
    switch alg
        case 'omp1'
            dictionary = run_omp1(patches, numBases, 50);
        case 'sc'
            dictionary = run_sc(patches, numBases, 10, lambda);
        case 'patches'
            dictionary = patches(randsample(size(patches,1), numBases), :);
            dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)) + 1e-20);
        case 'K_MEANS'
            [~, dictionary] = litekmeans(patches, numBases);
            dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)) + 1e-20);
        case 'ksvd'
            params.data = patches';
            params.Tdata = 30;
            params.dictsize = numBases;
            params.iternum = 30;
            params.memusage = 'high';
            [dictionary] = ksvd(params,'');
            dictionary = dictionary';
    end      
    show_centroids(dictionary * 5, rfSize); drawnow;
    %% feature encoding 
    for ix_encoder = 1:2
        encoder = encoders{ix_encoder};
        fprintf(['Encoding: ' encoder '\n']);
        encParam = [];
        if strfind(encoder, 'thresh')
            encParam=alpha;
        elseif strfind(encoder, 'LLC')
            encParam = knn;
        elseif strfind(encoder, 'sc')
            encParam=lambda;
        elseif strfind(encoder, 'RR')
            delta = 1;
            encParam=delta;
        end
        trainX = double(f1.data_train.A');
        trainY = double(f1.data_train.label);
        testX = double(f1.data_test.Y');
        testY = double(f1.data_test.label);
       
%         
%          if strcmp(encoder, 'triangle')
%             [~, centroids] = litekmeans(patches, numBases,'MaxIter', 30);
%             encParam = centroids;
%          end
        % extract training features
        trainXC = extract_features_2D_3Pyramid(trainX, dictionary, rfSize, ...
            DIM, M,P, encoder, encParam);
        clear trainX;
        % standardize data
        trainXC_mean = mean(trainXC);
        trainXC_sd = sqrt(var(trainXC)+0.01);
        trainXCs = bsxfun(@rdivide, bsxfun(@minus, trainXC, trainXC_mean), trainXC_sd);
        clear trainXC;
        trainXCs = [trainXCs, ones(size(trainXCs,1),1)]; % intercept term
        
        % compute testing features and standardize
        testXC = extract_features_2D_3Pyramid(testX, dictionary, rfSize, ...
            DIM, M,P, encoder, encParam);
        clear testX;
        testXCs = bsxfun(@rdivide, bsxfun(@minus, testXC, trainXC_mean), trainXC_sd);
        clear testXC;
        testXCs = [testXCs, ones(size(testXCs,1),1)];        
        %%
        %%%%%%%%% ridge regression classifier %%%%%%%%%%%%%%%%%%%%%
        [W, labels] = RRC(trainXCs, trainY(:), 0.005);
        fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
        [val,labels] = max(testXCs*W, [], 2);
        acc(ix_alg, ix_encoder) = sum(labels == testY) / length(testY);
%         save(['./res_other_database/acc_' dataset '_mycoding_' encoder '_Dict_' dataset '_' alg], 'acc');
        fprintf('Test accuracy %f%%\n', 100 * acc(ix_alg, ix_encoder));        
    end
    disp(acc);
end

