function t = LLRC(data, label, y, k)

[idx, d] = knnsearch(data', y', 'k', k);

dataNew = data(:,idx);
labelNew = label(idx);

lambda = 0.001;
pinv_A = (dataNew'*dataNew+lambda*eye(size(dataNew,2)))\(dataNew');
coef = pinv_A * y;

labelUnique = unique(labelNew);
res = [];
for c = 1 : length(labelUnique)
    coef_c = coef(labelNew == labelUnique(c));
    data_c = dataNew(:,labelNew == labelUnique(c));
    res(c) = norm(y - data_c*coef_c);
end

[~, I] = min(res);
t = labelUnique(I);