% function kval = RBF(u,v,rbf_sigma,varargin)
% %RBF_KERNEL Radial basis function kernel for SVM functions
% 
% % Copyright 2004-2012 The MathWorks, Inc.
% % $Revision: 1.1.12.6 $  $Date: 2012/05/03 23:57:02 $
% 
%  
% if nargin < 3 || isempty(rbf_sigma)
%     rbf_sigma = 1;
% else
%      if ~isscalar(rbf_sigma) || ~isnumeric(rbf_sigma)
%         error(message('stats:rbf_kernel:RBFSigmaNotScalar'));
%     end
%     if rbf_sigma == 0
%         error(message('stats:rbf_kernel:SigmaZero'));
%     end
%     
% end
% 
% kval = zeros(size(u,1), size(v,1));
% 
% for i = 1 : size(u,1)
%     for j = 1 : size(v,1)
%         u_i = u(i,:);
%         v_j = v(j,:);
%         kval(i,j) = exp(-(1/(2*rbf_sigma^2))*(repmat(sqrt(sum(u_i.^2,2).^2),1,size(v_j,1))...
%             -2*(u_i*v_j')+repmat(sqrt(sum(v_j.^2,2)'.^2),size(u_i,1),1)));
%     end
% end
% 



function K = RBF(x1,sig,varargin)

%function K = rbf(x1,sig,x2)
%
% Computes an rbf kernel matrix from the input coordinates
%
%INPUTS
% x1 =  a matrix containing all samples as rows
% sig = sigma, the kernel width; squared distances are divided by
%       squared sig in the exponent
% x2 =  (optional) a matrix containing all samples as rows, to make a
% rectangular kernel
%
%OUTPUTS
% K = the rbf kernel matrix ( = exp(-1/(2*sigma^2)*(coord*coord')^2) )
%
%
% For more info, see www.kernel-methods.net

switch nargin
    case 2
        n=size(x1,1);
        K=repmat(diag(x1*x1')',n,1)+repmat(diag(x1*x1'),1,n)-2*(x1*x1');
    case 3
        x2=varargin{1};
        n=size(x1,1);
        n2=size(x2,1);
        K=repmat(diag(x2*x2')',n,1)+repmat(diag(x1*x1'),1,n2)-2*(x1*x2');
    otherwise
        disp 'error, wrong number of arguments to rbf function'
end
K=exp((-1/(2*sig^2))*K);

%Author: Tijl De Bie, february 2003. Adapted: october 2004 (for speedup),
%       Adapted again: Martin Kolar, on May 2012 (for unsquare kernels).