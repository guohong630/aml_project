close all
clear

addpath('./helpfun/');
SPAMS_DIR='../spams-matlab/build/'; % E.g.: 'SPAMS/release/mkl64'
addpath(SPAMS_DIR);
addpath('../libsvm-3.12/windows/');


dataset = 'FERET';
DIM = [64 64];
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



% -------------- classification --------------------%
fprintf('Testing...\n');
lambda = 1; % param for RRC
num_run = 5;
num_test = 2;
num_train = 5;
acc1 = []; acc2 = []; acc3 = [];
for run = 1 : num_run
    fprintf(['run: ', num2str(run), '\n']);
    [data_train, data_test] = datapre(dataset, num_train, num_test,run);
    trainX = double(data_train.A');
    trainY = double(data_train.label);
    testX = double(data_test.Y');
    testY = double(data_test.label);
	
	[trainXC_Layer1, trainXC_Layer2,options] = extract_features_Encoding_2ndPooling_2layer(trainX, options);
	[testXC_Layer1, testXC_Layer2] = extract_features_Encoding_2ndPooling_2layer(testX, options);
	clear trainX;
	clear testX;
	trainXC_Layer1 = single(trainXC_Layer1);
	testXC_Layer1 = single(testXC_Layer1);
	trainXC_Layer2 = single(trainXC_Layer2);
	testXC_Layer2 = single(testXC_Layer2);
	trainY = single(trainY);
	testY = single(testY);
	
	disp('Classification with Layer1...');
	trainXC = trainXC_Layer1;
	testXC = testXC_Layer1;

	[trainXC, testXC] = standard(trainXC, testXC);
	trainXC = [trainXC, single(ones(size(trainXC,1),1))];
	testXC = [testXC, single(ones(size(testXC,1),1))];
	[W, labels] = RRC(trainXC, trainY(:), lambda);
	fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
	[~,labels] = max(testXC*W, [], 2);
	acc1(run) = sum(labels == testY(:)) / length(testY);
	fprintf('Test accuracy %f%%\n', 100 * acc1(run));

	disp('Classification with Layer2...');
	trainXC = trainXC_Layer2;
	testXC = testXC_Layer2;

	[trainXC, testXC] = standard(trainXC, testXC);
	trainXC = [trainXC, single(ones(size(trainXC,1),1))];
	testXC = [testXC, single(ones(size(testXC,1),1))];
	[W, labels] = RRC(trainXC, trainY(:), lambda);
	fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
	[~,labels] = max(testXC*W, [], 2);
	acc2(run) = sum(labels == testY(:)) / length(testY);
	fprintf('Test accuracy %f%%\n', 100 * acc2(run));
	
	disp('Classification with Layer1 + Layer2...');
	trainXC = [trainXC_Layer1, trainXC_Layer2];
	testXC = [testXC_Layer1,testXC_Layer2];

	[trainXC, testXC] = standard(trainXC, testXC);
	trainXC = [trainXC, single(ones(size(trainXC,1),1))];
	testXC = [testXC, single(ones(size(testXC,1),1))];
	[W, labels] = RRC(trainXC, trainY(:), lambda);
	fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
	[~,labels] = max(testXC*W, [], 2);
	acc12(run) = sum(labels == testY(:)) / length(testY);
	fprintf('Test accuracy %f%%\n', 100 * acc12);

end
	