close all
clear

addpath('./helpfun/');
SPAMS_DIR='../spams-matlab/build/'; % E.g.: 'SPAMS/release/mkl64'
addpath(SPAMS_DIR);
addpath('../libsvm-3.12/windows/');


dataset = 'MPIE_session_1_4';
data_DIR='../dataset/MPIE_session_1_4.mat';
f1 = load(data_DIR);
trainX = double(f1.data_train.A);
trainY = double(f1.data_train.label);
testX = double(f1.data_test.Y);
testY = double(f1.data_test.label);
clear f1
DIM = [100 82];

% dataset = 'FERET';
% f1 = load('../dataset/FERET/Fa_dat_nohistmask.mat');
% trainX = double(f1.fa_dat');
% trainY = double(f1.fa_label);
% f1 = load('../dataset/FERET/Dup1_dat_nohistmask.mat');
% testX = double(f1.dup1_dat');
% testY = double(f1.dup1_label);
% DIM = [150 130];

fprintf([dataset ':\n']);

% ----------------- Configuration -----------------------%
options.rfSize1 = 6;
options.numBases1 = 20;
options.Pyramid1 = [20 20];

options.rfSize2 = 4;
options.numBases2 = 60;
options.Pyramid2 = [1 1; 2 2; 4 4; 6 6];

options.DIM1 = DIM;
options.pooling = 'average';

% Dictionary Training
% alg='patches'; %% Use randomly sampled patches.  
options.alg = 'kmeans';
fprintf(['Dictionary training: ' options.alg '\n']);

% Encoding
alpha = 0.25;  
options.encoder='thresh'; 
options.encParam=alpha; %% Use soft threshold encoder.
% encoder='sc'; encParam=lambda; %% Use sparse coding for encoder.
% encoder='LLC';encParam = knn;
% encoder='LSC';encParam = knn;
% encoder = 'triangle'; encParam = '';
% encoder = 'RR'; encParam = 0.01;
fprintf(['Encoding: ' options.encoder '\n']);


disp('extracting training features...');
[trainXC_Layer1, trainXC_Layer2,options] = extract_features_Encoding_2ndPooling_2layer(trainX, options);
disp('extracting testing features...');
[testXC_Layer1, testXC_Layer2] = extract_features_Encoding_2ndPooling_2layer(testX, options);
clear trainX;
clear testX;
trainXC_Layer1 = single(trainXC_Layer1);
testXC_Layer1 = single(testXC_Layer1);
trainXC_Layer2 = single(trainXC_Layer2);
testXC_Layer2 = single(testXC_Layer2);
trainY = single(trainY);
testY = single(testY);

% -------------- classification --------------------%
fprintf('Testing...\n');
lambda = 1; % param for RRC

disp('Classification with Layer1 + Layer2...');
trainXC = [trainXC_Layer1, trainXC_Layer2];
testXC = [testXC_Layer1,testXC_Layer2];

[trainXC, testXC] = standard(trainXC, testXC);
trainXC = [trainXC, single(ones(size(trainXC,1),1))];
testXC = [testXC, single(ones(size(testXC,1),1))];
[W, labels] = RRC(trainXC, trainY(:), lambda);
fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
[~,labels] = max(testXC*W, [], 2);
acc = sum(labels == testY(:)) / length(testY);
fprintf('Test accuracy %f%%\n', 100 * acc);

disp('Classification with Layer1...');
trainXC = trainXC_Layer1;
testXC = testXC_Layer1;

[trainXC, testXC] = standard(trainXC, testXC);
trainXC = [trainXC, single(ones(size(trainXC,1),1))];
testXC = [testXC, single(ones(size(testXC,1),1))];
[W, labels] = RRC(trainXC, trainY(:), lambda);
fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
[~,labels] = max(testXC*W, [], 2);
acc = sum(labels == testY(:)) / length(testY);
fprintf('Test accuracy %f%%\n', 100 * acc);

disp('Classification with Layer2...');
trainXC = trainXC_Layer2;
testXC = testXC_Layer2;

[trainXC, testXC] = standard(trainXC, testXC);
trainXC = [trainXC, single(ones(size(trainXC,1),1))];
testXC = [testXC, single(ones(size(testXC,1),1))];
[W, labels] = RRC(trainXC, trainY(:), lambda);
fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
[~,labels] = max(testXC*W, [], 2);
acc = sum(labels == testY(:)) / length(testY);
fprintf('Test accuracy %f%%\n', 100 * acc);