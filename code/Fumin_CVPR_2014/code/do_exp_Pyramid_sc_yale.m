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
dataset = 'YaleB';
data_DIR='../dataset/YaleB/data_YaleB.mat';


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
% encoder='thresh'; encParam=alpha; %% Use soft threshold encoder.
encoder='sc'; encParam=lambda; %% Use sparse coding for encoder.
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
 %% Load  data
if strcmp(dataset,'FERET_32')
    f1 = load(data_DIR);
    data = double(f1.data)';
    label = double(f1.label);
    DIM = f1.DIM;
    step = 7; 
    order = randperm(step);
    trainX =[];
    testX =[];
    trainY = [];
    testY = [];
    for i=1:step:1400
        data_temp = data(i:i+6,:);
        label_temp = label(i:i+6,:);
        train = data_temp(order(1:5),:);
        test = data_temp(order(6:7),:);
        trainX = cat(1,trainX,train);
        testX = cat(1,testX,test);
        trainY = cat(1,trainY, label_temp(order(1:5),:));
        testY = cat(1, testY, label_temp(order(6:7),:));
    end
    
elseif strcmp(dataset,'lfw')
        f1 = load(data_DIR);
        data = double(f1.data);
        data = reshape(data, 1024,1580)';
        label = double(f1.label)';
        step = 10; 
        order = randperm(step);
        trainX =[];
        testX =[];
        trainY = [];
        testY = [];
        for i=1:step:1580
            data_temp = data(i:i+9,:);
            label_temp = label(i:i+9,:);
            %%%% select part of 10 as train and test set
            train = data_temp(order(1:5),:);
            test = data_temp(order(6:7),:);
            trainX = cat(1,trainX,train);
            testX = cat(1,testX,test);
            trainY = cat(1,trainY, label_temp(order(1:5),:));
            testY = cat(1, testY, label_temp(order(6:7),:));
        end

elseif strcmp(dataset,'YaleB')
     f1 = load(data_DIR);
     trX = double(f1.data_train.A');
     trY = double(f1.data_train.label);
%      tsX = double(f1.data_test.Y');
%      tsY = double(f1.data_test.label); 
     step = 32;
     order = randperm(step);
     trainX =[];
     testX =[];
     trainY = [];
     testY = [];
     % select 10 in 32 as train data   
     for i=1:step:1216
            trx_temp = trX(i:i+step-1,:);
            try_temp = trY(i:i+step-1,:);            
            %%%% select 10 and 5 as train and test set
            trainX = cat(1,trainX,trx_temp(order(1:10),:));
            testX = cat(1,testX,trx_temp(order(11:15),:));
            trainY = cat(1,trainY,try_temp(order(1:10),:));
            testY = cat(1,testY,try_temp(order(11:15),:));
     end
%      testX = double(f1.data_test.Y');
%      testY = double(f1.data_test.label); 
%      % select 10 in 32 as test data
%      step = 31;
%      for i=1:step:1197
%             tsx_temp = tsX(i:i+step-1,:);
%             tsy_temp = tsY(i:i+step-1,:);
%             testX = cat(1, testX, tsx_temp(order(1:5),:));
%             testY = cat(1, testY, tsy_temp(order(1:5),:));
%      end
        
    
else
     f1 = load(data_DIR);
     trainX = double(f1.data_train.A');
     trainY = double(f1.data_train.label);
     testX = double(f1.data_test.Y');
     testY = double(f1.data_test.label);     
end

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
[W, labels] = RRC(trainXCs, trainY(:), 0.005);
fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
[val,labels] = max(testXCs*W, [], 2);
acc = sum(labels == testY) / length(testY);
fprintf('Test accuracy %f%%\n', 100 * acc);
save(['./res/acc_5Pyramid_' dataset '_mycoding_' alg '_' encoder], 'acc');


% %%%%%%%%%% Liblinear SVM %%%%%%%%%%%%%%%%%%%%%
% addpath home/pli/2_Packages/liblinear-1.93/matlab
% model = {train(double(trainY),sparse(trainXCs),'-q -s 3 -c 10')};
% [~, accs] = predict(double(testY),sparse(testXCs),model{1});
% acc = accs(1);
% save(['./res_svm/acc_' dataset '_mycoding_' alg '_' encoder], 'acc');
% fprintf('Test accuracy %f%%\n', acc);

