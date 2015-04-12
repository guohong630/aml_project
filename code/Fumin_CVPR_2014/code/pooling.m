% ========================================================================
% Pooling the llc codes to form the image feature
% USAGE: [beta] = LLC_pooling(feaSet, B, pyramid, knn)
% Inputs
%       feaSet      -the coordinated local descriptors
%       B           -the codebook for llc coding
%       pyramid     -the spatial pyramid structure
%       knn         -the number of neighbors for llc coding
% Outputs
%       beta        -the output image feature
%
% Written by Jianchao Yang @ IFP UIUC
% May, 2010
% ========================================================================

function [beta] = pooling(patches, prows, pcols, pyramid)



dSize = size(patches,2);
% spatial levels
pLevels = length(pyramid);
% spatial bins on each level
pBins = pyramid.^2;
% total spatial bins
tBins = sum(pBins);

beta = zeros(dSize, tBins);
bId = 0;

for iter1 = 1:pLevels,
    
    r = round(prows/4);
    c = round(pcols/4);
    q_t = [];
    for i_lev1 = 1 : 4
        for i_lev2 = 1 : 4
            r_bound = i_lev1*r;
            c_bound = i_lev2*c;
            if i_lev1 == 4, r_bound = prows;end
            if i_lev2 == 4, c_bound = pcols;end
            tem = sum(sum(patches(((i_lev1-1)*r+1):r_bound,...
                ((i_lev2-1)*c+1):c_bound,:),1),2);
            q_t = [q_t;tem(:)];
        end
    end
end

if bId ~= tBins,
    error('Index number error!');
end

beta = beta(:);
beta = beta./sqrt(sum(beta.^2));
