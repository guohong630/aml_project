clear all;
% Generate lables
data_DIR = '/home/h1/pli/3_Dataset/CroppedYale/matImg_data/';
MODEL = 'fc3';
% clf = 'r';	% ridge
clf = 's'; % svm

data_path = fullfile(data_DIR, MODEL);
n_iter = 5;

tr_acc = zeros(1,n_iter);
ts_acc = zeros(1,n_iter);


for iter = 1:n_iter

	disp('Start importing data ...')

	subf = dir(data_path);
	trx_path = [];
	tsx_path = [];
	trainY = [];
	testY = [];
	ylable = 1;
	for i=1:length(subf)
		if (strcmp(subf(i).name, '.')  || strcmp(subf(i).name, '..')) % skip .. and . folder
	    	continue
	  	end
	  	disp(['processing ' subf(i).name])
	    folder_path = fullfile(data_path, subf(i).name);
	    imgfile = dir(folder_path);
	    len = length(imgfile)-2; % git ride of . and .. folder
	    tmp = [];
	    for j=1:length(imgfile)
		    if (strcmp(imgfile(j).name, '.')  || strcmp(imgfile(j).name, '..')) % skip .. and . folder
		    	continue
		  	end
		  	imgfile_path = fullfile(folder_path, imgfile(j).name);
		  	tmp = cat(1,tmp, imgfile_path);
	    end
	    a = randperm(len);
	    trx_temp_path = tmp(a(1:10),:);
	    trx_path = cat(1,trx_path,trx_temp_path);
	    try_temp = ones(1,10)*ylable;

	    tsx_temp_path = tmp(a(11:15),:);
	    tsx_path = cat(1,tsx_path,tsx_temp_path);
	    tsy_temp = ones(1,5)*ylable;

	    trainY = cat(2,trainY, try_temp);
		testY = cat(2,testY, tsy_temp);

	    ylable = ylable + 1;

	end
	trainXC = load_mat_yaleb(trx_path);
	testXC = load_mat_yaleb(tsx_path);


	trainY = trainY';
	testY = testY';

	%  Start training SVM

	disp('Finish importing data!')

	% standardize data
	trainXC_mean = mean(trainXC);
	trainXC_sd = sqrt(var(trainXC)+0.01);
	trainXCs = bsxfun(@rdivide, bsxfun(@minus, trainXC, trainXC_mean), trainXC_sd);
	clear trainXC;
	trainXCs = [trainXCs, ones(size(trainXCs,1),1)]; % intercept term

	%  test set
	testXCs = bsxfun(@rdivide, bsxfun(@minus, testXC, trainXC_mean), trainXC_sd);
	clear testXC;
	testXCs = [testXCs, ones(size(testXCs,1),1)];
	    

	if clf == 'r'
		%%%%%%%%% ridge regression classifier %%%%%%%%%%%%%%%%%%%%%
		disp('Training Ridge regression');
		[W, labels] = RRC(trainXCs, trainY(:), 0.03);
		acc1 = (1 - sum(labels ~= trainY(:)) / length(trainY));
		fprintf('Train accuracy %f%%\n', 100 * acc1);
		[val,labels] = max(testXCs*W, [], 2);
		acc2 = sum(labels == testY(:)) / length(testY);
		fprintf('Test accuracy %f%%\n', 100 * acc2);

	elseif clf == 's'
		%%%%%%%%%% Liblinear SVM %%%%%%%%%%%%%%%%%%%%%
		disp('Training SVM');
		addpath '/home/h1/pli/2_Packages/liblinear-1.93/matlab'
		% size(trainXCs)
		% size(trainY)
		C_reg = 10;
		svm_flag = 3;
		command = ['-q -s ' num2str(svm_flag) ' -c ' num2str(C_reg)];
		model = {train(double(trainY),sparse(double(trainXCs)), command)};
		% model = {train(double(trainY),sparse(double(trainXCs)),'-q -s 3 -c 10')};

		[~, accs] = predict(double(trainY),sparse(double(trainXCs)),model{1});
		acc1 = accs(1);
		fprintf('Train accuracy %f%%\n', acc1);
		clear accs;
		[~, accs] = predict(double(testY),sparse(double(testXCs)),model{1});
		acc2 = accs(1);
		fprintf('Test accuracy %f%%\n', acc2);
	end
	tr_acc(iter) = acc1;
	ts_acc(iter) = acc2;
end
tr_acc_mean = mean(tr_acc);
ts_acc_mean = mean(ts_acc);

tr_acc_std = std(tr_acc);
ts_acc_std = std(ts_acc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp('\n\n#############Final Results###################');
fprintf('Mean Train accuracy : %f%% +- %f%%\n', tr_acc_mean, tr_acc_std);
fprintf('Mean Test accuracy : %f%% +- %f%%\n', ts_acc_mean, ts_acc_std);
