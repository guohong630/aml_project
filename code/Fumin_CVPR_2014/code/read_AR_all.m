function [data_train, data_test] = read_AR_all(DIM)

    path = 'F:\FACE_DATA\AR database\AR_CROPPED_GREY\';
    fprintf('----------------------------------\n Read data ... \n');
    
    A = [];
    Y = [];
    L_trn = [];
    L_tst = [];
    
    for i = 1 : 100
    
        % SETIINGS same as in SRC Paper
        % read training data
        for j = 1 : 13
            path_img = [path num2str(i) '\' num2str(j) '.bmp'];
            img = imread( path_img , 'bmp' ); img = double(img);
            img = imresize(img,DIM,'nearest');
            A = [A, img(:)]; 
            L_trn = [L_trn;i];
        end   
        % read test data
        for j = 14 : 26
            path_img = [path num2str(i) '\' num2str(j) '.bmp'];
            img = imread( path_img , 'bmp' ); img = double(img);
            img = imresize(img,DIM,'nearest');
            Y = [Y, img(:)];
            L_tst = [L_tst; i];    
        end
    
    end
    
    data_train.A = A; data_test.Y = Y; data_train.label = L_trn; data_test.label = L_tst;
    save(['../dataset/AR/data_AR_ALL_DIM_' num2str(DIM(1))], 'data_train', 'data_test', 'DIM');
end
