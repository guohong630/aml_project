% oper = 'sqdiff'
% svm_flag = 0
% C_reg = 1
% Bias = 1

DIM =[150, 150];
% LFW_path = '../../dataset/lfw_funneled/';
addpath ./helpfun/ 
addpath ./minFunc/
classifier = 'Liblinear'
parameter_setting = [oper ' -s ' num2str(svm_flag) ' -c ' num2str(C_reg) ' -B ' num2str(Bias)]

% load ('../LFW_Eval.mat')
% clear data1 data2

% load LFW_data_for_dict
% %% read training data
% % Load  data for dictionary learning
% fprintf('Loading data for dictionary learning...\n');
%
% fileID = fopen([LFW_path, 'pairsDevTrain.txt']);
% C = textscan(fileID, '%s %d %s %d');
% fclose(fileID);
% C{1}(1) = [];C{2}(1) = [];C{3}(1) = [];C{4}(1) = [];
% data_for_dict = [];
% for ix_name = 1 : 1100
%     str_name = C{1}{ix_name};
%     % first image
%     str_num = '0000'; tem = num2str(C{2}(ix_name));str_num(end-length(tem)+1:end) = tem;
%     img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%     % crop images to 121x121
%     img_crop = img(65:185, 65:185);
%     % downsampling
%     img_crop = imresize(double(img_crop), DIM);
%     data_for_dict = [data_for_dict, img_crop(:)];
%     % second image
%     str_num = '0000'; tem = num2str(C{3}{ix_name});str_num(end-length(tem)+1:end) = tem;
%     img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%     % crop images to 121x121
%     img_crop = img(65:185, 65:185);
%     % downsampling
%     img_crop = imresize(double(img_crop), DIM);
%     data_for_dict = [data_for_dict, img_crop(:)];
% end
% for ix_name = 1101 : 2200
%     % first person
%     str_name = C{1}{ix_name};
%     str_num = '0000'; tem = num2str(C{2}(ix_name));str_num(end-length(tem)+1:end) = tem;
%     img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%     % crop images to 121x121
%     img_crop = img(65:185, 65:185);
%     % downsampling
%     img_crop = imresize(double(img_crop), DIM);
%     data_for_dict = [data_for_dict, img_crop(:)];
%     % second person
%     str_name = C{3}{ix_name};
%     str_num = '0000'; tem = num2str(C{4}(ix_name));str_num(end-length(tem)+1:end) = tem;
%     img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%     % crop images to 121x121
%     img_crop = img(65:185, 65:185);
%     % downsampling
%     img_crop = imresize(double(img_crop), DIM);
%     data_for_dict = [data_for_dict, img_crop(:)];
% end
% 
% data_for_dict = data_for_dict';

% %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % load evaluation data
% fprintf('Loading data for evaluation...\n');
% fileID = fopen([LFW_path, 'pairs.txt']);
% C = textscan(fileID, '%s %d %s %d');
% fclose(fileID);
% C{1}(1) = [];C{2}(1) = [];C{3}(1) = [];C{4}(1) = [];
% 
% data1 = zeros(22500,6000);
% % first image
% for ix_name = 1:6000
%     str_name = C{1}{ix_name};
%     str_num = '0000'; tem = num2str(C{2}(ix_name));str_num(end-length(tem)+1:end) = tem;
%     img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%     % crop images to 150x150
%     img_crop = img(51:200, 51:200);
%     % downsampling
%     %img_crop = imresize(double(img_crop), DIM);
%     data1(:,ix_name) = img_crop(:);
% end
% disp('data2');
% data2 = zeros(22500,6000);
% % second image
% for ix_folder = 1:10
%     for ix_nm = 1:300
%         ix_name = (ix_folder-1)*600 + ix_nm;
%         str_name = C{1}{ix_name};
%         str_num = '0000'; tem = C{3}{ix_name};str_num(end-length(tem)+1:end) = tem;
%         img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%         % crop images to 150x150
%         img_crop = img(51:200, 51:200);
%         % downsampling
%         %img_crop = imresize(double(img_crop), DIM);
%         data2(:,(ix_folder-1)*600+ix_nm) = img_crop(:);         
%     end
%     tem2 = zeros(22500,300);
%     for ix_nm = 1:300
%         ix_name = (ix_folder-1)*600 + 300 + ix_nm;
%         str_name = C{3}{ix_name};
%         str_num = '0000'; tem = num2str(C{4}(ix_name));str_num(end-length(tem)+1:end) = tem;
%         img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%         % crop images to 150x150
%         img_crop = img(51:200, 51:200);
%         % downsampling
%         %img_crop = imresize(double(img_crop), DIM);
%         data2(:,(ix_folder-1)*600+ix_nm+300) = img_crop(:);  
%     end
%     
% end
% % data = [data1, data2];
% % idxa = 1:6000;
% % idxb = 6001:12000;
% label = repmat([ones(300,1);2*ones(300,1)],10,1);
% save('LFW_Eval', 'data1', 'data2','label','-v7.3');




%% dictionary training

% rfSize = 6;
% numBases = 20;

% alpha = 0.25; 
% knn = 5;
% Pyramid = [1 1; 2 2; 4 4; 6 6; 8 8;];% 10 10; 12 12; 15 15;];%];%
% alg = 'kmeans';
% encoder='thresh'; encParam=alpha; %% Use soft threshold encoder.

% numPatches = 50000;
% patches = zeros(numPatches, rfSize*rfSize);

% load(['LFW_dictionary_' alg], 'dictionary', 'M', 'P');
% for i=1:numPatches
%     if (mod(i,10000) == 0) fprintf('Extracting patch: %d / %d\n', i, numPatches); end
%     r = random('unid', DIM(1) - rfSize + 1);
%     c = random('unid', DIM(2) - rfSize + 1);
%     patch = reshape(data_for_dict(random('unid', size(data_for_dict,1)),:), DIM);
%     patch = patch(r:r+rfSize-1,c:c+rfSize-1,:);
%     patches(i,:) = patch(:)';
% end
% 
% % normalize for contrast
% patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
% 
% % ZCA whitening (with low-pass)
% C = cov(patches);
% M = mean(patches);
% [V,D] = eig(C);
% P = V * diag(sqrt(1./(diag(D) + 0.1))) * V';
% patches = bsxfun(@minus, patches, M) * P;
% 
% % run dictionary training
% switch alg
%     case 'patches'
%         dictionary = patches(randsample(size(patches,1), numBases), :);
%         dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)) + 1e-20);
%     case 'kmeans'
%         [~, dictionary] = litekmeans(patches, numBases,'MaxIter', 50);
%         dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)) + 1e-20);
% end
% save(['LFW_dictionary_' alg], 'dictionary', 'M', 'P');

%% extract features using second-order pooling

% options = [];
% options.rfSize = rfSize;
% options.Pyramid = Pyramid;
% options.DIM = DIM;
% options.pooling = 'average';
% options.M = M;
% options.P = P;
% options.encoder = encoder;
% options.encParam =encParam;



% Feature_data1 = extract_features_Encoding_2ndPooling(data1', dictionary, options);

% Feature_data2 = extract_features_Encoding_2ndPooling(data2', dictionary, options);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Below is the verification test
% Add by Peng Li on May 7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Y = repmat([ones(300,1);-ones(300,1)],10,1);

disp('load data...');

load('d1seg1.mat','d1seg1')      
load('d1seg2.mat','d1seg2')         
load('d1seg3.mat','d1seg3')         
load('d2seg1.mat','d2seg1')      
load('d2seg2.mat','d2seg2') 
load('d2seg3.mat','d2seg3') 

Feature_data1 = [d1seg1;d1seg2;d1seg3];
clear d1seg1 d1seg2 d1seg3

Feature_data2 = [d2seg1;d2seg2;d2seg3];
clear d2seg1 d2seg2 d2seg3


% size(Feature_data1)
% size(Feature_data2)

% disp(['Element process with ' oper]);
% switch oper
% 	case 'mul'
% 		X = Feature_data1.*Feature_data2;
% 	case 'minus'
% 		X = abs(Feature_data1-Feature_data2);
% 	case 'sqrt'
% 		X = sqrt(abs(Feature_data1-Feature_data2));
% 	case 'sqdiff'
% 		X = (Feature_data1-Feature_data2).^2;
% end
% Feature_diff = Feature_data1-Feature_data2;
X = [Feature_data1 Feature_data2];
half = length(Feature_data1(1,:));  % 
clear Feature_data1
clear Feature_data2


% %%% normalize %%%%%%%%%%

% disp('normalizing...');
% X = imNormalize(X, 1);   % with zero mean and unit variance
% size(X)
% clear Feature_norm_data;

%%%%%%% CV process %%%%%%%%%%%
testBatchSize = 600;
n_iter = 10;
% tr_acc = zeros(1,n_iter);
ts_acc = zeros(1,n_iter);


for i = 1:n_iter
	XX = X;
	YY = Y;
	% test
	testX = X((i-1)*testBatchSize+1:i*testBatchSize,:);

	% disp('normalizing...');
	% testXnorm = imNormalize(testX, 1);   % with zero mean and unit variance
	% clear testX;

	testY = Y((i-1)*testBatchSize+1:i*testBatchSize,:);
	% train 
	XX((i-1)*testBatchSize+1:i*testBatchSize,:) = [];
	trainX = XX;

	% disp('normalizing...');
	% trainXnorm = imNormalize(trainX, 1);   % with zero mean and unit variance
	% clear trainX
	
	YY((i-1)*testBatchSize+1:i*testBatchSize,:) = [];
	trainY = YY;
	clear XX YY 

	% disp(['Element process with ' oper]);
	% % switch oper
	% % 	case 'mul'
	% % 		X = X(:,1:half).*X(:,half+1:end);
	% % 	% case 'minus'
	% % 	% 	X = abs(Feature_data1-Feature_data2);
	% % 	% case 'sqrt'
	% % 	% 	X = sqrt(abs(Feature_data1-Feature_data2));
	% % 	case 'sqdiff'
	% % 		X = (X(:,1:half)-Feature_data2).^2;
	% % end
	testXDiff = testX(:,1:half) - testX(:,half+1:end);
	testXC = testXDiff.^2;
	trainXC = (trainX(:,1:half) - trainX(:,half+1:end)).^2;

	clear trainX testX
	% normalize

	disp('normalizing...');
	trainXnorm = imNormalize(trainXC, 1);   % with zero mean and unit variance
	clear trainXC

	disp('normalizing...');
	testXnorm = imNormalize(testXC, 1);   % with zero mean and unit variance
	clear testXC

	switch classifier
		case 'Liblinear'
			%%%%%%%%% Liblinear SVM %%%%%%%%%%%%%%%%%%%%%
			addpath '/home/h1/pli/2_Packages/liblinear-1.93/matlab'
			disp(['training Liblinear ' num2str(i)]);
			libliner_command = ['-q -s ' num2str(svm_flag) ' -c ' num2str(C_reg) ' -B ' num2str(Bias)];
			model = {train(double(trainY),sparse(double(trainXnorm)),libliner_command)};
			disp('Liblinear trained! ');
			% [~, accs] = predict(double(trainY),sparse(double(trainXnorm)),model{1});
			% acc1 = accs(1);
			% fprintf('Train accuracy %f%%\n', acc1);
			% clear accs 
			clear trainXnorm
			weight = (model{1,1}.w);
			% below to calculate diag(weight)*testXDiff'
			tmp = zeros(size(testXDiff));
			for i = 1:half
    			tmp(:,i) = weight(i).*testXDiff(:,i);
			end
			tmp=tmp';
			% WMatrix = sparse(diag(weight.^2));

			distance = testXDiff*tmp;
			clear tmp testXDiff
			% score = trainY.*(Bias-distance) - 1;
			% tr_acc(i) = sum(score>0)./length(trainY);
			% fprintf('Train accuracy %f%%\n', tr_acc(i));


			score = (Bias-distance)*testY - 1;
			ts_acc(i) = sum(score>0)./length(testY);
			fprintf('Test accuracy %f%%\n', 100*ts_acc(i));
			% [~, accs] = predict(double(testY),sparse(double(testXnorm)),model{1});
			% acc2 = accs(1);
			% fprintf('Test accuracy %f%%\n', acc2);
			clear distance testY testXnorm
			% % tr_acc(i) = acc1;
			% ts_acc(i) = acc2;
		case 'RRC'
            [trainXnorm, testXnorm] = standard(trainXnorm, testXnorm);
            trainXnorm = [trainXnorm, single(ones(size(trainXnorm,1),1))];
            testXnorm = [testXnorm, single(ones(size(testXnorm,1),1))];
            [W, labels] = RRC(trainXnorm, trainY(:), lambda);
            fprintf('Train accuracy %f%%\n', 100 * (1 - sum(labels ~= trainY(:)) / length(trainY)));
            clear trainY trainXnorm
            [~,labels] = max(testXnorm*W, [], 2);
            ts_acc(i) = sum(labels == testY(:)) / length(testY);
    		fprintf('Test accuracy %f%%\n', ts_acc(i));

		case 'libSVM'
			addpath '/home/h1/pli/2_Packages/libsvm-3.17/matlab'
			% [trainXnorm, testXnorm] = standard(trainXnorm, testXnorm);
			disp(['training libSVM ' num2str(i)]);
			% libsvm dual
			% libsvmCommand = ['-q -t 0 -c ' num2str(C_reg)];
			% model = {svmtrain(double(trainY), double(trainXnorm), libsvmCommand)};
			% w = (model.sv_coef' * full(model.SVs));
			% train classifier using SVM
			theta = train_svm(trainXnorm, trainY, C_reg);
			WMatrix = diag(theta.^2);
			disp('LibSVM trained! ');


			disp('libSVM predicting...');
			size(testXDiff)
			size(WMatrix)

			distance = testXDiff*WMatrix*testXDiff';
			% score = trainY.*(Bias-distance) - 1;
			% tr_acc(i) = sum(score>0)/length(trainY);
			fprintf('Train accuracy %f%%\n', tr_acc(i));


			score = testY.*(Bias-distance) - 1;
			ts_acc(i) = sum(score>0)/length(testY);
			fprintf('Test accuracy %f%%\n', ts_acc(i));

			% [predicted_label, accs, decision_values] = svmpredict(double(testY), double(testXnorm), model{1}, libsvmCommand);
			% acc2 = accs(1);
			% fprintf('Test accuracy %f%%\n', acc2);
			% clear accs testY testXnorm
			% % tr_acc(i) = acc1;
			% ts_acc(i) = acc2;			
    end

	
end

% tr_acc_mean = mean(tr_acc);
% tr_acc_std = std(tr_acc);
ts_acc_mean = mean(ts_acc);
ts_acc_std = std(ts_acc);


disp('\n\n#############Final Results###################');
% fprintf('Mean Train accuracy : %f%% +- %f%%\n', tr_acc_mean, tr_acc_std);
fprintf('Mean Test accuracy : %f%% +- %f%%\n', ts_acc_mean, ts_acc_std);