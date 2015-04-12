function S = compPairSimi(numRF,k1,Xj,Xk)

S = zeros(numRF,k1);
alpha = zeros(numRF,k1);

% compute alpha, beta and gamma
parfor jj = 1:numRF
    xj = Xj(:,jj);
    for kk = 1:k1               
        xk = Xk(:,kk);        
        cor_matirx = corrcoef(xj, xk);      % compute alpha_jk
        alpha(jj,kk) = cor_matirx(2,1);
    end

end

beta = (1 - alpha).^(-1/2);
gamma = (1 + alpha).^(-1/2);

clear alpha

GB1 = beta + gamma;
GB2 = gamma - beta;

clear beta gamma
% Xj_h = zeros(size(Xj));
% Xk_h = zeros(size(z1));

% Pair-Wise Whitening and Compute S
parfor jj = 1:numRF
    xj = Xj(:,jj);  
    xj_h = 0.5 .* ( repmat(xj,1,k1) * diag(GB1(jj,:))  + Xk * diag(GB2(jj,:)));
    xk_h = 0.5 .* ( repmat(xj,1,k1) * diag(GB2(jj,:))  + Xk * diag(GB1(jj,:)));
    
    for ki = 1:k1     
        up = (xj_h(:,ki).^(2))' * (xk_h(:,ki).^(2)) - 1;
        down = sqrt( ((xj_h(:,ki).^2-1)'*(xj_h(:,ki).^2+1)) * ((xk_h(:,ki).^2-1)'*(xk_h(:,ki).^2+1)) );
        S(jj,ki) = up/down;
    end

end

clear GB1 GB2
end