close all
% clear all
% clc





rfSize = 6;
numBases=1600;

alpha = 0.25;  %% CV-chosen value for soft-threshold function.
lambda = 1;  %% CV-chosen sparse coding penalty.
knn = 5;

dataset = 'FERET';
fprintf([dataset ':\n']);

alg='patches';
fprintf(['Dictionary training: ' alg ' on ' dataset '\n']);
encoder='thresh'; encParam=alpha;
% encoder='sc'; encParam=lambda; %% Use sparse coding for encoder.
% encoder='LLC';encParam = knn;
% encoder='LSC';encParam = knn;
% encoder = 'triangle'; encParam = '';
addpath ../spams-matlab/build/
fprintf(['Encoding: ' encoder '\n']);




num_test = 2;
num_run = 5;
for num_train = 2:5 % training size per class
    fprintf(['num_train: ', num2str(num_train), '\n']);
    for run = 1 : num_run
        fprintf(['run: ', num2str(run), '\n']);
        feat = {'','_LBP'};        
        trainXCs = [];
        testXCs = [];
        for ix_feat = 1:length(feat)
            if strcmp(feat{ix_feat}, '_LBP')
                DIM = [30,30];
            else
                DIM = [32,32];
            end
            dataset_name = [dataset feat{ix_feat}];
            [data_train, data_test] = datapre(dataset_name, num_train, num_test,run);
            trainX = double(data_train.A');
            trainY = double(data_train.label);
            testX = double(data_test.Y');
            testY = double(data_test.label);
            %% dictionary learning
            data_for_dict = trainX;
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
                    [dictionary] = ksvd(params,'');dictionary = dictionary';
            end
            %save(['Dict/' dataset_Dict '_dictionary_' alg], 'dictionary', 'M', 'P');
            % show results of training
            % show_centroids(dictionary * 5, rfSize); drawnow;
            
            if strcmp(encoder, 'triangle')
                [~, centroids] = litekmeans(patches, numBases,'MaxIter', 30);
                encParam = centroids;
            end
            
            
            %% extracting features
            trainXC = extract_features_2D_Pyramid(trainX, dictionary, rfSize, ...
                DIM, M,P, encoder, encParam);
            %         options.ReducedDim = 10000;
            %         [eigvector,eigvalue] = PCA(trainXC,options);
            %         trainXC = trainXC*eigvector;
            clear trainX;
            trainXC_mean = mean(trainXC);
            trainXC_sd = sqrt(var(trainXC)+0.01);
            trainXCs = [trainXCs, bsxfun(@rdivide, bsxfun(@minus, trainXC, trainXC_mean), trainXC_sd)];
            clear trainXC;
            
            % compute testing features and standardize
            testXC = extract_features_2D_Pyramid(testX, dictionary, rfSize, ...
                DIM, M,P, encoder, encParam);
            %         testXC = testXC*eigvector;
            clear testX;
            testXCs = [testXCs, bsxfun(@rdivide, bsxfun(@minus, testXC, trainXC_mean), trainXC_sd)];
            clear testXC;
            
            %% classification
            trainXCs = [trainXCs, ones(size(trainXCs,1),1)]; % intercept term
            testXCs = [testXCs, ones(size(testXCs,1),1)];
            
            %% TRAINING ClASSIFIER %%%%%
            %%%%%%%%% ridge regression classifier %%%%%%%%%%%%%%%%%%%%%
            [W, labels] = RRC(trainXCs, trainY(:), 0.005);
            fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
            [val,labels] = max(testXCs*W, [], 2);
            acc(num_train, run, ix_feat) = sum(labels == testY) / length(testY);
            fprintf('Test accuracy %f%%\n', 100 * acc(num_train, run));
            
            trainXCs(:,end) = [];
            testXCs(:,end) = [];
        end
        
        
%         trainXCs = [trainXCs, ones(size(trainXCs,1),1)]; % intercept term
%         testXCs = [testXCs, ones(size(testXCs,1),1)];
%         
%         %% TRAINING ClASSIFIER %%%%%
%         %%%%%%%%% ridge regression classifier %%%%%%%%%%%%%%%%%%%%%
%         [W, labels] = RRC(trainXCs, trainY(:), 0.005);
%         fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
%         [val,labels] = max(testXCs*W, [], 2);
%         acc(num_train, run) = sum(labels == testY) / length(testY);
%         fprintf('Test accuracy %f%%\n', 100 * acc(num_train, run));

     
        
    end
end

acc_mean=mean(acc,2);
acc_std=std(acc');
result=[acc_mean,acc_std'];
save(['./res_new/acc_5Pyramid' dataset '_mycoding_' encoder '_' alg], 'result');

