% %%%%% TESTING %%%%%

para_DIR = './para/';

load ([para_DIR 'theta'],'theta');
load ([para_DIR 'dics'], 'dictionary1' ,'dictionary2', 'M1', 'M2', 'P1', 'P2')
T = 108;
numBases2 = 100;
numRF = 32;
rfSize1 = 6;
CIFAR_DIM=[32 32 3];
alpha = 0.25;  %% CV-chosen value for soft-threshold function.
lambda = 1.0;  %% CV-chosen sparse coding penalty.
encoder='thresh'; encParam=alpha;
%%%% fake X2order
X2order = randi(1600*4, numRF,T);
%%%%
numTestImage = 10000;
% Load CIFAR test data

fprintf('Loading test data...\n');
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

%%% pooling for layer2 output
poolingCols = 0;     % 0, no pooling for the coding results
poolingRows = 0;


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

%%%% normalize the testing features                      
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
% matlabpool close