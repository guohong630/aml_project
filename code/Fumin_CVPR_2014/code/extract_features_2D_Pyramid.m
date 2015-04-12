function XC = extract_features_2D_Pyramid(X, D, rfSize, DIM, M,P, encoder, encParam)
    numBases = size(D,1);
    
    if strcmp(encoder, 'RR')
        delta = encParam;
        inv_D = (D*D' + delta*eye(size(D,1)))\D;
    end
    
    
    Pyramid = [1 1;2 2; 4 4; 6 6; 8 8;];
%     Pyramid = [1 1;2 2; 3 3;  5 5; 7 7; 9 9];
    
    % compute features for all training images
    
    XC = zeros(size(X,1), numBases*2*(Pyramid(:,1)'*Pyramid(:,2)));
    for i=1:size(X,1)
        if (mod(i,100) == 0) 
            fprintf('Extracting features: %d / %d\n', i, size(X,1)); 
        end
        
        % extract overlapping sub-patches into rows of 'patches'
        patches = im2col(reshape(X(i,:),DIM), [rfSize rfSize])';

        % do preprocessing for each patch
        
        % normalize for contrast
        patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
        % whiten
        patches = bsxfun(@minus, patches, M) * P;
        
             
        
        
        % compute activation
        switch (encoder)
         case 'thresh'
          alpha=encParam;
%           z = patches * D';
          patches = [ max(patches * D' - alpha, 0), -max(- patches * D' - alpha, 0) ];
%           clear z;
          pooling = 'max';
          case 'triangle'
              centroids = encParam;
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
         case 'sc'
          lambda=encParam;
          z = sparse_codes(patches, D, lambda);
          patches = [ max(z, 0), -min(z, 0) ];
          pooling = 'max';
         case 'LLC'
          knn = encParam;
          z = LLC_coding_appr(D, patches, knn); 
          patches = [ max(z, 0), -min(z, 0) ];
          pooling = 'max';
          
         case 'thresh_max_pool'
          alpha = encParam;
%           z = patches * D';
          patches = [ max(patches * D' - alpha, 0), -max(- patches * D' - alpha, 0) ];
%           clear z;
          pooling = 'max'; 
         case 'sc_max_pool'
          lambda=encParam;
          z = sparse_codes(patches, D, lambda);
          patches = [ max(z, 0), -min(z, 0) ];
          pooling = 'max';
         case 'LLC_max_pool'
          knn = encParam;
          z = LLC_coding_appr(D, patches, knn); 
          patches = [ max(z, 0), -min(z, 0) ];
          pooling = 'max';
         case 'LSC'
             knn = encParam;
             z = EC_soft_coding(D, patches, knn);
             patches = [ max(z, 0), -min(z, 0) ];
             pooling = 'max';
         case 'RR'
             z = RR(patches, inv_D);
             patches = [ max(z, 0), -min(z, 0) ];
             pooling = 'max';
         otherwise
                error('Unknown encoder type.');
        end
        % patches is now the data matrix of activations for each patch
        
       
        % reshape to 2*numBases-channel image
        prows = DIM(1)-rfSize+1;
        pcols = DIM(2)-rfSize+1;
        patches = reshape(patches, prows, pcols, numBases*2);
        switch pooling
            case 'average'
                %% 1st layer pooling
                q0 = sum(sum(patches, 1), 2);
                XCi = q0(:)';

                for lev = 2 : size(Pyramid,1);
                    nRow = Pyramid(lev,1);
                    nCol = Pyramid(lev,2);
                    r_bin = round(prows/nRow);
                    c_bin = round(pcols/nCol);
                    q_tem = [];
                    for i_lev1 = 1 : nRow
                        for i_lev2 = 1 : nCol
                            r_bound = i_lev1*r_bin;
                            c_bound = i_lev2*c_bin;
                            if i_lev1 == nRow, r_bound = prows;end
                            if i_lev2 == nCol, c_bound = pcols;end
                            tem = sum(sum(patches(((i_lev1-1)*r_bin+1):r_bound,...
                                ((i_lev2-1)*c_bin+1):c_bound,:),1),2);
                            q_tem = [q_tem;tem(:)];
                        end
                    end
                    XCi = [XCi, q_tem'];
                end
                
            case 'max'
                %% 1st layer pooling
                q0 = max(max(patches, [], 1),[], 2);
                XCi = q0(:)';

                for lev = 2 : size(Pyramid,1);
                    nRow = Pyramid(lev,1);
                    nCol = Pyramid(lev,2);
                    r_bin = round(prows/nRow);
                    c_bin = round(pcols/nCol);
                    q_tem = [];
                    for i_lev1 = 1 : nRow
                        for i_lev2 = 1 : nCol
                            r_bound = i_lev1*r_bin;
                            c_bound = i_lev2*c_bin;
                            if i_lev1 == nRow, r_bound = prows;end
                            if i_lev2 == nCol, c_bound = pcols;end
                            tem = max(max(patches(((i_lev1-1)*r_bin+1):r_bound,...
                                ((i_lev2-1)*c_bin+1):c_bound,:),[],1),[],2);
                            q_tem = [q_tem;tem(:)];
                        end
                    end
                    XCi = [XCi, q_tem'];
                end
        end
        XC(i,:) = XCi;

    end
    
    

