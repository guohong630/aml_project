function PatchArr = extractPatch(I, gridX, gridY, patchSize)

num_patches = numel(gridX);
dim_patch = patchSize*patchSize;

PatchArr = zeros(num_patches, dim_patch);

for i=1:num_patches
	% find window of pixels that contributes to this descriptor
    x_lo = gridX(i);
    x_hi = gridX(i) + patchSize - 1;
    y_lo = gridY(i);
    y_hi = gridY(i) + patchSize - 1;
    tem = I(x_lo:x_hi, y_lo:y_hi);
    PatchArr(i,:) = tem(:)';
end