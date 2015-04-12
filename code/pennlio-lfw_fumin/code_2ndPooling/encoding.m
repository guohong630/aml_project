function [patches] = encoding(patches, D, options)

if strcmp(options.encoder, 'RR')
    delta = options.encParam;
    inv_D = (D*D' + delta*eye(size(D,1)))\D;
end

% normalize for contrast
patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
% whiten
patches = bsxfun(@minus, patches, options.M) * options.P;

% Encoding
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



end