
clear

% LFW
dataset = '../dataset/lfw';
load(dataset);

dataNew = zeros(32,32,length(label));
for i = 1 : length(label)
    tem = data(:,:,i);
    %gaussian smoothing
    h = fspecial('gaussian', [4 4], 1);
    IR = imfilter(tem,h);
    dataNew(:,:,i) = imgradient(IR);
end
data = dataNew;
save lfw_GradMag data label bb



clear
% AR
dataset = '../dataset/AR/data_AR';
load(dataset);

dataNew = zeros(1024,length(data_train.label));
for i = 1 : length(data_train.label)
    tem1 = reshape(data_train.A(:,i), [32 32]);
    %gaussian smoothing
    h = fspecial('gaussian', [4 4], 1);
    IR = imfilter(tem1,h);
    tem2 = imgradient(IR);
    dataNew(:,i) = tem2(:);
end
data_train.A = dataNew;


dataNew = zeros(1024,length(data_test.label));
for i = 1 : length(data_test.label)
    tem1 = reshape(data_test.Y(:,i), [32 32]);
    h = fspecial('gaussian', [4 4], 1);
    IR = imfilter(tem1,h);
    tem2 = imgradient(IR);
    dataNew(:,i) = tem2(:);
end
data_test.Y = dataNew;

save ../dataset/AR/AR_GradMag data_train data_test 