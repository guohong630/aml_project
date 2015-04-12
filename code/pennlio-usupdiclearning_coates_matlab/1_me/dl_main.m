clear all
close all
matlabpool close force local
%Initialize Matlab Parallel Computing Enviornment
CoreNum=4; 
if matlabpool('size')<=0 
matlabpool('open','local',CoreNum); 
else
matlabpool close;
matlabpool('open','local',CoreNum); 
end
%%%% Path
res_DIR = '../../Results/';
report_file = [res_DIR 'report.txt'];
para_DIR = './para/';
mkdir(para_DIR)
% CIFAR_DIR = 'F:\Peng_File\2_Research\03_coding\2_matlab\01_research\00_reporduce\Coates_2011\2_my_work\cifar-10-batches-mat';
% CIFAR_DIR='/home/peng/Documents/Research in UoA/[03]Paper Implementaion/2011_Coates_ICML/01_original/cifar-10-batches-mat';
CIFAR_DIR='../../Data/cifar-10-batches-mat';
% SPAMS_DIR='/path/to/SPAMS/release/platform'; % E.g.: 'SPAMS/release/mkl64'
addpath minFunc;
%%%%% Configuration
numRF = 32;          %  num of receptive fields
rfSize1 = 6;
numBases1 = 160;
numPatches = 4000;
numTrainImage = 1000;

CIFAR_DIM=[32 32 3];
alpha = 0.25;  %% CV-chosen value for soft-threshold function.
lambda = 1.0;  %% CV-chosen sparse coding penalty.

%%%%% Dictionary Training %%%%%%
%alg='patches'; %% Use randomly sampled patches.  Test accuracy 79.14%
alg='omp1';   %% Use 1-hot VQ (OMP-1).  Test accuracy 79.96%
%alg='sc';     %% Sparse coding

%%%%% Encoding %%%%%%
encoder='thresh'; encParam=alpha; %% Use soft threshold encoder.
%encoder='sc'; encParam=lambda; %% Use sparse coding for encoder.

%%%%% SVM Parameter %%%%%
switch (encoder)
 case 'thresh'
  L = 0.01; % L=0.01 for 1600 features.  Use L=0.03 for 4000-6000 features.
 case 'sc'
  L = 1.0; % May need adjustment for various combinations of training / encoding parameters.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check CIFAR directory
assert(~strcmp(CIFAR_DIR, '/path/to/cifar/cifar-10-batches-mat/'), ...
       ['You need to modify sc_vq_demo.m so that CIFAR_DIR points to ' ...
        'your cifar-10-batches-mat directory.  You can download this ' ...
        'data from:  http://www.cs.toronto.edu/~kriz/cifar-10-matlab.tar.gz']);

%% Check SPAMS install
if (strcmp(alg,'sc') || strcmp(encoder, 'sc'))
  assert(~strcmp(SPAMS_DIR, '/path/to/SPAMS/release/platform'), ...
         ['You need to modify sc_vq_demo.m so that SPAMS_DIR points to ' ...
          'the SPAMS toolkit release directory.  You can download this ' ...
          'toolkit from:  http://www.di.ens.fr/willow/SPAMS/downloads.html']);
  addpath(SPAMS_DIR);
end


%% Load CIFAR training data
fprintf('Loading training data...\n');
f1=load([CIFAR_DIR '/data_batch_1.mat']);
f2=load([CIFAR_DIR '/data_batch_2.mat']);
f3=load([CIFAR_DIR '/data_batch_3.mat']);
f4=load([CIFAR_DIR '/data_batch_4.mat']);
f5=load([CIFAR_DIR '/data_batch_5.mat']);

trainX = double([f1.data; f2.data; f3.data; f4.data; f5.data]);
trainY = double([f1.labels; f2.labels; f3.labels; f4.labels; f5.labels]) + 1; % add 1 to labels!
clear f1 f2 f3 f4 f5;

X1 = trainX(1:numTrainImage,:);
Y1 = trainY(1:numTrainImage,:);
clear trainX trainY


randrows = CIFAR_DIM(1) - rfSize1 + 1;
randcolums = CIFAR_DIM(2) - rfSize1 + 1;
patches = zeros(numPatches, rfSize1*rfSize1*3);

disp('Extracting 1st layer patches...')
parfor i=1:numPatches
  if (mod(i,10000) == 0) 
      fprintf('Extracting patch: %d / %d\n', i, numPatches); 
  end
  r = random('unid', randrows);
  c = random('unid', randcolums);
  rn_row = random('unid', size(X1,1));
  patch = reshape(X1(rn_row,:), CIFAR_DIM);
  patch = patch(r:r+rfSize1-1,c:c+rfSize1-1,:);
  patches(i,:) = patch(:)';
end

%% processing

disp('Normalization and ZCA Whitening for X1...')

%%%%%%%%%%% normalize for contrast %%%%%%
patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));

%%%%%%%%%%% ZCA whitening (with low-pass) %%%%%
C = cov(patches);
M1 = mean(patches);
[V,D] = eig(C);
P1 = V * diag(sqrt(1./(diag(D) + 0.1))) * V';
clear V D C
patches = bsxfun(@minus, patches, M1) * P1;
%%%%%%%%%%% training %%%%%%%%%
disp('Training dictionary...');
switch alg
 case 'omp1'
  dictionary1 = run_omp1(patches, numBases1, 50);
 case 'sc'
  dictionary1 = run_sc(patches, numBases1, 10, lambda);
 case 'patches'
    dictionary1 = patches(randsample(size(patches,1), numBases1), :);
    dictionary1 = bsxfun(@rdivide, dictionary1, sqrt(sum(dictionary1.^2,2)) + 1e-20);
end
clear patches
%%%%%%%%%%% show results of training %%%%%%%%%
% show_centroids(dictionary1 * 5, rfSize); 
% drawnow;
% save ('dic1', 'dictionary1');

disp('Extracting layer1 features...')
%%%%%%%%%%% extract training features %%%%%%%%

tic
[X1F, Z1] = extract_features1(X1, dictionary1, rfSize1, ...
                           CIFAR_DIM, M1,P1, encParam);            
toc
% clear M1 P1 dictionary1;
% save ('X1F','X1F');

clear X1
% clear X1F

%% inter-layer proc 

Z1RN = slice_normZ1(Z1);

%%%%%%%%%%% Compute S with pairwise Whitening %%%%

k1 = size(Z1RN,2);
tic
randrows = randi(k1,1,numRF);
Xj = Z1RN(:,randrows);                       % extract xj within xk
disp ('Compute S with approximation.');
S = compPairSimi(numRF,k1,Xj,Z1RN);
toc
clear Xj

%%%%% select T features out of Z1RN and form N RFs %%%%
T = 108;
X2 = zeros(numTrainImage,T,numRF);
X2order = zeros(numRF, T);
parfor jj =1:numRF
    sr = S(jj,:);
    [re,order] = sort(sr,'descend');
    X2order(jj,:) = order(1:T);    % select T largest features
    for i=1:numTrainImage
        X2(i,:,jj) = Z1RN(i,X2order(jj,:));
    end
end
save ([para_DIR 'X2order'],'X2order')
clear Z1RN S

disp('Normalization and ZCA Whitening for X2...')

%% layer 2
%%%%%%%%%% normalize for contrast %%%%%%%%%%%%%%%
X2 = bsxfun(@rdivide, bsxfun(@minus, X2, mean(X2,2)), sqrt(var(X2,[],2)+10));

%%%%%%%%%% ZCA whitening X2 (with low-pass) %%%%%%%%%%
M2 = zeros(numRF,T);
P2 = zeros(T, T, numRF);
parfor jj = 1:numRF
    X2temp = X2(:,:,jj);
    C = cov(X2temp);
    M2(jj,:) = mean(X2temp);
    [V,D] = eig(C);
    P2(:,:,jj) = V * diag(sqrt(1./(diag(D) + 0.1))) * V';
    X2(:,:,jj) = bsxfun(@minus, X2temp, M2(jj,:)) * P2(:,:,jj);
end
clear X2temp V D C

%%%%%%%%%%% training dics by K-means  %%%%%%%%%%%%
numBases2 = 100;
disp('Training dictionaries for layer 2 ...')
dictionary2 = zeros(numBases2,T,numRF);
for jj = 1:numRF
    dictionary2(:,:,jj) = run_omp1(X2(:,:,jj), numBases2, 50);
    fprintf ('Dic %d trained!\n',jj);
end
clear X2

% save ('dic2', 'dictionary2');
% parfor jj = 1:10 
%     figure
%     show_centroids(dictionary2(:,:,jj)*5, rfSize);
%     drawnow;
% end

% encoding dataset with dics
%%
%%%%%%%%%%% generate patches of image set  %%%%%%%%%%%%
% load('Z1','Z1');
tic
disp('Extracting layer 2 features...')
% load ('X2order','X2order');   
numImgRow = size(Z1,2);
numImgCol = size(Z1,3);
rfSize2 = 2;  % equals the size of slice
numBlkRow = numImgRow-rfSize2+1;
numBlkCol = numImgCol-rfSize2+1;

%%% pooling for layer2 output
poolingCols = 0;     % 0, no pooling for the coding results
poolingRows = 0;

if (poolingCols||poolingRows)     % with  pooling        
    rowsAfterPooling = round(numBlkRow/poolingRows);       
    colsAfterPooling = round(numBlkCol/poolingCols);
    X2F = zeros(numTrainImage, rowsAfterPooling*colsAfterPooling*numBases2, numRF);
else
    X2F = zeros(numTrainImage, numBlkCol*numBlkRow*numBases2,numRF);
end

for jj = 1:numRF
    X2F(:,:,jj) = extract_features2(Z1, dictionary2(:,:,jj), X2order(jj,:), rfSize2, ...                           
                           M2(jj,:),P2(:,:,jj),poolingCols,poolingRows, encoder, encParam);
    fprintf ('Encoding with Dic %d complete\n',jj)
end
toc
% clear dictionary2  M P
X2F = reshape(X2F,numTrainImage,[]);

%%%%% concatenate features %%%%
% load ('X1F','X1F');
disp('Concateneing training features...')
trainXC = cat(2,X1F,X2F);

clear X1F X2F
save ([para_DIR 'dics'], 'dictionary1' ,'dictionary2', 'M1', 'M2', 'P1', 'P2')

%% Training SVM
disp('Training SVM...')
%%%%% standarize data %%%%
trainXC_mean = mean(trainXC);
trainXC_sd = sqrt(var(trainXC)+0.01);
trainXCs = bsxfun(@rdivide, bsxfun(@minus, trainXC, trainXC_mean), trainXC_sd);
clear trainXC;

trainXCs = [trainXCs, ones(size(trainXCs,1),1)]; % intercept term
tic
% train classifier using SVM

theta = train_svm(trainXCs, Y1, 1/L);

toc
[val,labels] = max(trainXCs*theta, [], 2);

file = fopen(report_file,'w');
fprintf(file, 'Train accuracy %f%%\n', 100 * (1 - sum(labels ~= Y1) / length(Y1)));
fclose(file);


save([para_DIR 'theta'],'theta');
save ([para_DIR 'train_val'],'val');
save ([para_DIR 'train_lables'],'labels');
save ([para_DIR 'train_Y1'],'Y1');
%% Prepare data for testing
% %%%%% TESTING %%%%%

numTestImage = 1000;
% Load CIFAR test data

fprintf('Loading TEST data...\n');
f1=load([CIFAR_DIR '/test_batch.mat']);
testX = double(f1.data);
testY = double(f1.labels) + 1;

testX = testX(1:numTestImage,:);
testY = testY(1:numTestImage,:);

clear f1;

%%%% compute testing features of layer 1
disp('Extracting layer 1 features for test set...')
[X1TF, Z1T] = extract_features1(testX, dictionary1, rfSize1, ...
                          CIFAR_DIM, M1,P1, encParam);
                      
disp('Extracting layer 2 features for test set...')                      
numImgRow = size(Z1T,2);
numImgCol = size(Z1T,3);
numBlkRow = numImgRow-rfSize2+1;
numBlkCol = numImgCol-rfSize2+1;


if (poolingCols||poolingRows)     % with  pooling        
    rowsAfterPooling = round(numBlkRow/poolingRows);       
    colsAfterPooling = round(numBlkCol/poolingCols);
    X2TF = zeros(numTestImage, rowsAfterPooling*colsAfterPooling*numBases2, numRF);
else
    X2TF = zeros(numTestImage, numBlkCol*numBlkRow*numBases2,numRF);
end

for jj = 1:numRF
    X2TF(:,:,jj) = extract_features2(Z1T, dictionary2(:,:,jj), X2order(jj,:), rfSize2, ...                           
                           M2(jj,:),P2(:,:,jj),poolingCols,poolingRows, encoder, encParam);
    fprintf ('Encoding with Dic %d complete\n',jj)
end
toc
% clear dictionary2  M P
X2TF = reshape(X2TF,numTestImage,[]);                      

%%%%% concatenate features %%%%
% load ('X1F','X1F');
disp('Concateneing testing features...')
testXC = cat(2,X1TF,X2TF);

clear X1TF X2TF dictionary1 dictionray2 M1 M2 P1 P2
%% Testing 

%%% normalize the testing features                      
% %clear testX;
testXCs = bsxfun(@rdivide, bsxfun(@minus, testXC, trainXC_mean), trainXC_sd);
%clear testXC;
testXCs = [testXCs, ones(size(testXCs,1),1)];

%%%% test and print result
[val,labels] = max(testXCs*theta, [], 2);
file = fopen(report_file,'a');
fprintf(file, 'Test accuracy %f%%\n', 100 * (1 - sum(labels ~= testY) / length(testY)));
fclose(file);
%%%% save 
save ([para_DIR 'test_val'],'val');
save ([para_DIR 'test_lables'],'labels');
save ([para_DIR 'test_Y1'],'testY');
matlabpool close