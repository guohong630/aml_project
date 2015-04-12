
path_data = '../../dataset/pubfig83';

subjects = dir(path_data);
subjects(1:2) = [];


data = [];
label = [];
for i = 1:length(subjects)
    name = subjects(i).name;
    imgs = dir([path_data '/' name]);
    imgs(1:2) = [];
    
    for j = 1:length(imgs)
        img = imread([path_data '/' name '/' imgs(j).name]);
        img = rgb2gray(img);
        data = [data, img(:)];
        label = [label; i];
    end
    
end

save PubFig83 data label