DIM = [150, 150];
LFW_path = '../../dataset/lfw_funneled/';
list = dir(LFW_path);
isfd = [list(:).isdir];
folderName = {list(isfd).name}';
folderName(ismember(folderName,{'.','..'})) = [];

data = []; label = []; id = 0;

for i = 1 : length(folderName)
    i
    subName = folderName{i};
    sub_path = [LFW_path subName '\'];
    list = dir(sub_path);
    isimg = ~[list(:).isdir];
    imagesName = {list(isimg).name}';
    id = id + 1;
    for j = 1 : length(imagesName)
       img = imread([sub_path imagesName{j}]);
       % crop images to 121x121
       img_crop = img(51:200, 51:200); 
       % downsampling
       %img_crop = imresize(double(img_crop), DIM);
       data = [data, img_crop(:)];

    end   
    label = [label; id*ones(length(imagesName),1)];
end

save(['../dataset/LFW_ALL_DIM_' num2str(DIM(1))], 'data', 'label');