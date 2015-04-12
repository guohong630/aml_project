function XC = extract_features_2D_2layer(X, D, rfSize, DIM, M,P, encoder, encParam)
    numBases = size(D,1);
    
    % compute features for all training images
    XC = zeros(size(X,1), numBases*2*4);
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
          
         case 'thresh_max_pool'
          alpha=encParam;
          z = patches * D';
          patches = [ max(z - alpha, 0), -max(-z - alpha, 0) ];
          clear z;
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

