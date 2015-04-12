function [W, labels] = RRC(tr_dat, tr_labels, lambda)

%projection matrix computing
if size(tr_dat,1) < size(tr_dat,2)
    Proj_M = tr_dat'/(tr_dat*tr_dat'+lambda*eye(length(tr_labels)));
else
    Proj_M = (tr_dat'*tr_dat+lambda*eye(size(tr_dat,2)))\tr_dat';
end
Y = sparse([1:length(tr_labels)], double(tr_labels), 1); Y = full(Y);
W = Proj_M * Y;
%-------------------------------------------------------------------------
%testing
[~,labels] = max(tr_dat*W, [], 2);

end


% function [acc, W] = RRC(Z, tst_labels, X, tr_labels, lambda, kernel)
% % each row of X and Z is a sample
% % Z: test data, X: training data
% 
% Y = sparse([1:length(tr_labels)], double(tr_labels), 1); Y = full(Y);
% 
% switch kernel
%     case 'lin'
%         KX = X*X';
%         KZ = X*Z';
%     case 'rbf'
%         n1sq = sum(X.^2,2);
%         n1 = size(X,1);
%         DX = n1sq * ones(1,n1) + (n1sq * ones(1,n1))' -2*X*X';
%         
%         n2sq = sum(Z.^2,2);
%         n2 = size(Z,1);
%         DZ = n1sq * ones(1,n2) + ones(n1,1)*n2sq' - 2*X*Z';
%         
%         
%         sigma = mean(abs(DX(:)));  
%         
%         KX = exp(-DX/(2*sigma));
%         KZ = exp(-DZ/(2*sigma));
%     case 'poly'
%         b = 1;
%         d = 3;
%         KX = (X*X' + b).^d;
%         KZ = (X*Z' + b).^d;
% end
% %projection matrix computing
% W = (KX +lambda*eye(length(tr_labels))) \ Y;
% %-------------------------------------------------------------------------
% %testing
% [~,labels] = max(KZ'*W, [], 2);
% acc = sum(labels == tst_labels) / length(tst_labels);
% 
% end


% function [acc, W] = RRC(Z, tst_labels, X, tr_labels, lambda, kernel)
% 
% m = max(tr_labels);
% T = zeros(m-1, m);
% T(1,:) = [1; zeros(m-1,1)];
% T(1,2:m) = -1/(m-1);
% for k = 1 : m-2
%     T(k+1, k+1) = sqrt(1 - sum(T(1:k,k+1).^2));
%     for j = k+2 : m
%         T(k+1,j) = - T(k+1, k+1)/(m-k-1);
%     end
% end
% Y = zeros(m-1,length(tr_labels));
% for i = 1 : m
%     Y(:, i) = T(:,tr_labels(i));
% end
% 
% 
% 
% KX = X*X';
% KZ = X*Z';
% 
% % n1sq = sum(X.^2,2);
% % n1 = size(X,1);
% % DX = n1sq * ones(1,n1) + (n1sq * ones(1,n1))' -2*X*X';
% % 
% % n2sq = sum(Z.^2,2);
% % n2 = size(Z,1);
% % DZ = n1sq * ones(1,n2) + ones(n1,1)*n2sq' - 2*X*Z';
% % 
% % 
% % sigma = mean(abs(DX(:)));
% % 
% % KX = exp(-DX/(2*sigma));
% % KZ = exp(-DZ/(2*sigma));
% 
% 
% A = inv(KX +lambda*eye(length(tr_labels))) * Y';
% WZ = KZ'*A;
% 
% labels = knnclassify(WZ, T', 1:m,1);
% acc = sum(labels == tst_labels) / length(tst_labels);
% 
% end





% options = [];
% options.sigma = 0;
% [KX, sigma] = kernelmatrix(kernel,X',options);
% options.sigma = sigma;
% options.X2 = Z';
% KZ = kernelmatrix(kernel,X',options);

