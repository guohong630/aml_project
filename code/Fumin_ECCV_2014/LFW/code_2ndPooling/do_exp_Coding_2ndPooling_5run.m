close all
clear

addpath('./helpfun/');
SPAMS_DIR='../spams-matlab/build/'; % E.g.: 'SPAMS/release/mkl64'
addpath(SPAMS_DIR);
addpath('../libsvm-3.12/windows/');


dataset = 'LFW_158_DIM_80';
DIM = [80 80];
fprintf([dataset ':\n']);

%%%%% Configuration
rfSize = 6;
numBases = 20;

alpha = 0.25;  %% CV-chosen value for soft-threshold function.
knn = 5;
Pyramid = [15 15];%[1 1; 2 2; 4 4; 6 6; 8 8;];% 10 10; 12 12; 15 15;];%];%

% Dictionary Training
% alg='patches'; %% Use randomly sampled patches.  Test accuracy 79.14%
alg = 'kmeans';
% alg='omp1';   %% Use 1-hot VQ (OMP-1).  Test accuracy 79.96%
% alg='sc';     %% Sparse coding
fprintf(['Dictionary training: ' alg '\n']);

% Encoding 
encoder='thresh'; encParam=alpha; %% Use soft threshold encoder.
% encoder='sc'; encParam=lambda; %% Use sparse coding for encoder.
% encoder='LLC';encParam = knn;
% encoder='LSC';encParam = knn;
% encoder = 'triangle'; encParam = '';
% encoder = 'RR'; encParam = 0.01;
fprintf(['Encoding: ' encoder '\n']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load  data
num_run = 5;
num_test = 2;
num_train = 1;
for run = 1 : num_run
    fprintf(['run: ', num2str(run), '\n']);
    [data_train, data_test] = datapre(dataset, num_train, num_test,run);
    trainX = double(data_train.A');
    trainY = double(data_train.label);
    testX = double(data_test.Y');
    testY = double(data_test.label);
    
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
   
    
    %% extract  features
    if strcmp(encoder, 'triangle')
        [~, centroids] = litekmeans(patches, numBases,'MaxIter', 30);
        encParam = centroids;
    end
    
    options = [];
    options.rfSize = rfSize;
    options.Pyramid = Pyramid;
    options.DIM = DIM;
    options.pooling = 'average';
    options.M = M;
    options.P = P;
    options.encoder = encoder;
    options.encParam =encParam;
    %options.ReducedDim = 10;   
    
    if isfield(options, 'ReducedDim')
        disp('Compute pca matrix...');
        numPatches = 10000;
        patches = zeros(numPatches, rfSize*rfSize);
        for i=1:numPatches
            %if (mod(i,10000) == 0) fprintf('Extracting patch: %d / %d\n', i, numPatches); end
            r = random('unid', DIM(1) - rfSize + 1);
            c = random('unid', DIM(2) - rfSize + 1);
            patch = reshape(trainX(random('unid', size(trainX,1)),:), DIM);
            patch = patch(r:r+rfSize-1,c:c+rfSize-1,:);
            patches(i,:) = patch(:)';
        end
        patches = encoding(patches, dictionary, options);
        options.eigvector = PCA(patches,options);
        clear patches;
    end
    
    
    trainXC = extract_features_Encoding_2ndPooling(trainX, dictionary, options);
    testXC = extract_features_Encoding_2ndPooling(testX, dictionary, options);
%     trainXC = squash_features(trainXC', 'power')'; 
%     testXC = squash_features(testXC', 'power')'; 
    clear trainX;
    clear testX;
    trainXC = single(trainXC);trainY = single(trainY);
    testXC = single(testXC);testY = single(testY);
    
    %% classification
    fprintf('Testing...\n');
    classifier = 'RRC';
    lambda = 1; % param for RRC
    lc = 1; % param for libSVM
    
    switch classifier
        case 'RRC'
            [trainXC, testXC] = standard(trainXC, testXC);
            trainXC = [trainXC, single(ones(size(trainXC,1),1))];
            testXC = [testXC, single(ones(size(testXC,1),1))];
            [W, labels] = RRC(trainXC, trainY(:), lambda);
            fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
            [~,labels] = max(testXC*W, [], 2);
        case 'libSVM'
            % [trainXC, testXC] = standard(trainXC, testXC);
            disp('libSVM training...');
            % libsvm dual
            K = double(trainXC*trainXC');
            K_test = double(testXC*trainXC');
            n_class = unique(trainY);
            libsvm = cell(numel(n_class),1);
            for j=1:numel(n_class)
                these_labels = -ones(numel(trainY),1);
                these_labels(trainY == n_class(j)) = 1;
                libsvm{j} = svmtrain(these_labels, ...
                    [(1:size(K,1))' K], ...
                    sprintf(' -t 4 -c %f -q -p 0.00001', lc));
            end
            disp('libSVM predicting...');
            scores = cell(numel(libsvm),1);
            for j=1:numel(n_class)
                [predictlabel, duh, scores{j}] = ...
                    svmpredict(zeros(size(K_test,1),1), [[size(K,1)+1:size(K,1)+size(K_test,1)]' K_test], ...
                    libsvm{j});
                if(libsvm{j}.Label(1)==-1)
                    scores{j} = -scores{j};
                end
            end
            
            scores2 = scores';
            scores2 = cell2mat(scores2);
            [value, labels] = max(scores2, [], 2);
    end
    acc(run) = sum(labels == testY) / length(testY);
    fprintf('Test accuracy %f%%\n', 100 * acc(run));   
end

acc_mean=mean(acc)
acc_std=std(acc)
