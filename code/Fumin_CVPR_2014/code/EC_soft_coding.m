function Coeff = EC_soft_coding(B, X, knn)

if ~exist('knn', 'var') || isempty(knn),
    knn = 5;
end
[label,distance] = Find_knn(B',X',knn);

% find k nearest neighbors
nframe = size(X,1);
nbase  = size(B,1);    
Coeff = zeros(nframe, nbase);

r = 10;
% knn

for i = 1:nframe,
	d = distance(:,i);
    idx = label(:,i);
	
    c = exp(-r*d);%/sum(exp(-r*distance(1:knn)))
    Coeff(i,idx) = c/sum(c);
    
end