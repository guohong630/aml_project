function [xp] =  extract_feature_2ndPooling(x, options)
% x: image as a vector of dimension DIM(1)*DIM(2) or a matrix with dim of DIM
% options: params for pooling
% example:
%     options.rfSize = 6;
%     options.DIM = [96 96];
%     options.ReducedDim = 10;
%     options.Pyramid = [1 1;2 2; 4 4; 6 6; 8 8; 10 10; 12 12; 15 15;];
%     options.pooling = 'max';
% xp1: output vector of the first pooling layer

% params for 1st layer
if length(x) > 1
    DIM = options.DIM;
    rfSize = options.rfSize; % patch size
    prows = DIM(1)-rfSize+1;
    pcols = DIM(2)-rfSize+1;
    patches = im2col(reshape(x,DIM), [rfSize rfSize])';
elseif isstruct(x)
    patches = x.feaArr';
    prows = length(unique(x.y));
    pcols = length(unique(x.x));    
end
dim_patch = options.ReducedDim;


% pre-processing
% normalize for contrast
patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
% PCA
if isfield(options, 'ReducedDim')
    patches = patches*options.eigvector;
end
% % fliping
% patches = [ max(patches, 0), -min(patches, 0) ];
% dim_patch = dim_patch*2;

% first layer pooling. Only use 1 level pooling grid
patches = reshape(patches, prows, pcols, dim_patch);

offset = 0.001*eye(dim_patch, dim_patch);
true_mat = true(dim_patch,dim_patch);
in_triu = triu(true_mat);
% output of layer1
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
%                     % second-order pooling
%                     theD = patches(((ix_bin_r-1)*r_bin+1):r_bound,...
%                         ((ix_bin_c-1)*c_bin+1):c_bound,:);
%                     theD = reshape(theD, size(theD,1)*size(theD,2), size(theD,3))';
%                     temMatrix = [];
%                     for ixtem = 1:size(theD,2)
%                         tem = theD(:,ixtem)*theD(:,ixtem)';
%                         temMatrix = [temMatrix,tem(:)];
%                     end
%                     tem = reshape(max(temMatrix,[],2),size(theD,1),size(theD,1)); 
%                     tem = tem(in_triu);
                case 'average'
%                     % first-order pooling
%                     tem = patches(((ix_bin_r-1)*r_bin+1):r_bound,...
%                         ((ix_bin_c-1)*c_bin+1):c_bound,:);
%                     tem = (1/(size(tem,1)*size(tem,2))).*sum(sum(tem,1),2);
                    % second-order pooling
                    theD = patches(((ix_bin_r-1)*r_bin+1):r_bound,...
                        ((ix_bin_c-1)*c_bin+1):c_bound,:);
                    theD = reshape(theD, size(theD,1)*size(theD,2), size(theD,3))';
                    tem = real(logm(((1/size(theD,2)).*(theD *theD')) + offset));
                    tem = tem(in_triu);
            end
            xp = [xp,tem(:)'];
        end
    end
end


end