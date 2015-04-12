close all
clear

SPAMS_DIR='/home/pli/2_Packages/spams-matlab/build/'; % E.g.: 'SPAMS/release/mkl64'

% dataset = 'LFW';
% data_DIR = '../dataset/LFW_158_split.mat';

% dataset = 'lfw_temp';
% data_DIR = './lfw_temp.mat';

% dataset = 'AR';
% data_DIR='../dataset/AR/data_AR.mat';

% dataset = 'AR_ALL';
% data_DIR='../dataset/AR/data_AR_all.mat';

% dataset = 'AR_disguise';
% data_DIR='../dataset/AR/data_AR_disguise.mat';
% % % 
% dataset = 'YaleB';
% data_DIR='../dataset/YaleB/data_YaleB.mat';

dataset = 'FERET_32';
data_DIR = '../dataset/data_FERET_DIM_32.mat';

fprintf([dataset ':\n']);
DIM=[32 32];

%%%%% Configuration
addpath minFunc;
rfSize = 6;
numBases=1600;
disp(numBases);
alpha = 0.25;  %% CV-chosen value for soft-threshold function.
lambda = 1;  %% CV-chosen sparse coding penalty.
knn = 5;

%%%%% Dictionary Training %%%%%%
alg='patches'; %% Use randomly sampled patches.  Test accuracy 79.14%
% alg = 'kmeans';
% alg='omp1';   %% Use 1-hot VQ (OMP-1).  Test accuracy 79.96%
%alg='sc';     %% Sparse coding
fprintf(['Dictionary training: ' alg '\n']);

%%%%% Encoding %%%%%%
encoder='thresh'; encParam=alpha; %% Use soft threshold encoder.
% encoder='sc'; encParam=lambda; %% Use sparse coding for encoder.
% encoder='LLC_average_pool';encParam = knn;
% encoder='LSC';encParam = knn;
% encoder = 'triangle'; encParam = '';
fprintf(['Encoding: ' encoder '\n']);


if (strcmp(alg,'sc') || strcmp(encoder, 'sc'))
  assert(~strcmp(SPAMS_DIR, '/path/to/SPAMS/release/platform'), ...
         ['You need to modify sc_vq_demo.m so that SPAMS_DIR points to ' ...
          'the SPAMS toolkit release directory.  You can download this ' ...
          'toolkit from:  http://www.di.ens.fr/willow/SPAMS/downloads.html']);
  addpath(SPAMS_DIR);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %% Load  
[data_train, data_test] = datapre(dataset, 5,  2, randi(10));
trainX = double(data_train.A');
trainY = double(data_train.label);
testX = double(data_test.Y');
testY = double(data_test.label); 

% extract random patches
%  if exist(['Dict/' dataset '_dictionary_' alg '.mat'], 'file')
%      load(['Dict/' dataset '_dictionary_' alg], 'dictionary', 'M', 'P');
%  else
    fprintf('Loading training data...\n');
    switch (alg)
        case 'omp1'
            numPatches = 400000;
        case 'sc'
            numPatches = 100000;
        case 'patches'
            numPatches = 50000; % still needed for whitening
        case 'kmeans'
            numPatches = 50000;
    end
    patches = zeros(numPatches, rfSize*rfSize);
    for i=1:numPatches
        if (mod(i,10000) == 0) fprintf('Extracting patch: %d / %d\n', i, numPatches); end
        r = random('unid', DIM(1) - rfSize + 1);
        c = random('unid', DIM(2) - rfSize + 1);
        patch = reshape(trainX(random('unid', size(trainX,1)),:), DIM);
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
    
    %% run dictionary training
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
    end
%     save(['Dict/' dataset '_dictionary_' alg], 'dictionary', 'M', 'P');
    % show results of training
%     show_centroids(dictionary * 5, rfSize); drawnow;
%  end

% if exist(['Feat/' dataset '_feature_' alg '_' encoder '.mat'], 'file')
%     load(['Feat/' dataset '_feature_' alg '_' encoder '.mat'], 'testXCs','trainXCs');
% else
    %% extract training features
    if strcmp(encoder, 'triangle')
        [~, centroids] = litekmeans(patches, numBases,'MaxIter', 30);
        encParam = centroids;
    end
    trainXC = extract_features_2D_Pyramid(trainX, dictionary, rfSize, ...
        DIM, M,P, encoder, encParam);
    clear trainX;
    
    % standardize data
    trainXC_mean = mean(trainXC);
    trainXC_sd = sqrt(var(trainXC)+0.01);
    trainXCs = bsxfun(@rdivide, bsxfun(@minus, trainXC, trainXC_mean), trainXC_sd);
    clear trainXC;
    trainXCs = [trainXCs, ones(size(trainXCs,1),1)]; % intercept term
    
    % compute testing features and standardize
    testXC = extract_features_2D_Pyramid(testX, dictionary, rfSize, ...
        DIM, M,P, encoder, encParam);
    clear testX;
    testXCs = bsxfun(@rdivide, bsxfun(@minus, testXC, trainXC_mean), trainXC_sd);
    clear testXC;
    testXCs = [testXCs, ones(size(testXCs,1),1)];
    
%     save(['Feat_' dataset], 'trainY','testY','trainXC', 'testXC','-v7.3');
% end

%%

%%%%%%%%% ridge regression classifier %%%%%%%%%%%%%%%%%%%%%
%[W, labels] = RRC(trainXCs, trainY(:), 0.005);
%fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
%[val,labels] = max(testXCs*W, [], 2);
%acc = sum(labels == testY) / length(testY);
%fprintf('Test accuracy %f%%\n', 100 * acc);
%save(['./res/acc_5Pyramid_' dataset '_mycoding_' alg '_' encoder], 'acc');


%%%%%%%%%%%% LibSVM SVM %%%%%%%%%%%%%%%%%%%%%
 %addpath /home/pli/2_Packages/liblinear-1.93/matlab
 addpath /home/pli/2_Packages/libsvm-3.17/matlab
 
 model = {ovrtrain(double(trainY),sparse(trainXCs),'-s 0 -t 0 -c 1')};
 [~, accs] = ovrpredict(double(testY),sparse(testXCs),model{1});
 acc = accs(1);
 save(['./res_svm/acc_' dataset '_mycoding_' alg '_' encoder], 'acc');
 fprintf('Test accuracy %f%%\n', acc);

