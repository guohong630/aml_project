function t = CRC_knn(label, y, k, pinv_A)



dis = pinv_A * y;

[~, I] = sort(dis, 'descend');

[t,v] = majority(label(I(1:k))');

end