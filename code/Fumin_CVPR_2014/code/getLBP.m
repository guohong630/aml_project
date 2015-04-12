

% % LFW
% dataset = '../dataset/lfw';
% load(dataset);
% 
% dataNew = zeros(30,30,length(label));
% for i = 1 : length(label)
%     tem = data(:,:,i);
%     dataNew(:,:,i) = lbp(tem, 1, 8);
% end
% data = dataNew;
% save lfw_LBP data label bb


% % AR
% dataset = '../dataset/AR/data_AR';
% load(dataset);
% 
% dataNew = zeros(900,length(data_train.label));
% for i = 1 : length(data_train.label)
%     tem1 = reshape(data_train.A(:,i), [32 32]);
%     tem2 = lbp(tem1, 1, 8);
%     dataNew(:,i) = tem2(:);
% end
% data_train.A = dataNew;
% 
% 
% dataNew = zeros(900,length(data_test.label));
% for i = 1 : length(data_test.label)
%     tem1 = reshape(data_test.Y(:,i), [32 32]);
%     tem2 = lbp(tem1, 1, 8);
%     dataNew(:,i) = tem2(:);
% end
% data_test.Y = dataNew;
% 
% save ../dataset/AR/AR_LBP data_train data_test 

% FERET
dataset = '../dataset/data_FERET_DIM_32';
load(dataset);
dataNew = zeros(900,length(label));
for i = 1 : length(label)
    tem1 = reshape(data(:,i),[32,32]);
    tem2 = lbp(tem1, 1, 8);
    dataNew(:,i) = tem2(:);
end
data = dataNew;
save ../dataset/data_FERET_LBP_DIM_32 data label