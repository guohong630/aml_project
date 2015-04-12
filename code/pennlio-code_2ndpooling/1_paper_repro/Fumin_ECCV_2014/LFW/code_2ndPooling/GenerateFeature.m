DIM =[150, 150];
LFW_path = '../../dataset/lfw_funneled/';
addpath ./helpfun/ 

load ('../LFW_Eval.mat')
% load LFW_data_for_dict
% %% read training data
% % Load  data for dictionary learning
% fprintf('Loading data for dictionary learning...\n');
%
% fileID = fopen([LFW_path, 'pairsDevTrain.txt']);
% C = textscan(fileID, '%s %d %s %d');
% fclose(fileID);
% C{1}(1) = [];C{2}(1) = [];C{3}(1) = [];C{4}(1) = [];
% data_for_dict = [];
% for ix_name = 1 : 1100
%     str_name = C{1}{ix_name};
%     % first image
%     str_num = '0000'; tem = num2str(C{2}(ix_name));str_num(end-length(tem)+1:end) = tem;
%     img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%     % crop images to 121x121
%     img_crop = img(65:185, 65:185);
%     % downsampling
%     img_crop = imresize(double(img_crop), DIM);
%     data_for_dict = [data_for_dict, img_crop(:)];
%     % second image
%     str_num = '0000'; tem = num2str(C{3}{ix_name});str_num(end-length(tem)+1:end) = tem;
%     img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%     % crop images to 121x121
%     img_crop = img(65:185, 65:185);
%     % downsampling
%     img_crop = imresize(double(img_crop), DIM);
%     data_for_dict = [data_for_dict, img_crop(:)];
% end
% for ix_name = 1101 : 2200
%     % first person
%     str_name = C{1}{ix_name};
%     str_num = '0000'; tem = num2str(C{2}(ix_name));str_num(end-length(tem)+1:end) = tem;
%     img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%     % crop images to 121x121
%     img_crop = img(65:185, 65:185);
%     % downsampling
%     img_crop = imresize(double(img_crop), DIM);
%     data_for_dict = [data_for_dict, img_crop(:)];
%     % second person
%     str_name = C{3}{ix_name};
%     str_num = '0000'; tem = num2str(C{4}(ix_name));str_num(end-length(tem)+1:end) = tem;
%     img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%     % crop images to 121x121
%     img_crop = img(65:185, 65:185);
%     % downsampling
%     img_crop = imresize(double(img_crop), DIM);
%     data_for_dict = [data_for_dict, img_crop(:)];
% end
% 
% data_for_dict = data_for_dict';

% %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % load evaluation data
% fprintf('Loading data for evaluation...\n');
% fileID = fopen([LFW_path, 'pairs.txt']);
% C = textscan(fileID, '%s %d %s %d');
% fclose(fileID);
% C{1}(1) = [];C{2}(1) = [];C{3}(1) = [];C{4}(1) = [];
% 
% data1 = zeros(22500,6000);
% % first image
% for ix_name = 1:6000
%     str_name = C{1}{ix_name};
%     str_num = '0000'; tem = num2str(C{2}(ix_name));str_num(end-length(tem)+1:end) = tem;
%     img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%     % crop images to 150x150
%     img_crop = img(51:200, 51:200);
%     % downsampling
%     %img_crop = imresize(double(img_crop), DIM);
%     data1(:,ix_name) = img_crop(:);
% end
% disp('data2');
% data2 = zeros(22500,6000);
% % second image
% for ix_folder = 1:10
%     for ix_nm = 1:300
%         ix_name = (ix_folder-1)*600 + ix_nm;
%         str_name = C{1}{ix_name};
%         str_num = '0000'; tem = C{3}{ix_name};str_num(end-length(tem)+1:end) = tem;
%         img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%         % crop images to 150x150
%         img_crop = img(51:200, 51:200);
%         % downsampling
%         %img_crop = imresize(double(img_crop), DIM);
%         data2(:,(ix_folder-1)*600+ix_nm) = img_crop(:);         
%     end
%     tem2 = zeros(22500,300);
%     for ix_nm = 1:300
%         ix_name = (ix_folder-1)*600 + 300 + ix_nm;
%         str_name = C{3}{ix_name};
%         str_num = '0000'; tem = num2str(C{4}(ix_name));str_num(end-length(tem)+1:end) = tem;
%         img = imread([LFW_path  str_name '\' str_name '_' str_num '.jpg']);
%         % crop images to 150x150
%         img_crop = img(51:200, 51:200);
%         % downsampling
%         %img_crop = imresize(double(img_crop), DIM);
%         data2(:,(ix_folder-1)*600+ix_nm+300) = img_crop(:);  
%     end
%     
% end
% % data = [data1, data2];
% % idxa = 1:6000;
% % idxb = 6001:12000;
% label = repmat([ones(300,1);2*ones(300,1)],10,1);
% save('LFW_Eval', 'data1', 'data2','label','-v7.3');




%% dictionary training

rfSize = 6;
numBases = 20;

alpha = 0.25; 
knn = 5;
Pyramid = [1 1; 2 2; 4 4; 6 6; 8 8;];% 10 10; 12 12; 15 15;];%];%
alg = 'kmeans';
encoder='thresh'; encParam=alpha; %% Use soft threshold encoder.

numPatches = 50000;
patches = zeros(numPatches, rfSize*rfSize);

% load(['LFW_dictionary_' alg], 'dictionary', 'M', 'P');
for i=1:numPatches
    if (mod(i,10000) == 0) fprintf('Extracting patch: %d / %d\n', i, numPatches); end
    r = random('unid', DIM(1) - rfSize + 1);
    c = random('unid', DIM(2) - rfSize + 1);
    patch = reshape(data_for_dict(random('unid', size(data_for_dict,1)),:), DIM);
    patch = patch(r:r+rfSize-1,c:c+rfSize-1,:);
    patches(i,:) = patch(:)';
end

% normalize for contrast
patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));

% ZCA whitening (with low-pass)
C = cov(patches);
M = mean(patches);
[V,D] = eig(C);
P = V * diag(sqrt(1./(diag(D) + 0.1))) * V';
patches = bsxfun(@minus, patches, M) * P;

% run dictionary training
switch alg
    case 'patches'
        dictionary = patches(randsample(size(patches,1), numBases), :);
        dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)) + 1e-20);
    case 'kmeans'
        [~, dictionary] = litekmeans(patches, numBases,'MaxIter', 50);
        dictionary = bsxfun(@rdivide, dictionary, sqrt(sum(dictionary.^2,2)) + 1e-20);
end
save(['LFW_dictionary_' alg], 'dictionary', 'M', 'P');

%% extract features using second-order pooling

options = [];
options.rfSize = rfSize;
options.Pyramid = Pyramid;
options.DIM = DIM;
options.pooling = 'average';
options.M = M;
options.P = P;
options.encoder = encoder;
options.encParam =encParam;


Feature_data1 = extract_features_Encoding_2ndPooling(data1', dictionary, options);
Feature_data2 = extract_features_Encoding_2ndPooling(data2', dictionary, options);

%%%%%%%%%%%%ADD by Peng%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% save %%%%%%%%%%%%%%%%
d1seg1 = Feature_data1(1:2000,:);
save('d1seg1.mat','d1seg1')      
d1seg2 = Feature_data1(2001:4000,:);
save('d1seg2.mat','d1seg2')         
d1seg3 = Feature_data1(4001:6000,:);
save('d1seg3.mat','d1seg3')         
d2seg1 = Feature_data2(1:2000,:);   
save('d2seg1.mat','d2seg1')      
d2seg2 = Feature_data2(2001:4000,:);
save('d2seg2.mat','d2seg2') 
d2seg3 = Feature_data1(4001:6000,:);
save('d2seg3.mat','d2seg3') 

% Feature_data.data1 = Feature_data1;
% Feature_data.data2 = Feature_data2;
% save ('Feature_data.mat','-struct','Feature_data');


