function pooledImage = poolingFeatures(image,poolingRows, poolingCols, method)
%%%% output pooled image in 3D
mapRows = size(image,1);
mapCols = size(image,2);
maps = size(image,3);

rowsAfterPooling = round(mapRows/poolingRows);       
colsAfterPooling = round(mapCols/poolingCols);

pooledImage = zeros(rowsAfterPooling,colsAfterPooling,maps);

switch method
    case 'mean'
         parfor imap = 1:maps
             colImage = im2col(image(:,:,imap),[poolingRows,poolingCols],'distinct');
             pooled = mean(colImage,1);
             pooledImage(:,:,imap) = reshape(pooled,rowsAfterPooling,[]);
         end   
    case 'sum'
         parfor imap = 1:maps
             colImage = im2col(image(:,:,imap),[poolingRows,poolingCols],'distinct');
             pooled = sum(colImage,1);
             pooledImage(:,:,imap) = reshape(pooled,rowsAfterPooling,[]);
         end
end
end
