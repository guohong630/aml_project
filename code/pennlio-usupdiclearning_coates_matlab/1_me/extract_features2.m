function X2C = extract_features2(Z1, dictionary, X2order, rfSize,...
    M,P,poolingCols,poolingRows,encoder, encParam)
%%% For every patch in each image within image set Z1, encode with D and 
%%% convert output into a vector and store in matrix X2C (pooling is optional)
    numBase2 = size(dictionary,1);
    
    numImage = size(Z1,1);    
    numImgRow = size(Z1,2);
    numImgCol = size(Z1,3);
    
    numBlkRow = numImgRow-rfSize+1;
    numBlkCol = numImgCol-rfSize+1;
    
    if (poolingCols||poolingRows)     % with  pooling        
        rowsAfterPooling = round(numBlkRow/poolingRows);       
        colsAfterPooling = round(numBlkCol/poolingCols);
        X2C = zeros(numImage, rowsAfterPooling*colsAfterPooling*numBase2);
    else
        X2C = zeros(numImage, numBlkCol*numBlkRow*numBase2);
    end
    
    parfor i=1:numImage
        if (mod(i,100) == 0)
            fprintf('Extracting layer 2 features: %d / %d\n', i,numImage); 
        end
        %%% generate patches       
        patches = images2Mtrx (Z1(i,:,:,:),rfSize);  
        
        %%%% select features %%%%%
        patches = patches(:,X2order);
        
        %%%% do preprocessing for each patch

        % normalize for contrast
        patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
        % whiten
        patches = bsxfun(@minus, patches, M) * P;
    
        % compute activation
        switch (encoder)
         case 'thresh'
          alpha=encParam;
          patches = max(patches * dictionary' - alpha, 0);
         case 'sc'
          lambda=encParam;
          z = sparse_codes(patches, dictionary, lambda);
          patches = [ max(z, 0), -min(z, 0) ];
         otherwise
          error('Unknown encoder type.');
        end
        if (poolingCols||poolingRows)
           patches = reshape(patches, numBlkCol, numBlkRow, numBase2);
           pooledImage = poolingFeatures(patches, poolingRows, poolingCols, 'mean');        
           X2C(i,:) = pooledImage(:)';
        else
           X2C(i,:) = patches(:)'; %% same with the process in layer extraction1
        end
      
    end
end

