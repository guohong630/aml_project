function z = RR(patches, inv_D)

n_base= size(inv_D,1);
n_patch = size(patches,1);

% inv_D = (D*D' + lambda*eye(n_base))\D;

z = zeros(n_base,n_patch);

for i = 1 : n_patch
   pi = patches(i,:);
   z(:,i) = inv_D*pi';    
end

z = z';


end

