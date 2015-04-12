close all
clear

addpath('D:\work\Classification\HMP-NIPS\liblinear-1.51\matlab');
addpath('D:\work\Classification\HMP-NIPS\liblinear-1.5-dense-float\matlab');
addpath('D:\work\Classification\HMP-NIPS\helpfun');
addpath('D:\work\Classification\HMP-NIPS\omp_layer1');
addpath('D:\work\Classification\HMP-NIPS\omp_layer2');
addpath('D:\work\Classification\HMP-NIPS\learn_layer1');
addpath('D:\work\Classification\HMP-NIPS\learn_layer2');
addpath(genpath('D:\work\Classification\HMP-NIPS\ksvdbox'));
addpath(genpath('D:\work\Classification\OMPbox\'));

%% load dataset
dataset = 'FERET';
fprintf([dataset ':\n']);
DIM=[64 64];



%% Two-Layer feature learning
type{1} = 'gray';
saveroot = '../hmpfea/';

alg = 'ksvd'; % dictionary learning algorithm
coding = 'thresh';% encoder
if exist('../hmpfea/','dir')
    rmdir('../hmpfea/','s');
end

num_run = 5;
num_test = 2;
for num_train = 5 % training size per class
    fprintf(['num_train: ', num2str(num_train), '\n']);
    for run = 1 : num_run
        fprintf(['run: ', num2str(run), '\n']);
        [data_train, data_test] = datapre(dataset, num_train, num_test,run);
        trainX = double(data_train.A');
        trainY = double(data_train.label);
        testX = double(data_test.Y');
        testY = double(data_test.label);
        
        %% first layer
        % prams for dictionary
        dic_first.alg = alg;
        dic_first.dicsize = 128;
        dic_first.patchsize = 6;
        dic_first.samplenum = 200;
        % parms for feature
        fea_first.data = trainX;
        fea_first.DIM = DIM;
        fea_first.type = type{1};
        fea_first.resizetag = 0;
        %test feature dir
        fea_first.savedir = [saveroot '/' dataset '_hmp_fea_' num2str(dic_first.patchsize) 'x' num2str(dic_first.patchsize) '_' fea_first.type '_test/'];
        mkdir_bo(fea_first.savedir);
        feapathtest = get_fea_path(fea_first.savedir);
        %train feature dir
        fea_first.savedir = [saveroot '/' dataset '_hmp_fea_' num2str(dic_first.patchsize) 'x' num2str(dic_first.patchsize) '_' fea_first.type '_train/'];
        mkdir_bo(fea_first.savedir);
        feapathtrain = get_fea_path(fea_first.savedir);
        if isempty(feapathtrain) || isempty(feapathtest)
            % dictionary learning
            encoder_first.coding = coding;
            if strcmp(encoder_first.coding,'omp')
                [dic_first.dic] = ksvd_learn_layer1(fea_first, dic_first);
            else
                [dic_first.dic, dic_first.M, dic_first.P] = ksvd_learn_layer1(fea_first, dic_first);
            end
            % initialize the parameters of encoder
            encoder_first.encParam = 0.25; % for soft threshold
            encoder_first.pooling = 4;
            encoder_first.sparsity = 4; % for omp
            % orthogonal matching pursuit encoder over training set
            omp_pooling_layer1_batch(fea_first, dic_first, encoder_first);
            feapathtrain = get_fea_path(fea_first.savedir);
            % orthogonal matching pursuit encoder over test set
            fea_first.data = testX;
            fea_first.savedir = [saveroot '/' dataset '_hmp_fea_' num2str(dic_first.patchsize) 'x' num2str(dic_first.patchsize) '_' fea_first.type '_test/'];
            mkdir_bo(fea_first.savedir);
            omp_pooling_layer1_batch(fea_first, dic_first, encoder_first);
            feapathtest = get_fea_path(fea_first.savedir);
        end
        
        %% second layer
        % initialize the parameters of dictionary
        dic_second.alg = alg;
        dic_second.dicsize = 1024;
        dic_second.patchsize = 3;
        dic_second.samplenum = 50;
        % initialize the parameters of encoder
        encoder_second.coding = coding;
        encoder_second.encParam = 0.25; % for soft threshold
        encoder_second.pooling = [1 2 4];
        encoder_second.sparsity = 10; % for omp
        pooling_layer = {'first','second','second+first'};
        for ix_layer = 1:3
            encoder_second.fea = pooling_layer{ix_layer};
            % initialize the paramters of features
            fea_second.feapath = feapathtrain;                        
            % dictionary learning
            if strcmp(encoder_second.fea,'second')||strcmp(encoder_second.fea,'second+first')
                if strcmp(encoder_second.coding,'omp')
                    [dic_second.dic] = ksvd_learn_layer2(fea_second, dic_second);
                else
                    [dic_second.dic, dic_second.M, dic_second.P] = ksvd_learn_layer2(fea_second, dic_second);
                end
            end
            % orthogonal matching pursuit encoder over training set
            featrain_one = omp_pooling_layer2_batch(fea_second, dic_second, encoder_second);
            % lfw_DIM64featrain = single(lfw_DIM64featrain_one);
            % orthogonal matching pursuit encoder over test set
            fea_second.feapath = feapathtest;
            featest_one = omp_pooling_layer2_batch(fea_second, dic_second, encoder_second);
            % lfw_DIM64featest = single(lfw_DIM64featest_one);
            
            %% classification
            featrain = featrain_one';
            featest = featest_one';
            %%%%%%%%% ridge regression classifier %%%%%%%%%%%%%%%%%%%%%
            [W, labels] = RRC(featrain, trainY(:), 0.005);
            fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
            [val,labels] = max(featest*W, [], 2);
            acc(num_train, run,ix_layer) = sum(labels == testY) / length(testY);
            % save(['./res/acc_' dataset '_mycoding_' alg '_' encoder], 'acc');
            fprintf('Test accuracy %f%%\n', 100 * acc(num_train, run,ix_layer));
        end
        rmdir('../hmpfea/','s');
    end
end
acc5 = acc(5,:,:);acc5 = squeeze(acc5);
acc_mean=mean(acc5);
acc_std=std(acc5);
result=[acc_mean',acc_std'];

save(['./res_2layer/acc_' dataset '_' coding '_' alg], 'result');

    
    
    
    
    