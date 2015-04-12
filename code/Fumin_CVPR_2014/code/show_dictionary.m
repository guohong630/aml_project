close all
clear

SPAMS_DIR='../spams-matlab/build/'; % E.g.: 'SPAMS/release/mkl64'
addpath(SPAMS_DIR);


dataset = 'AR';
data_DIR='../dataset/AR/data_AR_DIM_64';

fprintf([dataset ':\n']);
DIM=[64 64];

%%%%% Configuration
addpath minFunc;
rfSize = 12;
numBases=100;

alpha = 0.25;  %% CV-chosen value for soft-threshold function.
lambda = 1;  %% CV-chosen sparse coding penalty.
knn = 5;

%%%%% Dictionary Training %%%%%%
alg='patches'; %% Use randomly sampled patches.  Test accuracy 79.14%
% alg = 'kmeans';
% alg = 'ksvd';
% alg='omp1';   %% Use 1-hot VQ (OMP-1).  Test accuracy 79.96%
% alg='sc';     %% Sparse coding
fprintf(['Dictionary training: ' alg '\n']);





% %% Load  data
% f1 = load(data_DIR);
% trainX = double(f1.data_train.A');
% trainY = double(f1.data_train.label);
% testX = double(f1.data_test.Y');
% testY = double(f1.data_test.label);
% clear f1
% 
% fprintf('Loading training data...\n');
% switch (alg)
%     case 'omp1'
%         numPatches = 400000;
%     case 'sc'
%         numPatches = 100000;
%     case 'patches'
%         numPatches = 50000; % still needed for whitening
%     case 'kmeans'
%         numPatches = 50000;
% end
% patches = zeros(numPatches, rfSize*rfSize);
% for i=1:numPatches
%     if (mod(i,10000) == 0) fprintf('Extracting patch: %d / %d\n', i, numPatches); end
%     r = random('unid', DIM(1) - rfSize + 1);
%     c = random('unid', DIM(2) - rfSize + 1);
%     patch = reshape(trainX(random('unid', size(trainX,1)),:), DIM);
%     patch = patch(r:r+rfSize-1,c:c+rfSize-1,:);
%     patches(i,:) = patch(:)';
% end
% 
% save patches patches

load patches
% normalize for contrast
patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
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
    case 'ksvd'
            params.data = patches';
            params.Tdata = 3;
            params.dictsize = numBases;
            params.iternum = 30;
            params.memusage = 'high';
            [dictionary] = ksvd(params,'');
            dictionary = dictionary';
end
figure;
show_centroids(dictionary * 5, rfSize); drawnow;
saveas(gcf, ['./chart/dictionary_' alg '_without_whiten'],'eps')
saveas(gcf, ['./chart/dictionary_' alg '_without_whiten'],'fig')


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
    case 'ksvd'
            params.data = patches';
            params.Tdata = 3;
            params.dictsize = numBases;
            params.iternum = 30;
            params.memusage = 'high';
            [dictionary] = ksvd(params,'');
            dictionary = dictionary';
end
figure;
show_centroids(dictionary * 5, rfSize); drawnow;
saveas(gcf, ['./chart/dictionary_' alg '_with_whiten_RF12'],'eps')
saveas(gcf, ['./chart/dictionary_' alg '_with_whiten_RF12'],'fig')
