function [data_train, data_test] = datapre(database, Class_Train_NUM,  Class_Test_NUM, h)

% modified from P. Zhu's ECCV'12 code MSPCRC
%
% This function is used to get the traning and test data;
% you can add other databases in this function
% because of the copyright, please prepare the dataset by yourself;
% for MSPCRC, the training set is divided into two parts:Vali_DAT and Vali_DATT
%
% lfw.mat inlcudes: data: 32*32*1580  158 subjects 10 per subject bb is the random ranks
% h:  the random experiment index
% si: the number of samples per class in the training set


switch database
    case {'lfw','lfw_GradMag'}
        load(['../dataset/',database]);
        Image_row_NUM=32;Image_column_NUM=32;
        NN=Image_row_NUM*Image_column_NUM;                                                        
        Class_Test_NUM = 2;
        Class_NUM=158;
        Train_NUM=Class_NUM*Class_Train_NUM;
        Test_NUM=Class_NUM*Class_Test_NUM;
        
        data=reshape(data,[NN,10,Class_NUM]);
        Train_DAT=data(:,bb(h,1:Class_Train_NUM),:);
        Test_DAT=data(:,bb(h,9:10),:);
        
        A = reshape(Train_DAT, [1024, Class_Train_NUM*158]);
        label = 1:158;
        label = repmat(label, Class_Train_NUM,1);
        data_train.A = A;
        data_train.label = label(:);
        Y = reshape(Test_DAT, [1024, Class_Test_NUM*158]);
        label = 1:158;
        label = repmat(label, Class_Test_NUM,1);
        data_test.Y = Y;
        data_test.label = label(:);
        
    case 'YaleB'
        load ../dataset/YaleB/YaleB_dim32_32      
        A = []; Y = [];
        label_train = []; label_tst = [];
        
        for i = 1 : max(label)
            inx = find(label == i);
            rand('seed',h*1e3 + i);
            tem = randperm(length(inx));       
            inx_train = inx(tem(1:Class_Train_NUM));
            inx_tst = inx(tem(end-Class_Test_NUM+1:end));
            A = [A, data(:,inx_train)];
            Y = [Y, data(:, inx_tst)];
            label_train = [label_train; i*ones(length(inx_train),1)];
            label_tst = [label_tst; i*ones(length(inx_tst),1)];
        end
        
%         load ../dataset/data_YaleB      
%         A = []; Y = [];
%         label_train = []; label_tst = [];
%         
%         rand('seed',h);
%         for i = 1 : max(data_train.label)
%             inx = find(data_train.label == i);
%             tem = randperm(length(inx));       
%             inx_train = inx(tem(1:Class_Train_NUM));
%             A = [A, data_train.A(:,inx_train)];
%             label_train = [label_train; i*ones(Class_Train_NUM,1)];
%             
%             inx = find(data_test.label == i);
%             tem = randperm(length(inx)); 
%             inx_tst = inx(tem(1:Class_Test_NUM));         
%             Y = [Y, data_test.Y(:, inx_tst)];
%             label_tst = [label_tst; i*ones(Class_Test_NUM,1)];
%         end
        
        data_train.A = A;
        data_train.label = label_train;
        data_test.Y = Y;
        data_test.label = label_tst;
    case 'AR_GradMag'
        load ../dataset/AR/AR_GradMag;
        A = []; Y = [];
        label_train = []; label_tst = [];
        for i = 1 : max(data_train.label)
            inx = find(data_train.label == i);
            rand('seed',h*1e3 + i);
            tem = randperm(length(inx));       
            inx_train = inx(tem(1:Class_Train_NUM));
            A = [A, data_train.A(:,inx_train)];
            label_train = [label_train; i*ones(length(inx_train),1)];
            
            inx = find(data_test.label == i);
            rand('seed',h*1e5 + i);
            tem = randperm(length(inx)); 
            inx_tst = inx(tem(end-Class_Test_NUM+1:end));
            Y = [Y, data_test.Y(:, inx_tst)];    
            label_tst = [label_tst; i*ones(length(inx_tst),1)];
        end
        data_train.A = A;
        data_train.label = label_train;
        data_test.Y = Y;
        data_test.label = label_tst;
    case 'AR'
        load ../dataset/AR/data_AR;
        A = []; Y = [];
        label_train = []; label_tst = [];
        for i = 1 : max(data_train.label)
            inx = find(data_train.label == i);
            rand('seed',h*1e3 + i);
            tem = randperm(length(inx));       
            inx_train = inx(tem(1:Class_Train_NUM));
            A = [A, data_train.A(:,inx_train)];
            label_train = [label_train; i*ones(length(inx_train),1)];
            
            inx = find(data_test.label == i);
            rand('seed',h*1e5 + i);
            tem = randperm(length(inx)); 
            inx_tst = inx(tem(end-Class_Test_NUM+1:end));
            Y = [Y, data_test.Y(:, inx_tst)];    
            label_tst = [label_tst; i*ones(length(inx_tst),1)];
        end
        data_train.A = A;
        data_train.label = label_train;
        data_test.Y = Y;
        data_test.label = label_tst;
    case 'AR_LBP'
        load ../dataset/AR/AR_LBP;
        A = []; Y = [];
        label_train = []; label_tst = [];
        for i = 1 : max(data_train.label)
            inx = find(data_train.label == i);
            rand('seed',h*1e3 + i);
            tem = randperm(length(inx));       
            inx_train = inx(tem(1:Class_Train_NUM));
            A = [A, data_train.A(:,inx_train)];
            label_train = [label_train; i*ones(length(inx_train),1)];
            
            inx = find(data_test.label == i);
            rand('seed',h*1e5 + i);
            tem = randperm(length(inx)); 
            inx_tst = inx(tem(end-Class_Test_NUM+1:end));
            Y = [Y, data_test.Y(:, inx_tst)];    
            label_tst = [label_tst; i*ones(length(inx_tst),1)];
        end
        data_train.A = A;
        data_train.label = label_train;
        data_test.Y = Y;
        data_test.label = label_tst;
    case 'FERET_64'
        load ../dataset/data_FERET_DIM_64;
        A = []; Y = [];
        label_train = []; label_tst = [];
        
        for i = 1 : max(label)
            inx = find(label == i);
            rand('seed',h*1e3 + i);
            tem = randperm(length(inx));       
            inx_train = inx(tem(1:Class_Train_NUM));
            inx_tst = inx(tem(end-Class_Test_NUM+1:end));
            A = [A, data(:,inx_train)];
            Y = [Y, data(:, inx_tst)];
            label_train = [label_train; i*ones(length(inx_train),1)];
            label_tst = [label_tst; i*ones(length(inx_tst),1)];
        end
        data_train.A = A;
        data_train.label = label_train;
        data_test.Y = Y;
        data_test.label = label_tst;

   case 'FERET_32'
        load ../dataset/data_FERET_DIM_32;
        A = []; Y = [];
        label_train = []; label_tst = [];
        
        for i = 1 : max(label)
            inx = find(label == i);
            rand('seed',h*1e3 + i);
            tem = randperm(length(inx));       
            inx_train = inx(tem(1:Class_Train_NUM));
            inx_tst = inx(tem(end-Class_Test_NUM+1:end));
            A = [A, data(:,inx_train)];
            Y = [Y, data(:, inx_tst)];
            label_train = [label_train; i*ones(length(inx_train),1)];
            label_tst = [label_tst; i*ones(length(inx_tst),1)];
        end
        data_train.A = A;
        data_train.label = label_train;
        data_test.Y = Y;
        data_test.label = label_tst;
   case 'LFW_DIM_64'
        load ../dataset/LFW_158_DIM_64;
        A = []; Y = [];
        label_train = []; label_tst = [];
        
        for i = 1 : max(label)
            inx = find(label == i);
            rand('seed',h*1e3 + i);
            tem = randperm(length(inx));       
            inx_train = inx(tem(1:Class_Train_NUM));
            inx_tst = inx(tem(end-Class_Test_NUM+1:end));
            A = [A, data(:,inx_train)];
            Y = [Y, data(:, inx_tst)];
            label_train = [label_train; i*ones(length(inx_train),1)];
            label_tst = [label_tst; i*ones(length(inx_tst),1)];
        end
        data_train.A = A;
        data_train.label = label_train;
        data_test.Y = Y;
        data_test.label = label_tst;
    case 'FERET_LBP'
        load ../dataset/data_FERET_LBP_DIM_32;
        A = []; Y = [];
        label_train = []; label_tst = [];
        for i = 1 : max(label)
            inx = find(label == i);
            rand('seed',h*1e3 + i);
            tem = randperm(length(inx));       
            inx_train = inx(tem(1:Class_Train_NUM));
            inx_tst = inx(tem(end-Class_Test_NUM+1:end));
            A = [A, data(:,inx_train)];
            Y = [Y, data(:, inx_tst)];
            label_train = [label_train; i*ones(length(inx_train),1)];
            label_tst = [label_tst; i*ones(length(inx_tst),1)];
        end
        data_train.A = A;
        data_train.label = label_train;
        data_test.Y = Y;
        data_test.label = label_tst;
        
    case 'lfw_LBP'
        load ../dataset/lfw_LBP
        Image_row_NUM=30;Image_column_NUM=30;
        NN=Image_row_NUM*Image_column_NUM;                                                        
        Class_Test_NUM = 2;
        Class_NUM=158;
        Train_NUM=Class_NUM*Class_Train_NUM;
        Test_NUM=Class_NUM*Class_Test_NUM;
        
        data=reshape(data,[NN,10,Class_NUM]);
        Train_DAT=data(:,bb(h,1:Class_Train_NUM),:);
        Test_DAT=data(:,bb(h,9:10),:);
        
        A = reshape(Train_DAT, [900, Class_Train_NUM*158]);
        label = 1:158;
        label = repmat(label, Class_Train_NUM,1);
        data_train.A = A;
        data_train.label = label(:);
        Y = reshape(Test_DAT, [900, Class_Test_NUM*158]);
        label = 1:158;
        label = repmat(label, Class_Test_NUM,1);
        data_test.Y = Y;
        data_test.label = label(:);
        
        
end
