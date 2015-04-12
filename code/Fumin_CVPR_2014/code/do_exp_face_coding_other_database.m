close all
clear

SPAMS_DIR='../spams-matlab/build/'; % E.g.: 'SPAMS/release/mkl64'

% dataset = 'lfw';
% data_DIR = '../dataset/lfw_lei.mat';


% dataset = 'AR';
% data_DIR='../dataset/AR/data_AR.mat';

% dataset = 'AR_ALL';
% data_DIR='../dataset/AR/data_AR_ALL.mat';

dataset = 'YaleB';
data_DIR='../dataset/YaleB/data_YaleB.mat';

% dataset_Dict = 'cifar_gray';
% data_Dict_DIR = './cifar_gray.mat';

% dataset_Dict = 'LFW';
% data_Dict_DIR = './LFW_158_split.mat';

dataset_Dict = 'AR_ALL';
data_Dict_DIR='../dataset/AR/data_AR_ALL.mat';

% dataset_Dict = 'YaleB';
% data_Dict_DIR='../dataset/YaleB/data_YaleB.mat';

fprintf([dataset ':\n']);
DIM=[32 32];

%%%%% Configuration
addpath minFunc;
rfSize = 6;
numBases=1600;

alpha = 0.25;  %% CV-chosen value for soft-threshold function.
lambda = 1;  %% CV-chosen sparse coding penalty.
knn = 5;

%%%%% Dictionary Training %%%%%%
% alg = 'kmeans';
alg='patches'; %% Use randomly sampled patches.  Test accuracy 79.14%
% alg='omp1';   %% Use 1-hot VQ (OMP-1).  Test accuracy 79.96%
% alg='sc';     %% Sparse coding
% alg = 'ksvd';
fprintf(['Dictionary training: ' alg ' on ' dataset_Dict '\n']);
%%%%% Encoding %%%%%%
% encoder='thresh'; encParam=alpha; %% Use soft threshold encoder.
% encoder='thresh_max_pool'; encParam=alpha; %% Use soft threshold encoder.
encoder='sc'; encParam=lambda; %% Use sparse coding for encoder.
% encoder='LLC';encParam = knn;
fprintf(['Encoding: ' encoder '\n']);


if (strcmp(alg,'sc') || strcmp(encoder, 'sc'))
  assert(~strcmp(SPAMS_DIR, '/path/to/SPAMS/release/platform'), ...
         ['You need to modify sc_vq_demo.m so that SPAMS_DIR points to ' ...
          'the SPAMS toolkit release directory.  You can download this ' ...
          'toolkit from:  http://www.di.ens.fr/willow/SPAMS/downloads.html']);
  addpath(SPAMS_DIR);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




 
% extract random patches


% if exist(['Dict/' dataset_Dict '_dictionary_' alg '.mat'], 'file')
%     load(['Dict/' dataset_Dict '_dictionary_' alg], 'dictionary', 'M', 'P');
% else
    
    % Load  data for dictionary learning
    fprintf('Loading data for dictionary learning...\n');
    f1 = load(data_Dict_DIR);
    data_for_dict = double(f1.data_train.A');
%     data_for_dict = double(f1.cifar);

    
    clear f1
 


    switch (alg)
        case 'omp1'
            numPatches = 400000;
        case 'sc'
            numPatches = 100000;
        case 'patches'
            numPatches = 50000; % still needed for whitening
        case 'kmeans'
            numPatches = 50000;
        case 'ksvd'
            numPatches = 50000;
    end
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
        case 'kmeans'
            [~, dictionary] = litekmeans(patches, numBases);
            dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)) + 1e-20);
        case 'ksvd'
            params.data = patches';
            params.Tdata = 3;
            params.dictsize = numBases;
            params.iternum = 30;
            params.memusage = 'high';
            [dictionary] = ksvd(params,'');dictionary = dictionary';
    end
%     save(['Dict/' dataset_Dict '_dictionary_' alg], 'dictionary', 'M', 'P');
%     % show results of training
%     show_centroids(dictionary * 5, rfSize); drawnow;
% end

% Load  data
% fprintf('Loading training data...\n');
f1 = load(data_DIR);
trainX = double(f1.data_train.A');
trainY = double(f1.data_train.label);
testX = double(f1.data_test.Y');
testY = double(f1.data_test.label);
clear f1
 
% if ~exist(['Feat/' dataset '_feature_' alg '_' encoder '_' dataset_Dict '.mat'], 'file')
%     load(['Feat/' dataset '_feature_' alg '_' encoder '_' dataset_Dict '.mat'], 'testXCs','trainXCs');
% else
    
    % extract training features
    trainXC = extract_features_2D_3Pyramid(trainX, dictionary, rfSize, ...
        DIM, M,P, encoder, encParam);
    %clear trainX;
    
    % standardize data
    trainXC_mean = mean(trainXC);
    trainXC_sd = sqrt(var(trainXC)+0.01);
    trainXCs = bsxfun(@rdivide, bsxfun(@minus, trainXC, trainXC_mean), trainXC_sd);
    %clear trainXC;
    trainXCs = [trainXCs, ones(size(trainXCs,1),1)]; % intercept term
    
    % compute testing features and standardize
    testXC = extract_features_2D_3Pyramid(testX, dictionary, rfSize, ...
        DIM, M,P, encoder, encParam);
    %clear testX;
    testXCs = bsxfun(@rdivide, bsxfun(@minus, testXC, trainXC_mean), trainXC_sd);
    %clear testXC;
    testXCs = [testXCs, ones(size(testXCs,1),1)];
    
%     save(['Feat/' dataset '_feature_' alg '_' encoder '_' dataset_Dict '.mat'], 'testXCs','trainXCs');
% end

%%
%%%%% TRAINING ClASSIFIER %%%%%

% % train classifier using SVM
% theta = train_svm(trainXCs, trainY, 1/L);
% [val,labels] = max(trainXCs*theta, [], 2);

%%%%%%%%% ridge regression classifier %%%%%%%%%%%%%%%%%%%%%
[W, labels] = RRC(trainXCs, trainY(:), 0.005);
fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
[val,labels] = max(testXCs*W, [], 2);
acc = sum(labels == testY) / length(testY);
save(['./res_other_database/acc_' dataset '_mycoding_' encoder '_Dict_' dataset_Dict '_' alg], 'acc');
fprintf('Test accuracy %f%%\n', 100 * acc);

% %%%%%%%%%% Liblinear SVM %%%%%%%%%%%%%%%%%%%%%
% addpath D:\work\Classification\liblinear-1.91\windows
% model = {train(double(trainY),sparse(trainXCs),'-q -s 1')};
% [~, accs] = predict(double(testY),sparse(testXCs),model{1});
% acc = accs(1);
% % Multi-class linear SVM
% model = {train(double(trainY),sparse(trainXCs),'-q -s 4')};
% [~, accs] = predict(double(testY),sparse(testXCs),model{1});
% acc = accs(1);

% save(['./res_new/acc_' dataset '_mycoding_' encoder], 'acc');
% fprintf('Test accuracy %f%%\n', acc);

