clear all;

addpath('./helpfun/');
addpath('../liblinear-1.91/windows');
addpath('../libsvm-3.12/windows/');


%seting parameter
options.DIM = [100 100];
rfSizes = [6];
options.ReducedDim = 10;
options.Pyramid = [1 1;2 2; 4 4; 6 6; 8 8; 10 10; 12 12; 15 15;];%];%
options.pooling = 'average';


dataset = 'PubFig83';

num_run = 5;
num_train = 30;
num_test = 10;
fprintf(['num_train: ', num2str(num_train), '\n']);

acc = [];
for run = 1 : num_run
    fprintf(['run: ', num2str(run), '\n']);
    [data_train, data_test] = datapre(dataset, num_train, num_test,run);
    tr_dat = double(data_train.A');
    trls = double(data_train.label);
    tt_dat = double(data_test.Y');
    ttls = double(data_test.label);
    
    
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
            patch = reshape(tr_dat(random('unid', size(tr_dat,1)),:), options.DIM);
            patch = patch(r:r+options.rfSize-1,c:c+options.rfSize-1,:);
            patches(i,:) = patch(:)';
        end
        % normalize for contrast
        patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
        % PCA
        options.eigvector = PCA(patches,options);
        
        %% feature extraction
        disp('feature extracting...');
        
        [xp] =  extract_feature_2ndPooling(tr_dat(1,:), options);
        tem = zeros(size(tr_dat,1),length(xp));
        
        
        for i = 1:size(tr_dat,1)
            %if ~mod(i, 5), fprintf('.'); end
            if (mod(i,100) == 0), fprintf('Extracting features: %d / %d\n', i, size(tr_dat,1)); end
            [xp] =  extract_feature_2ndPooling(tr_dat(i,:), options);
            tem(i,:) =  xp;
        end
        tem = squash_features(tem', 'power')';
        trainXC = [trainXC, tem];
        
        tem = zeros(size(tt_dat,1),length(xp));
        for i = 1:size(tt_dat,1)
            %if ~mod(i, 5), fprintf('.'); end
            if (mod(i,100) == 0), fprintf('Extracting features: %d / %d\n', i, size(tt_dat,1)); end
            [xp] =  extract_feature_2ndPooling(tt_dat(i,:), options);
            tem(i,:) =  xp;
        end
        tem = squash_features(tem', 'power')';
        testXC = [testXC, tem];
    end
    
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
            [W, labels] = RRC(trainXC, trls(:), lambda);
            fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trls(:)) / length(trls)));
            [~,labels] = max(testXC*W, [], 2);
        case 'libSVM'
            % [trainXC, testXC] = standard(trainXC, testXC);
            disp('libSVM training...');
            % libsvm dual
            K = double(trainXC*trainXC');
            K_test = double(testXC*trainXC');
            n_class = unique(trls);
            libsvm = cell(numel(n_class),1);
            for j=1:numel(n_class)
                these_labels = -ones(numel(trls),1);
                these_labels(trls == n_class(j)) = 1;
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
    acc(run) = sum(labels == ttls(:)) / length(ttls);
    fprintf('Test accuracy %f%%\n', 100 * acc(run));
end

acc_mean=mean(acc)
acc_std=std(acc)



