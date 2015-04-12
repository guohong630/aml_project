function XC = extract_features_2D(X, D, rfSize, DIM, M,P, encoder, encParam)
    numBases = size(D,1);
    
    
    if strcmp(encoder, 'RR')
        delta = encParam;
        inv_D = (D*D' + delta*eye(size(D,1)))\D;
    end
    

    
    % compute features for all training images
    XC = zeros(size(X,1), numBases*4*2);
    for i=1:size(X,1)
        if (mod(i,100) == 0) fprintf('Extracting features: %d / %d\n', i, size(X,1)); end
        
        % extract overlapping sub-patches into rows of 'patches'
        patches = [im2col(reshape(X(i,:),DIM), [rfSize rfSize])]';

        % do preprocessing for each patch
        
        % normalize for contrast
        patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
        % whiten
        patches = bsxfun(@minus, patches, M) * P;
    
        % compute activation
        switch (encoder)
         case 'thresh'
          alpha=encParam;
          z = patches * D';
          patches = [ max(z - alpha, 0), -max(-z - alpha, 0) ];
          clear z;
          pooling = 'average';
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
              pooling = 'average';  
         case 'sc'
          lambda=encParam;
          z = sparse_codes(patches, D, lambda);
          patches = [ max(z, 0), -min(z, 0) ];
          pooling = 'average';
         case 'LLC'
          knn = encParam;
          z = LLC_coding_appr(D, patches, knn); 
          patches = [ max(z, 0), -min(z, 0) ];
          pooling = 'average';

         case 'LSC'
             knn = encParam;
             z = EC_soft_coding(D, patches, knn);
             patches = [ max(z, 0), -min(z, 0) ];
             pooling = 'max';
         case 'RR'
             z = RR(patches, inv_D);
             patches = [ max(z, 0), -min(z, 0) ];
             pooling = 'average';
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
                %% average/sum pooling over quadrants
                halfr = round(prows/2);
                halfc = round(pcols/2);
                q1 = sum(sum(patches(1:halfr, 1:halfc, :), 1),2);
                q2 = sum(sum(patches(halfr+1:end, 1:halfc, :), 1),2);
                q3 = sum(sum(patches(1:halfr, halfc+1:end, :), 1),2);
                q4 = sum(sum(patches(halfr+1:end, halfc+1:end, :), 1),2);
                
                % concatenate into feature vector
                XC(i,:) = [q1(:);q2(:);q3(:);q4(:)]';
%                 XC(i,:) = [q1(:)]';
            case 'max'
                halfr = round(prows/2);
                halfc = round(pcols/2);
                q1 = max(max(patches(1:halfr, 1:halfc, :), [], 1),[], 2);
                q2 = max(max(patches(halfr+1:end, 1:halfc, :), [],1),[],2);
                q3 = max(max(patches(1:halfr, halfc+1:end, :), [],1),[],2);
                q4 = max(max(patches(halfr+1:end, halfc+1:end, :), [],1),[],2);
                
                % concatenate into feature vector
                 XC(i,:) = [q1(:);q2(:);q3(:);q4(:)]';
%                  XC(i,:) = min([q1(:),q2(:),q3(:),q4(:)])';

        end
        
           

    end

