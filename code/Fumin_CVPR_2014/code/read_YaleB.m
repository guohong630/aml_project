function [data_train, data_test] = read_YaleB(dim,rand_seed)
% dim: downsampled to dim



data_name = ['YaleB_dim' num2str(dim(1)),'_', num2str(dim(2)), '.mat'];
if exist(data_name,'file')
    load(data_name, 'data','label');
else
    
    path = 'F:\FACE_DATA\CroppedYale\yaleB';
    fprintf('----------------------------------\n Read data ... \n');
    
    
    num = [1:9]';
    str = num2str(num);
    str = [num2str(zeros(9,1)) , str];
    num = [10:39]';
    str = [str;num2str(num)];
    str(14,:) = []; % the 14th subject doesn't exist.
    
    files = {'A+000E+00.pgm'
        'A+000E+20.pgm'
        'A+000E+45.pgm'
        'A+000E+90.pgm'
        'A+000E-20.pgm'
        'A+000E-35.pgm'
        'A+005E+10.pgm'
        'A+005E-10.pgm'
        'A+010E+00.pgm'
        'A+010E-20.pgm'
        'A+015E+20.pgm'
        'A+020E+10.pgm'
        'A+020E-10.pgm'
        'A+020E-40.pgm'
        'A+025E+00.pgm'
        'A+035E+15.pgm'
        'A+035E+40.pgm'
        'A+035E+65.pgm'
        'A+035E-20.pgm'
        'A+050E+00.pgm'
        'A+050E-40.pgm'
        'A+060E+20.pgm'
        'A+060E-20.pgm'
        'A+070E+00.pgm'
        'A+070E+45.pgm'
        'A+070E-35.pgm'
        'A+085E+20.pgm'
        'A+085E-20.pgm'
        'A+095E+00.pgm'
        'A+110E+15.pgm'
        'A+110E+40.pgm'
        'A+110E+65.pgm'
        'A+110E-20.pgm'
        'A+120E+00.pgm'
        'A+130E+20.pgm'
        'A-005E+10.pgm'
        'A-005E-10.pgm'
        'A-010E+00.pgm'
        'A-010E-20.pgm'
        'A-015E+20.pgm'
        'A-020E+10.pgm'
        'A-020E-10.pgm'
        'A-020E-40.pgm'
        'A-025E+00.pgm'
        'A-035E+15.pgm'
        'A-035E+40.pgm'
        'A-035E+65.pgm'
        'A-035E-20.pgm'
        'A-050E+00.pgm'
        'A-050E-40.pgm'
        'A-060E+20.pgm'
        'A-060E-20.pgm'
        'A-070E+00.pgm'
        'A-070E+45.pgm'
        'A-070E-35.pgm'
        'A-085E+20.pgm'
        'A-085E-20.pgm'
        'A-095E+00.pgm'
        'A-110E+15.pgm'
        'A-110E+40.pgm'
        'A-110E+65.pgm'
        'A-110E-20.pgm'
        'A-120E+00.pgm'
        'A-130E+20.pgm'};
    
    subset1 = { 'A+000E+00.pgm'; 'A-010E+00.pgm'; 'A+010E+00.pgm'; 'A-005E+10.pgm';
        'A+005E+10.pgm'; 'A-005E-10.pgm'; 'A+005E-10.pgm'};
    subset2 = { 'A+000E-20.pgm'; 'A-010E-20.pgm'; 'A+020E-10.pgm'; 'A-025E+00.pgm';
        'A-015E+20.pgm'; 'A-020E-10.pgm'; 'A+000E+20.pgm'; 'A+010E-20.pgm';
        'A+020E+10.pgm'; 'A+025E+00.pgm'; 'A+015E+20.pgm'; 'A-020E+10.pgm' };
    subset3 = { 'A+000E-35.pgm'; 'A-035E+15.pgm'; 'A-035E-20.pgm'; 'A-020E-40.pgm';
        'A-035E+40.pgm'; 'A-050E+00.pgm'; 'A+000E+45.pgm'; 'A+035E+15.pgm';
        'A+035E-20.pgm'; 'A+020E-40.pgm'; 'A+035E+40.pgm'; 'A+050E+00.pgm' };
    subset4 = {'A-050E-40.pgm'; 'A+060E-20.pgm'; 'A-060E-20.pgm'; 'A-035E+65.pgm';
        'A-070E+00.pgm'; 'A-070E-35.pgm'; 'A-070E+45.pgm'; 'A+050E-40.pgm';
        'A+060E+20.pgm'; 'A-060E+20.pgm'; 'A+035E+65.pgm'; 'A+070E+00.pgm';
        'A+070E-35.pgm'; 'A+070E+45.pgm'};
    subset5 = setxor(files,subset1);
    subset5 = setxor(subset5,subset2);
    subset5 = setxor(subset5,subset3);
    subset5 = setxor(subset5,subset4);
    
    badfiles = {'yaleB11_P00A-050E-40.pgm';
        'yaleB11_P00A-110E+15.pgm';
        'yaleB11_P00A+050E-40.pgm';
        'yaleB11_P00A+095E+00.pgm';
        'yaleB12_P00A-050E-40.pgm';
        'yaleB12_P00A-110E-20.pgm';
        'yaleB12_P00A-110E+15.pgm';
        'yaleB12_P00A+050E-40.pgm';
        'yaleB12_P00A+095E+00.pgm';
        'yaleB13_P00A-050E-40.pgm';
        'yaleB13_P00A-110E+15.pgm';
        'yaleB13_P00A+050E-40.pgm';
        'yaleB13_P00A+095E+00.pgm';
        'yaleB15_P00A-035E+40.pgm';
        'yaleB16_P00A-010E+00.pgm';
        'yaleB16_P00A+095E+00.pgm'
        'yaleB17_P00A-010E+00.pgm';
        'yaleB18_P00A-010E+00.pgm';
        'yaleB34_P00A+095E+00.pgm';};
    
    
    
    data = [];
    label = [];
    for i = 1 : 38
        sub_path = [path str(i,:) '\'];
        for j = 1 : length(files)
            img_file_name = ['yaleB' str(i,:) '_P00' files{j}];
            %detect if img_path is a bad file
            if ismember(img_file_name ,badfiles)
                continue;
            end
            img_path = [sub_path img_file_name];
            img = imread(img_path, 'pgm');
            img = double(img);
            img = imresize(img, dim,'nearest');
            data = [data, img(:)];
            label = [label;i];
        end
    end
save(data_name, 'data', 'label');
end

%%%%%%%  get random training data and test data %%%%%%%%%%%%%%%

rand('seed',rand_seed);
n_each_train = 32;
data_train.A = []; data_test.Y = []; data_train.label = []; data_test.label = [];
for i = 1 : 38
    tem_data = data(:,label ==i);
    inx = randperm(size(tem_data,2));
%     inx = 1 : size(tem_data,2);
    data_train.A = [data_train.A, tem_data(:,inx(1:n_each_train))];
    data_train.label = [data_train.label; i * ones(n_each_train,1)];
    
    data_test.Y = [data_test.Y,tem_data(:,inx(n_each_train+1:end))];
    data_test.label = [data_test.label; i * ones(length(inx(n_each_train+1:end)), 1)];
end

save data_Yale data_train data_test

end