
DIM = [32,32];
LFW_path = 'F:\FACE_DATA\lfw2\';
list = dir(LFW_path);
isfd = [list(:).isdir];
folderName = {list(isfd).name}';
folderName(ismember(folderName,{'.','..'})) = [];

data = []; label = []; id = 0;
%% crop images to 150x130
for i = 1 : length(folderName)
    subName = folderName{i};
    sub_path = [LFW_path subName '\'];
    list = dir(sub_path);
    isimg = ~[list(:).isdir];
    imagesName = {list(isimg).name}';
    if length(imagesName) < 10
        continue;% only use subjects containing more than ten samples
    end
    id = id + 1;
    for j = 1 : length(imagesName)
       img = imread([sub_path imagesName{j}]);
       img_crop = img(63:184, 63:184); 
       img_crop = imresize(double(img_crop), DIM);
       data = [data, img_crop(:)];

    end   
    label = [label; id*ones(length(imagesName),1)];
end

save(['../dataset/LFW_158_DIM_' num2str(DIM(1))], 'data', 'label');

% load save(['LFW_158_DIM_' num2str(DIM(1))], 'data', 'label');

%% split for training and testing
A = []; Y = [];
label_train = []; label_tst = [];
for i = 1 : max(label)
    inx = find(label == i);
    tem = randperm(length(inx));
    sz_train = 5;
    inx_train = inx(tem(1:sz_train));
    inx_tst = inx(tem(end-1:end));
    A = [A, data(:,inx_train)];
    Y = [Y, data(:, inx_tst)];
    label_train = [label_train; i*ones(length(inx_train),1)];
    label_tst = [label_tst; i*ones(length(inx_tst),1)];
end

data_train.A = A;
data_train.label = label_train;
data_test.Y = Y;
data_test.label = label_tst;

save(['../dataset/LFW_158_DIM_' num2str(DIM(1)) '_split'], 'data_train', 'data_test');












%% packing
% for i = 1 : length(folderName)
%     subName = folderName{i};
%     sub_path = [LFW_path subName '\'];
%     list = dir(sub_path);
%     isimg = ~[list(:).isdir];
%     imagesName = {list(isimg).name}';
%     imagesName(strfind(imagesName, '.mat')
%     for j = 1 : length(imagesName)
%        img = imread([sub_path imagesName{j}]);
%        img_crop = img(51:200, 61:190);
%        save([sub_path imagesName{j} '.mat'], 'img_crop');
%        imwrite(img_crop,[sub_path imagesName{j} '_crop.jpg'])
%     end   
% end