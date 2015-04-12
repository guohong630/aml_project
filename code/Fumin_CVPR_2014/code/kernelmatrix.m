function [K, sigma] = kernelmatrix(ker,X,options)
% With Fast Computation of the RBF kernel matrix
% To speed up the computation, we exploit a decomposition of the Euclidean distance (norm)
%
% Inputs:
%       ker:    'lin','poly','rbf','sam'
%       X:      data matrix with training samples in rows and features in columns
%       X2:     data matrix with test samples in rows and features in columns
%       sigma: width of the RBF kernel
%       b:     bias in the linear and polinomial kernel
%       d:     degree in the polynomial kernel
%
% Output:
%       K: kernel matrix
%
% Gustavo Camps-Valls
% 2006(c)
% Jordi (jordi@uv.es), 2007
% 2007-11: if/then -> switch, and fixed RBF kernel


switch ker
    case 'lin'
        if isfield(options, 'X2')
            X2 = options.X2;
            K = X' * X2;
        else
            K = X' * X;
        end

    case 'poly'
        if isfield(options, 'X2')
            X2 = options.X2;
            K = (X' * X2 + b).^d;
        else
            K = (X' * X + b).^d;
        end

    case 'rbf'

        n1sq = sum(X.^2,1);
        n1 = size(X,2);

        if isfield(options, 'X2')
            X2 = options.X2;
            n2sq = sum(X2.^2,1);
            n2 = size(X2,2);
            D = (ones(n2,1)*n1sq)' + ones(n1,1)*n2sq -2*X'*X2;
        else
            D = (ones(n1,1)*n1sq)' + ones(n1,1)*n1sq -2*X'*X;
            
        end;
        sigma = options.sigma;
        if sigma == 0
           sigma = mean(abs(D(:)));  
        end
        K = exp(-D/(2*sigma)); %%%% ATENTION for sigma not in square here!!!!!!

    case 'sam'
        if isfield(options, 'X2')
            X2 = options.X2;
            D = X'*X2;
        else
            D = X'*X;
        end
        sigma = options.sigma;
        if sigma == 0
           sigma = mean(sqrt(abs(D(:))));  
        end
        K = exp(-acos(D).^2/(2*sigma^2));

    otherwise
        error(['Unsupported kernel ' ker])
end