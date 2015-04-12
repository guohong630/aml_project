
dataset = 'AR';
data_DIR='../dataset/AR/data_AR_DIM_64.mat';

load(data_DIR);
fprintf([dataset ':\n']);

k = 10;

n_test = length(data_test.label);
t = zeros(n_test, 1);

lambda = 0.001;
pinv_A = (data_train.A'*data_train.A+lambda*eye(size(data_train.A,2)))\(data_train.A');

for i = 1 : n_test
    y = data_test.Y(:,i);
    t(i) = CRC_knn(data_train.label, y, k, pinv_A);
end

acc = sum(t == data_test.label) / n_test;
fprintf('Test accuracy %f%%\n', 100 * acc);    
