function [data, label] = read_FERET(DIM)

path = 'F:\FACE_DATA\FERET_80\FERET_80\';
fprintf('----------------------------------\n Read data ... \n');



data = [];
label = [];

for i = 1 : 200
    for j = 1 : 7
        path_img = [ path 'ff' num2str(i) '_' num2str(j) '.tif'];
        img = imread( path_img , 'tif' ); img = double(img);
        img = imresize(img,DIM);
        data = [data, img(:)];
        label = [label;i];
    end
end

save(['../dataset/data_FERET_DIM_' num2str(DIM(1))], 'data', 'label', 'DIM');

end

