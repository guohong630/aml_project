close all
clear


addpath ../ksvdbox
 addpath ../ompbox/
 

SPAMS_DIR='../spams-matlab/build/'; % E.g.: 'SPAMS/release/mkl64'



% dataset = 'AR';
% data_DIR='../dataset/AR/data_AR.mat';

dataset = 'AR_ALL';
data_DIR='../dataset/AR/data_AR_ALL.mat';

% dataset = 'YaleB';
% data_DIR='../dataset/YaleB/data_YaleB.mat';


dataset_Dict = 'AR_ALL';
data_Dict_DIR='../dataset/AR/data_AR_ALL.mat';

% dataset_Dict = 'cifar_gray';
% data_Dict_DIR = './cifar_gray.mat';

fprintf([dataset ':\n']);
DIM=[32 32];

%%%%% Configuration
addpath minFunc;
rfSize = 6;
% numBases=1600;


%%%%% Dictionary Training %%%%%%
% alg = 'kmeans';
% alg='patches'; %% Use randomly sampled patches.  Test accuracy 79.14%
% alg='omp1';   %% Use 1-hot VQ (OMP-1).  Test accuracy 79.96%
%alg='sc';     %% Sparse coding

algs = {'ksvd','patches','kmeans', 'omp1','sc'};
for ix_alg = 1 : 1
    alg = algs{ix_alg};
    fprintf(['Dictionary training: ' alg ' on ' dataset_Dict '\n']);
    
    %%%%% Encoding %%%%%%
    alpha = 0.25;  %% CV-chosen value for soft-threshold function.
    lambda = 1;  %% CV-chosen sparse coding penalty.
    knn = 5;
    
    encoder =  'thresh';
    
    if strfind(encoder, 'thresh')
        encParam=alpha;
    elseif strfind(encoder, 'LLC')
        encParam = knn;
    elseif strfind(encoder, 'sc')
        encParam=lambda;
    end
    
    % encoder='thresh'; encParam=alpha; %% Use soft threshold encoder.
    %     encoder='thresh_max_pool'; encParam=alpha; %% Use soft threshold encoder.
    % encoder='sc'; encParam=lambda; %% Use sparse coding for encoder.
    % encoder='LLC_max';encParam = knn;
    fprintf(['Encoding: ' encoder '\n']);
    

    
    % Load  data for dictionary learning
    fprintf('Loading data for dictionary learning...\n');
    f1 = load(data_Dict_DIR);
        data_for_dict = double(f1.data_train.A');
%     data_for_dict = double(f1.cifar);
%      DIM = double(f1.DIM);
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
    
    size_dictionary = [100, 200, 400, 800, 1200, 1600, 2000];
    acc = zeros(1, length(size_dictionary));
    for ix_sz = 1 : length(size_dictionary)
        numBases = size_dictionary(ix_sz);
        fprintf(['dictionary size: ' num2str(numBases) '\n']);
        
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
                [dictionary] = ksvd(params,'');
                dictionary = dictionary';
                dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)) + 1e-20);
        end
        % save(['Dict/' dataset_Dict '_dictionary_' alg], 'dictionary', 'M', 'P');
        % show results of training
%         show_centroids(dictionary * 5, rfSize); drawnow;
        
        
        % Load  data
        % fprintf('Loading training data...\n');
        f1 = load(data_DIR);
        trainX = double(f1.data_train.A');
        trainY = double(f1.data_train.label);
        testX = double(f1.data_test.Y');
        testY = double(f1.data_test.label);
        clear f1
        
        
            
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
            %
            %             save(['Feat/' dataset '_feature_' alg '_' encoder '_' dataset_Dict '.mat'], 'testXCs','trainXCs');
   
        
        %%
        %%%%%%%%% ridge regression classifier %%%%%%%%%%%%%%%%%%%%%
        [W, labels] = RRC(trainXCs, trainY(:), 0.005);
        fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
        [val,labels] = max(testXCs*W, [], 2);
        acc(ix_sz) = sum(labels == testY) / length(testY);
%         save(['./res_other_database/acc_' dataset '_mycoding_' encoder '_Dict_' dataset_Dict '_' alg], 'acc');
        fprintf('Test accuracy %f%%\n', 100 * acc);
        
      
        
        % %%%%%%%%%% Liblinear SVM %%%%%%%%%%%%%%%%%%%%%
        % addpath D:\work\Classification\liblinear-1.91\windows
        % model = {train(double(trainY),sparse(trainXCs),'-q -s 1')};
        % [~, accs] = predict(double(testY),sparse(testXCs),model{1});
        % acc = accs(1);
        % save(['./res_svm/acc_' dataset '_mycoding_' encoder], 'acc');
        % fprintf('Test accuracy %f%%\n', acc);
    end
    
    save(['./res_other_database/acc_compare_DictSize' dataset '_' encoder '_Dict_' dataset_Dict '_' alg],...
        'acc', 'size_dictionary');
    
end



