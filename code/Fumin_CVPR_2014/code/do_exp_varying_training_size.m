close all
clear

addpath D:\work\Classification\liblinear-1.91\windows

SPAMS_DIR='../spams-matlab/build/'; % E.g.: 'SPAMS/release/mkl64'

dataset = 'AR';
data_DIR='../dataset/AR/data_AR.mat';
% 
% dataset = 'AR_ALL';
% data_DIR='../dataset/AR/data_AR_ALL.mat';
%
% dataset = 'YaleB';
% data_DIR='../dataset/YaleB/data_YaleB.mat';


% dataset_Dict = 'cifar_gray';
% data_Dict_DIR = './cifar_gray.mat';

dataset_Dict = 'AR';
data_Dict_DIR = './AR_dictionary_patches.mat';


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
alg='patches'; %% Use randomly sampled patches.  Test accuracy 79.14%
% alg = 'kmeans';
% alg='omp1';   %% Use 1-hot VQ (OMP-1).  Test accuracy 79.96%
%alg='sc';     %% Sparse coding
fprintf(['Dictionary training: ' alg '\n']);

%%%%% Encoding %%%%%%
encoder='thresh'; encParam=alpha; %% Use soft threshold encoder.
% encoder='sc'; encParam=lambda; %% Use sparse coding for encoder.
% encoder='LLC_average_pool';encParam = knn;
fprintf(['Encoding: ' encoder '\n']);


if (strcmp(alg,'sc') || strcmp(encoder, 'sc'))
    assert(~strcmp(SPAMS_DIR, '/path/to/SPAMS/release/platform'), ...
        ['You need to modify sc_vq_demo.m so that SPAMS_DIR points to ' ...
        'the SPAMS toolkit release directory.  You can download this ' ...
        'toolkit from:  http://www.di.ens.fr/willow/SPAMS/downloads.html']);
    addpath(SPAMS_DIR);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% Load  data
% f1 = load(data_DIR);
% trainX = double(f1.data_train.A');
% trainY = double(f1.data_train.label);
% testX = double(f1.data_test.Y');
% testY = double(f1.data_test.label);
% clear f1

%% extract dictionary
if exist(['Dict/' dataset_Dict '_dictionary_' alg '.mat'], 'file')
    load(['Dict/' dataset_Dict '_dictionary_' alg], 'dictionary', 'M', 'P');
else
    
    % Load  data for dictionary learning
    fprintf('Loading data for dictionary learning...\n');
    f1 = load(data_Dict_DIR);
    data_for_dict = double(f1.data_train.A');
%     data_for_dict = double(f1.cifar);
    DIM_data_for_dict = double(f1.DIM);
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
    end
    patches = zeros(numPatches, rfSize*rfSize);
    for i=1:numPatches
        if (mod(i,10000) == 0) fprintf('Extracting patch: %d / %d\n', i, numPatches); end
        r = random('unid', DIM(1) - rfSize + 1);
        c = random('unid', DIM(2) - rfSize + 1);
        patch = reshape(data_for_dict(random('unid', size(data_for_dict,1)),:), DIM_data_for_dict);
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
    save(['Dict/' dataset_Dict '_dictionary_' alg], 'dictionary', 'M', 'P');
    % show results of training
    show_centroids(dictionary * 5, rfSize); drawnow;
end


%% extract training features
% Load  data
% fprintf('Loading training data...\n');
f1 = load(data_DIR);
trainX= double(f1.data_train.A');
trainY = double(f1.data_train.label);

testX = double(f1.data_test.Y');
testY = double(f1.data_test.label);
clear f1



trainXC = extract_features_2D(trainX, dictionary, rfSize, ...
     DIM, M,P, encoder, encParam);
 %clear trainX;
 
 % compute testing features and standardize
 testXC = extract_features_2D(testX, dictionary, rfSize, ...
     DIM, M,P, encoder, encParam);
 %clear testX;

% This code is for selecting part of training samples
N_smp = length(find(trainY == 1));
N_cls = max(trainY);
max_sz_train = 7; % 7 for AR clean; 32 for Yale B
acc = zeros(1,max_sz_train);
for sz_train = 1 : max_sz_train
    sz_train
    inx_trn = [];
    for ix_cls = 1 : N_cls
        inx_trn = [inx_trn,(ix_cls-1) * N_smp + [1:sz_train]];
    end
    % randomly selection
    % for i = 1 : N
    %     if n_trn_new == 1
    %         ix_rand = 1; % use the first natural sample.
    %     else
    %         ix_rand = randperm(n_trn_old);
    %     end
    %     inx_trn = [inx_trn,(i-1) * n_trn_old + ix_rand(1:n_trn_new)];
    % end
    
    trainXC_p = trainXC(inx_trn,:);
    trainYs = trainY(inx_trn);
    
    % standardize data
    trainXC_mean = mean(trainXC_p);
    trainXC_sd = sqrt(var(trainXC_p)+0.01);
    trainXCs = bsxfun(@rdivide, bsxfun(@minus, trainXC_p, trainXC_mean), trainXC_sd);
    %clear trainXC;
    trainXCs = [trainXCs, ones(size(trainXCs,1),1)]; % intercept term
    
   
    testXCs = bsxfun(@rdivide, bsxfun(@minus, testXC, trainXC_mean), trainXC_sd);
    %clear testXC;
    testXCs = [testXCs, ones(size(testXCs,1),1)];
    
    
    %%
    %%%%% TRAINING ClASSIFIER %%%%%
    
    % % train classifier using SVM
    % theta = train_svm(trainXCs, trainY, 1/L);
    % [val,labels] = max(trainXCs*theta, [], 2);
    
    %%%%%%%%% ridge regression classifier %%%%%%%%%%%%%%%%%%%%%
    [W, labels] = RRC(trainXCs, trainYs(:), 0.005);
    fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainYs(:)) / length(trainYs)));
    [val,labels] = max(testXCs*W, [], 2);
    acc(sz_train) = sum(labels == testY) / length(testY);
    
    fprintf('Test accuracy %f%%\n', 100 * acc);
    
    %%%%%%%%%% Liblinear SVM %%%%%%%%%%%%%%%%%%%%%
    
%     model = {train(double(trainYs),sparse(trainXCs),'-q -s 3 -c 10')};
%     [~, accs] = predict(double(testY),sparse(testXCs),model{1});
%     acc(sz_train) = accs(1);
% %     save(['./res_svm/acc_' dataset '_mycoding_' alg '_' encoder], 'acc');
%     fprintf('Test accuracy %f%%\n', acc);

   %%%%%%%%%%%%%% NN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    
end
save(['./res_svm/acc_vary_trainSZ_' dataset '_mycoding_' alg '_' encoder], 'acc','max_sz_train');
