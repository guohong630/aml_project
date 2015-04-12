function [XP1, XP2, options] = extract_features_Encoding_2ndPooling_2layer(X,options)

rfSize1 = options.rfSize1;
DIM1 = options.DIM1;
numBases1 = options.numBases1;
Pyramid1 = options.Pyramid1;

rfSize2 = options.rfSize2;
DIM2 = Pyramid1;
numBases2 = options.numBases2;
Pyramid2 = options.Pyramid2;

%% first layer
disp('------------- Layer 1 --------------');
% ------------- Normalization and whitening --------------%
disp('Normalization and whitening...');
if isfield(options, 'dictionary1');
   dictionary1 = options.dictionary1;
   M = options.M1;
   P = options.P1;
else
    numPatches = 1000;
    patches = zeros(numPatches, rfSize1*rfSize1);
    for i=1:numPatches
        if (mod(i,10000) == 0) fprintf('Extracting patch: %d / %d\n', i, numPatches); end
        r = random('unid', DIM1(1) - rfSize1 + 1);
        c = random('unid', DIM1(2) - rfSize1 + 1);
        patch = reshape(X(random('unid', size(X,1)),:), DIM1);
        patch = patch(r:r+rfSize1-1,c:c+rfSize1-1,:);
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

    % -------------- dictionary training --------------------%
    disp('dictionary training...');
    switch options.alg
        case 'patches'
            dictionary1 = patches(randsample(size(patches,1), numBases1), :);
            dictionary1 = bsxfun(@rdivide, dictionary1, sqrt(sum(dictionary1.^2,2)) + 1e-20);
        case 'kmeans'
            [~, dictionary1] = litekmeans(patches, numBases1);
            dictionary1 = bsxfun(@rdivide, dictionary1, sqrt(sum(dictionary1.^2,2)) + 1e-20);
    end
    options.dictionary1 = dictionary1;
    options.M1 = M;
    options.P1 = P;
end


% -------------- encoding + pooling --------------------%
disp('encoding + pooling....');
if strcmp(options.encoder, 'triangle')
    [~, centroids] = litekmeans(patches, numBases,'MaxIter', 30);
    options.encParam = centroids;
end


if strcmp(options.encoder, 'VQ')
    dim_patch1 = numBases1;
else
    dim_patch1 = numBases1*2;
end
if strcmp(options.encoder, 'RR')
    delta = options.encParam;
    inv_D = (dictionary1*dictionary1' + delta*eye(size(dictionary1,1)))\dictionary1;
end


% compute features for all training images
dim_layer1 = dim_patch1*(dim_patch1+1)/2;
XP1 = zeros(size(X,1), Pyramid1(1), Pyramid1(2), dim_layer1);

for i=1:size(X,1)
    if (mod(i,100) == 0) fprintf('Extracting features: %d / %d\n', i, size(X,1)); end    
    % Encoding    
    % extract overlapping sub-patches into rows of 'patches'
    patches = [im2col(reshape(X(i,:),DIM1), [rfSize1 rfSize1])]';
    
    % normalize for contrast
    patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
    % whiten
    patches = bsxfun(@minus, patches, M) * P;
        
    switch (options.encoder)
        case 'thresh'
            alpha=options.encParam;
            z = patches * dictionary1';
            patches = [ max(z - alpha, 0), -max(-z - alpha, 0) ];
            clear z;
        case 'triangle'
            centroids = dictionary1;
            % compute 'triangle' activation function
            xx = sum(patches.^2, 2);
            cc = sum(centroids.^2, 2)';
            xc = patches * centroids';
            
            z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*xc)) ); % distances
            %                 [v,inds] = min(z,[],2);
            mu = mean(z, 2); % average distance to centroids for each patch
            patches = [max(bsxfun(@minus, mu, z), 0), -max(bsxfun(@minus, mu, -z), 0)];
            % patches is now the data matrix of activations for each patch
            pooling = 'max';
        case 'VQ' % hard assignment
            %                 centroids = encParam;
            % compute 'triangle' activation function
            xx = sum(patches.^2, 2);
            cc = sum(dictionary1.^2, 2)';
            xc = patches * dictionary1';
            
            z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*xc)) );
            [~,inds] = min(z,[],2);
            patches = sparse(1:size(patches,1),inds,1,size(z,1),size(z,2));
            patches = full(patches);
            pooling = 'max';
        case 'sc'
            lambda=encParam;
            z = sparse_codes(patches, dictionary1, lambda);
            patches = [ max(z, 0), -min(z, 0) ];
            pooling = 'max';
        case 'LLC'
            knn = 5;
            delta = encParam;
            z = LLC_coding_appr(dictionary1, patches, knn, delta);
            patches = [ max(z, 0), -min(z, 0) ];
            pooling = 'max';
            
        otherwise
            error('Unknown encoder type.');
    end
    % patches is now the data matrix of activations for each patch

    
    % pooling
    
    % reshape to 2*numBases-channel image
    prows = DIM1(1)-rfSize1+1;
    pcols = DIM1(2)-rfSize1+1;    
    patches = reshape(patches, prows, pcols, dim_patch1);
    
    offset = 0.001*eye(dim_patch1, dim_patch1);
    true_mat = true(dim_patch1,dim_patch1);
    in_triu = triu(true_mat);
    
    xp = [];
    
    nRow = Pyramid1(1);% num of pooling grid along the row dimension
    nCol = Pyramid1(2);% num of pooling grid along the column dimension
  
    
    r_bin = round(prows/nRow);% num of pathes in each bin along the row dimension
    if r_bin*(nRow-1) >= prows, r_bin = floor(prows/nRow);end
    c_bin = round(pcols/nCol);% num of pathes in each bin along the column dimension
    if c_bin*(nCol-1) >= pcols,c_bin = floor(pcols/nCol);end
    for ix_bin_r = 1:nRow
        for ix_bin_c = 1:nCol
            r_bound = ix_bin_r*r_bin; if ix_bin_r == nRow, r_bound = prows;end
            c_bound = ix_bin_c*c_bin; if ix_bin_c == nCol, c_bound = pcols;end
            switch options.pooling
                case 'max'
                    tem = max(max(patches(((ix_bin_r-1)*r_bin+1):r_bound,...
                        ((ix_bin_c-1)*c_bin+1):c_bound,:),[],1),[],2);
                    %                         % second-order pooling
                    %                         theD = patches(((ix_bin_r-1)*r_bin+1):r_bound,...
                    %                             ((ix_bin_c-1)*c_bin+1):c_bound,:);
                    %                         theD = reshape(theD, size(theD,1)*size(theD,2), size(theD,3))';
                    %                         temMatrix = [];
                    %                         for ixtem = 1:size(theD,2)
                    %                             tem = theD(:,ixtem)*theD(:,ixtem)';
                    %                             temMatrix = [temMatrix,tem(:)];
                    %                         end
                    %                         tem = reshape(max(temMatrix,[],2),size(theD,1),size(theD,1));
                    %                         tem = tem(in_triu);
                case 'average'
                    %                         % first-order pooling
                    %                         tem = patches(((ix_bin_r-1)*r_bin+1):r_bound,...
                    %                             ((ix_bin_c-1)*c_bin+1):c_bound,:);
                    %                         tem = (1/(size(tem,1)*size(tem,2))).*sum(sum(tem,1),2);
                    % second-order pooling
                    theD = patches(((ix_bin_r-1)*r_bin+1):r_bound,...
                        ((ix_bin_c-1)*c_bin+1):c_bound,:);
                    theD = reshape(theD, size(theD,1)*size(theD,2), size(theD,3))';
                    tem = real(logm(((1/size(theD,2)).*(theD *theD')) + offset));
                    %                         tem = real((((1/size(theD,2)).*(theD *theD')) + offset));
                    tem = tem(in_triu);
            end
            XP1(i,ix_bin_r, ix_bin_c, :) = tem(:);            
        end
    end
end

%% second layer
disp('------------- Layer 2 --------------');
% ------------- Normalization and whitening --------------%
disp('Normalization...');
if isfield(options, 'dictionary2');
   dictionary2 = options.dictionary2;
   M = options.M2;
   P = options.P2;
else
    numPatches = 1000;
    patches = zeros(numPatches, rfSize2*rfSize2*dim_layer1);
    for i=1:numPatches
        if (mod(i,10000) == 0) fprintf('Extracting patch: %d / %d\n', i, numPatches); end
        r = random('unid', DIM2(1) - rfSize2 + 1);
        c = random('unid', DIM2(2) - rfSize2 + 1);   
        patch = XP1(random('unid', size(XP1,1)),:,:,:);
        patch = patch(1,r:r+rfSize2-1,c:c+rfSize2-1,:);
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
    options.M2 = M;
    options.P2 = P;


    % -------------- dictionary training --------------------%
    disp('dictionary training...');
    switch options.alg
        case 'patches'
            dictionary2 = patches(randsample(size(patches,1), numBases2), :);
            dictionary2 = bsxfun(@rdivide, dictionary2, sqrt(sum(dictionary2.^2,2)) + 1e-20);
        case 'kmeans'
            [~, dictionary2] = litekmeans(patches, numBases2);
            dictionary2 = bsxfun(@rdivide, dictionary2, sqrt(sum(dictionary2.^2,2)) + 1e-20);
    end
    options.dictionary2 = dictionary2;
end

% -------------- encoding + pooling --------------------%
disp('encoding and pooling...');
if strcmp(options.encoder, 'triangle')
    [~, centroids] = litekmeans(patches, numBases,'MaxIter', 30);
    options.encParam2 = centroids;
end


if strcmp(options.encoder, 'VQ')
    dim_patch2 = numBases2;
else
    dim_patch2 = numBases2*2;
end
if strcmp(options.encoder, 'RR')
    delta = options.encParam;
    inv_D = (dictionary2*dictionary2' + delta*eye(size(dictionary2,1)))\dictionary2;
end


% compute features for all training images
XP2 = zeros(size(XP1,1), Pyramid2(:,1)'*Pyramid2(:,2)*dim_patch2*(dim_patch2+1)/2);

for i=1:size(XP1,1)
    if (mod(i,100) == 0) fprintf('Extracting features: %d / %d\n', i, size(XP1,1)); end            
    
    % extract overlapping sub-patches into rows of 'patches'
    patches = im2colstep(squeeze(XP1(i,:,:,:)), [rfSize2 rfSize2 dim_layer1], [1 1 1])';
    
    % normalize for contrast
    patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
    % whiten
    patches = bsxfun(@minus, patches, options.M2) * options.P2;
    
    % Encoding
    switch (options.encoder)
        case 'thresh'
            alpha=options.encParam;
            z = patches * dictionary2';
            patches = [ max(z - alpha, 0), -max(-z - alpha, 0) ];
            clear z;
        case 'triangle'
            centroids = dictionary2;
            % compute 'triangle' activation function
            xx = sum(patches.^2, 2);
            cc = sum(centroids.^2, 2)';
            xc = patches * centroids';
            
            z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*xc)) ); % distances
            %                 [v,inds] = min(z,[],2);
            mu = mean(z, 2); % average distance to centroids for each patch
            patches = [max(bsxfun(@minus, mu, z), 0), -max(bsxfun(@minus, mu, -z), 0)];
            % patches is now the data matrix of activations for each patch
            pooling = 'max';                    
        otherwise
            error('Unknown encoder type.');
    end
    % patches is now the data matrix of activations for each patch

    
    % pooling
    
    % reshape to 2*numBases-channel image
    prows = DIM2(1)-rfSize2+1;
    pcols = DIM2(2)-rfSize2+1;    
    patches = reshape(patches, prows, pcols, dim_patch2);
    
    offset = 0.001*eye(dim_patch2, dim_patch2);
    true_mat = true(dim_patch2,dim_patch2);
    in_triu = triu(true_mat);
    
    xp = [];
    for lev = 1 : size(Pyramid2,1)
        nRow = Pyramid2(lev,1);% num of pooling grid along the row dimension
        nCol = Pyramid2(lev,2);% num of pooling grid along the column dimension
        r_bin = round(prows/nRow);% num of pathes in each bin along the row dimension
        if r_bin*(nRow-1) >= prows, r_bin = floor(prows/nRow);end
        c_bin = round(pcols/nCol);% num of pathes in each bin along the column dimension
        if c_bin*(nCol-1) >= pcols,c_bin = floor(pcols/nCol);end
        for ix_bin_r = 1:nRow
            for ix_bin_c = 1:nCol
                r_bound = ix_bin_r*r_bin; if ix_bin_r == nRow, r_bound = prows;end
                c_bound = ix_bin_c*c_bin; if ix_bin_c == nCol, c_bound = pcols;end
                switch options.pooling
                    case 'max'
                        tem = max(max(patches(((ix_bin_r-1)*r_bin+1):r_bound,...
                            ((ix_bin_c-1)*c_bin+1):c_bound,:),[],1),[],2);
%                         % second-order pooling
%                         theD = patches(((ix_bin_r-1)*r_bin+1):r_bound,...
%                             ((ix_bin_c-1)*c_bin+1):c_bound,:);
%                         theD = reshape(theD, size(theD,1)*size(theD,2), size(theD,3))';
%                         temMatrix = [];
%                         for ixtem = 1:size(theD,2)
%                             tem = theD(:,ixtem)*theD(:,ixtem)';
%                             temMatrix = [temMatrix,tem(:)];
%                         end
%                         tem = reshape(max(temMatrix,[],2),size(theD,1),size(theD,1));
%                         tem = tem(in_triu);
                    case 'average'
%                         % first-order pooling
%                         tem = patches(((ix_bin_r-1)*r_bin+1):r_bound,...
%                             ((ix_bin_c-1)*c_bin+1):c_bound,:);
%                         tem = (1/(size(tem,1)*size(tem,2))).*sum(sum(tem,1),2);
                        % second-order pooling
                        theD = patches(((ix_bin_r-1)*r_bin+1):r_bound,...
                            ((ix_bin_c-1)*c_bin+1):c_bound,:);
                        theD = reshape(theD, size(theD,1)*size(theD,2), size(theD,3))';
                        tem = real(logm(((1/size(theD,2)).*(theD *theD')) + offset));
                        %                         tem = real((((1/size(theD,2)).*(theD *theD')) + offset));
                        tem = tem(in_triu);
                end
                xp = [xp, tem(:)'];
            end
        end
    end
    XP2(i,:) = xp;
end

XP1 = reshape(XP1, size(XP1,1),Pyramid1(1)*Pyramid1(2)*dim_layer1);








