function Z1RN = slice_normZ1(Z1)
numImages = size(Z1,1);
numBases = size(Z1,4);
dim = size(Z1,2);

Z1RN = zeros(numImages, 2*2*numBases);
parfor ii = 1:numImages
%%%%% select random 2*2 spatial regions from Z1 %%%%
%     disp('selecting spatial region...')
    region = randi(dim-1,1,2);
    slice1 = Z1(ii,region(1):region(1)+1,region(2):region(2)+1,:);
    slice1 = reshape(slice1,1,[]);             % 4d to vector
    slice1 = (slice1 - mean(slice1,2)) ./ std(slice1);      % normalize xk(xj)
    Z1RN(ii,:) = slice1;
        
end

end