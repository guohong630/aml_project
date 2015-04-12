close all
clear



% dataset = 'AR';
% data_DIR='../dataset/AR/data_AR.mat';
% dataset = 'AR_ALL';
% data_DIR='../dataset/AR/data_AR_ALL.mat';
% dataset = 'AR_disguise';
% data_DIR='../dataset/AR/data_AR_disguise.mat';

% dataset = 'YaleB';
% data_DIR='../dataset/YaleB/data_YaleB.mat';

% dataset = 'CIFAR10';
% data_DIR='../dataset/cifar10_gray.mat';
dataset = 'feret';
data_DIR = './feret_run1.mat';

fprintf([dataset ':\n']);
DIM=[32 32];

%%%%% Configuration
rfSize = 25;
% Load  data
f1 = load(data_DIR);
trainX = double(f1.data_train.A');
trainY = double(f1.data_train.label);
testX = double(f1.data_test.Y');
testY = double(f1.data_test.label);
clear f1
 




%% extract training features
options.ReducedDim = 8;

tttem = im2col(reshape(trainX(1,:),DIM), [rfSize rfSize]);
NumPatch = size(tttem,2);
Dim_fea = NumPatch*options.ReducedDim;
trainXC_p = zeros(size(trainX,1),rfSize*rfSize, NumPatch);
testXC_p = zeros(size(testX,1),rfSize*rfSize, NumPatch);
% extract overlapping sub-patches into rows of 'patches'
for i=1:size(trainX,1)  
    trainXC_p(i,:,:) = im2col(reshape(trainX(i,:),DIM), [rfSize rfSize]);
end
for i=1:size(testX,1)
    testXC_p(i,:,:) = im2col(reshape(testX(i,:),DIM), [rfSize rfSize]);
end
% PCA
train_tem = zeros(size(trainX,1),options.ReducedDim, NumPatch);
test_tem = zeros(size(testX,1),options.ReducedDim, NumPatch);
for i_patch = 1:NumPatch
    data_trn_patch = trainXC_p(:,:,i_patch);
    [eigvector,eigvalue] = PCA(data_trn_patch,options);
    train_tem(:,:,i_patch) = data_trn_patch*eigvector;
    test_tem(:,:,i_patch) =  testXC_p(:,:,i_patch)*eigvector;
end
trainXC = zeros(size(trainX,1),options.ReducedDim*NumPatch);
testXC = zeros(size(testX,1),options.ReducedDim*NumPatch);
for i = 1 : size(trainX,1)
    tem = train_tem(i,:,:);
    trainXC(i,:) = tem(:);
end
for i = 1:size(testX,1)
    tem = test_tem(i,:,:);
    testXC(i,:) = tem(:);
end

%% standardize data
trainXC_mean = mean(trainXC);
trainXC_sd = sqrt(var(trainXC)+0.01);
trainXCs = bsxfun(@rdivide, bsxfun(@minus, trainXC, trainXC_mean), trainXC_sd);
%    clear trainXC;
trainXCs = [trainXCs, ones(size(trainXCs,1),1)]; % intercept term
testXCs = bsxfun(@rdivide, bsxfun(@minus, testXC, trainXC_mean), trainXC_sd);
%    clear testXC;
testXCs = [testXCs, ones(size(testXCs,1),1)];

   
%%
[W, labels] = RRC(trainXCs, trainY(:), 0.005);
fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
[val,labels] = max(testXCs*W, [], 2);
acc = sum(labels == testY) / length(testY);
save(['./res_manifold/acc_' dataset '_' alg '_real'], 'acc');
fprintf('Test accuracy %f%%\n', 100 * acc);


%% binary
trainH = double(trainXC >0);
testH = double(testXC >0);

[W, labels] = RRC(trainH, trainY(:), 0.005);
fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
[val,labels] = max(testH*W, [], 2);
acc = sum(labels == testY) / length(testY);
save(['./res_manifold/acc_' dataset '_' alg '_binary'], 'acc');
fprintf('Test accuracy %f%%\n', 100 * acc);


% % knn classifier
% [err, ~] = knn_error(double(trainH), trainY, double(testH), testY, 1);
% fprintf('Test accuracy %f%%\n', 100 * (1-err));
