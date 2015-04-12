% clear all;

addpath('./helpfun/');
addpath('../liblinear-1.91/windows');
addpath('../libsvm-3.12/windows/');

%seting parameter
rfSizes = [6];
options.ReducedDim = 10;
options.Pyramid = [1 1;2 2; 4 4; 6 6; 8 8; 10 10; 12 12; 15 15;];
options.pooling = 'average';


% dataset = 'AR_disguise';
% data_DIR='../dataset/AR/data_AR_disguise_DIM_64.mat';
% f1 = load(data_DIR);
% trainX = double(f1.data_train.A');
% trainY = double(f1.data_train.label);
% testX = double(f1.data_test_sunglass.Y');
% testY = double(f1.data_test_sunglass.label);
% clear f1
% options.DIM = [64 64];

dataset = 'FERET';
f1 = load('../dataset/FERET/Fa_dat_nohistmask.mat');
trainX = double(f1.fa_dat');
trainY = double(f1.fa_label);
f1 = load('../dataset/FERET/Fb_dat_nohistmask.mat');
testX = double(f1.fb_dat');
testY = double(f1.fb_label);
options.DIM = [150 130];



fprintf([dataset ':\n']);


trainXC = [];testXC=[];
for ix_rf = 1:length(rfSizes)
    rfSize = rfSizes(ix_rf);
    options.rfSize = rfSize;
    
    % compute PCA projection matrix
    numPatches = 10000;
    patches = zeros(numPatches, options.rfSize*options.rfSize);
    for i=1:numPatches
        %if (mod(i,1000) == 0) fprintf('Extracting patch: %d / %d\n', i, numPatches); end
        r = random('unid', options.DIM(1) - options.rfSize + 1);
        c = random('unid', options.DIM(2) - options.rfSize + 1);
        patch = reshape(trainX(random('unid', size(trainX,1)),:), options.DIM);
        patch = patch(r:r+options.rfSize-1,c:c+options.rfSize-1,:);
        patches(i,:) = patch(:)';
    end
    % normalize for contrast
    patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
    % PCA
    options.eigvector = PCA(patches,options);
    
    %% feature extraction
    disp('feature extracting...');
    
    [xp] =  extract_feature_2ndPooling(trainX(1,:), options);
    tem = zeros(size(trainX,1),length(xp));
    
    
    for i = 1:size(trainX,1)
        %if ~mod(i, 5), fprintf('.'); end
        if (mod(i,100) == 0), fprintf('Extracting features: %d / %d\n', i, size(trainX,1)); end
        [xp] =  extract_feature_2ndPooling(trainX(i,:), options);
        tem(i,:) =  xp;
    end
    tem = squash_features(tem', 'power')';
    trainXC = [trainXC, tem];
    
    tem = zeros(size(testX,1),length(xp));
    for i = 1:size(testX,1)
        %if ~mod(i, 5), fprintf('.'); end
        if (mod(i,100) == 0), fprintf('Extracting features: %d / %d\n', i, size(testX,1)); end
        [xp] =  extract_feature_2ndPooling(testX(i,:), options);
        tem(i,:) =  xp;
    end
    tem = squash_features(tem', 'power')';
    testXC = [testXC, tem];
end
trainXC_b = double(trainXC>0);
testXC_b = double(testXC>0);

%% classification
fprintf('Testing...\n');
classifier = 'RRC';
lambda = 1; % param for RRC
lc = 1; % param for libSVM

switch classifier
    case 'RRC'
        [trainXC, testXC] = standard(trainXC, testXC);
        trainXC = [trainXC, ones(size(trainXC,1),1)];
        testXC = [testXC, ones(size(testXC,1),1)];
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
    case 'KNN'
        k = 1;
        labels = knnclassify(testXC,trainXC,trainY(:),k);        
end
acc = sum(labels == testY(:)) / length(testY);
fprintf('Test accuracy %f%%\n', 100 * acc);


