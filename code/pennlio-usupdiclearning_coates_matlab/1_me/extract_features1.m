function [X1F, Z1] = extract_features1(X, Dic, rfSize, CIFAR_DIM, M,P, encParam)
    numBase = size(Dic,1);
    numImage = size(X,1);
    numFeature = size(X,2);
    dim1 = CIFAR_DIM(1);
    dim2 = CIFAR_DIM(2);
    numBlkRow = dim1-rfSize+1;
    numBlkCol = dim2-rfSize+1;
    
    %%%%%%%%%%%% compute features for all training images

    %%%%%%%%%%%% pooling for Z1 %%%%%%%%%%%%%%% 
    poolingRows = 9;              % row size of pooling block
    poolingCols = 9;              % col size of pooling block
    rowsAfterPooling = round(numBlkRow/poolingRows);       
    colsAfterPooling = round(numBlkCol/poolingCols);
    Z1 = zeros(numImage,rowsAfterPooling,colsAfterPooling,numBase);
    
    %%%%%%%%%%%% pooling for X1F %%%%%%%%%%%%%%% 
    poolingRows2 = 14;              % row size of pooling block
    poolingCols2 = 14;              % col size of pooling block
    rowsAfterPooling2 = round(numBlkRow/poolingRows2);       
    colsAfterPooling2 = round(numBlkCol/poolingCols2);
    X1F = zeros(numImage,rowsAfterPooling2*colsAfterPooling2*numBase);
    
    %%%%%%%%%%%% divide into channels %%%%%%%%%%%%

    X1 = X(:, 1:numFeature/3);
    X2 = X(:,numFeature/3 + 1:numFeature * 2 / 3);
    X3 = X(:,numFeature * 2 / 3 + 1:end);
    clear X
    parfor i=1:numImage
        if (mod(i,100) == 0)
            fprintf('Extracting layer 1 features: %d / %d\n', i,numImage); 
        end
        
        %%%%%%%%%%%% extract overlapping sub-patches into rows of 'patches'
        patches = [ im2col(reshape(X1(i,:),[dim1 dim2]), [rfSize rfSize]) ;
                    im2col(reshape(X2(i,:),[dim1 dim2]), [rfSize rfSize]) ;
                    im2col(reshape(X3(i,:),[dim1 dim2]), [rfSize rfSize]) ]';

        %%%%%%%%%%%% do preprocessing for each patch
        
        % normalize for contrast
        patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
        % whiten
        patches = bsxfun(@minus, patches, M) * P;
    
        % compute activation
%         switch (encoder)
%          case 'thresh'
        alpha=encParam;
        patches = max(patches * Dic' - alpha, 0);
%          case 'sc'
%           lambda=encParam;
%           z = sparse_codes(patches, Dic, lambda);
%           patches = [ max(z, 0), -min(z, 0) ];
%          otherwise
%           error('Unknown encoder type.');
%         end

        patches = reshape(patches, numBlkRow, numBlkCol, numBase);
        
        % pooling for Z1
        Z1(i,:,:,:) = poolingFeatures(patches, poolingRows, poolingCols, 'mean');
        % pooling for X1F
        X1C = poolingFeatures(patches, poolingRows2, poolingCols2, 'mean');
        X1F(i,:) = X1C(:)';
    end
end

