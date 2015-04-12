function [trainX, trainY, testX, testY] = data_aug(trainX, trainY, testX, testY, DIM_Ori, DIM_Dst)


% for training data
sz_trn = size(trainX,1);
X = trainX; trainX = [];
Y = trainY; trainY = [];
for i=1:sz_trn
    patches = [im2col(reshape(X(i,:),DIM_Ori), DIM_Dst)]';
    trainX = [trainX; patches];
    trainY = [trainY; Y(i)*ones(size(patches,1),1)];
end


% for testing data
sz_tst = size(testX,1);
X = testX; testX = [];
Y = testY; testY = [];
for i=1:sz_tst
%     patches = [im2col(reshape(X(i,:),DIM_Ori), DIM_Dst)]';
    patches = [];
    img = reshape(X(i,:),DIM_Ori); 
    tem = img(1:DIM_Dst(1),1:DIM_Dst(2));
    patches = [patches;tem(:)'];
    tem = img(1:DIM_Dst(1),DIM_Ori-DIM_Dst(2)+1:DIM_Ori(2));
    patches = [patches;tem(:)'];
    tem = img(DIM_Ori(1)-DIM_Dst(1)+1:DIM_Ori(1),1:DIM_Dst(2));
    patches = [patches;tem(:)'];
    tem = img(DIM_Ori(1)-DIM_Dst(1)+1:DIM_Ori,DIM_Ori(2)-DIM_Dst(2)+1:DIM_Ori(2));
    patches = [patches;tem(:)'];
    slide = 2;
    tem = img(slide:DIM_Dst(1)+slide-1,slide:DIM_Dst(2)+slide-1);
    patches = [patches;tem(:)'];
    
    testX = [testX; patches];
    testY = [testY; Y(i)*ones(size(patches,1),1)];
end




end