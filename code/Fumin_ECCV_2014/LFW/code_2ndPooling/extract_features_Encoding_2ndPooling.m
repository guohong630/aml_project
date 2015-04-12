function XC = extract_features_Encoding_2ndPooling(X, D, options)

numBases = size(D,1);
rfSize = options.rfSize;
DIM = options.DIM;

if strcmp(options.encoder, 'VQ')
    dim_patch = numBases;
else
    dim_patch = numBases*2;
end
if strcmp(options.encoder, 'RR')
    delta = options.encParam;
    inv_D = (D*D' + delta*eye(size(D,1)))\D;
end


% compute features for all training images
if isfield(options, 'ReducedDim')
    dim_patch = options.ReducedDim;
end
XC = zeros(size(X,1), options.Pyramid(:,1)'*options.Pyramid(:,2)*dim_patch*(dim_patch+1)/2);

for i=1:size(X,1)
    if (mod(i,100) == 0) fprintf('Extracting features: %d / %d\n', i, size(X,1)); end
    
    %% Encoding
    % extract overlapping sub-patches into rows of 'patches'
    patches = [im2col(reshape(X(i,:),DIM), [rfSize rfSize])]';
    
    % normalize for contrast
    patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
    % whiten
    patches = bsxfun(@minus, patches, options.M) * options.P;
        
    switch (options.encoder)
        case 'thresh'
            alpha=options.encParam;
            z = patches * D';
            patches = [ max(z - alpha, 0), -max(-z - alpha, 0) ];
            clear z;
        case 'triangle'
            centroids = D;
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
            cc = sum(D.^2, 2)';
            xc = patches * D';
            
            z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*xc)) );
            [~,inds] = min(z,[],2);
            patches = sparse(1:size(patches,1),inds,1,size(z,1),size(z,2));
            patches = full(patches);
            pooling = 'max';
        case 'sc'
            lambda=encParam;
            z = sparse_codes(patches, D, lambda);
            patches = [ max(z, 0), -min(z, 0) ];
            pooling = 'max';
        case 'LLC'
            knn = 5;
            delta = encParam;
            z = LLC_coding_appr(D, patches, knn, delta);
            patches = [ max(z, 0), -min(z, 0) ];
            pooling = 'max';
            
        otherwise
            error('Unknown encoder type.');
    end
    % patches is now the data matrix of activations for each patch

    
    %% pooling
    if isfield(options, 'ReducedDim')
        patches = patches*options.eigvector;
        dim_patch = options.ReducedDim;
    end
    
    % reshape to 2*numBases-channel image
    prows = DIM(1)-rfSize+1;
    pcols = DIM(2)-rfSize+1;    
    patches = reshape(patches, prows, pcols, dim_patch);
        
    
    offset = 0.001*eye(dim_patch, dim_patch);
    true_mat = true(dim_patch,dim_patch);
    in_triu = triu(true_mat);
    
    xp = [];
    for lev = 1:size(options.Pyramid,1)
        nRow = options.Pyramid(lev,1);% num of pooling grid along the row dimension
        nCol = options.Pyramid(lev,2);% num of pooling grid along the column dimension
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
                xp = [xp,tem(:)'];
            end
        end
    end
    
    XC(i,:) = xp;
    
end



