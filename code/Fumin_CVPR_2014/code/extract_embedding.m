function XC = extract_embedding(X, dictionary, Embedding, options)

% Pyramid = [29 29];
Pyramid = [1 1;2 2; 4 4;6 6;8 8;10 10;12 12;14 14;29 29];
DIM = options.DIM;
rfSize = options.rfSize;
%% extract features
Dim_fea = (Pyramid(:,1)'*Pyramid(:,2))*options.ReducedDim*2;
XC = zeros(size(X,1),Dim_fea);
for i=1:size(X,1)
    if (mod(i,100) == 0) fprintf('Extracting features: %d / %d\n', i, size(X,1)); end    
    % extract overlapping sub-patches into rows of 'patches'
    patches = [im2col(reshape(X(i,:),DIM), [rfSize rfSize])]';
    % normalize for contrast
    patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
    % whiten
    patches = bsxfun(@minus, patches, options.M) * options.P;
    
    [Z,~, sigma] = get_Z(patches, dictionary, options.s, options.sigma);
    patches = Z*Embedding;
    patches = [ max(patches, 0), -min(patches, 0) ];
    %% pooling
    prows = DIM(1)-rfSize+1;
    pcols = DIM(2)-rfSize+1;
    patches = reshape(patches, prows, pcols, options.ReducedDim*2);
    switch options.pooling
        case 'average'
            XCi = [];
            for lev = 1 : size(Pyramid,1);
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
            XCi = [];
            for lev = 1 : size(Pyramid,1);
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



end