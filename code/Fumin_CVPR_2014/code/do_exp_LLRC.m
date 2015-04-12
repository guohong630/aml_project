
dataset = 'AR';
data_DIR='../dataset/AR/data_AR_DIM_64.mat';

load(data_DIR);
fprintf([dataset ':\n']);

k = 700;

n_test = length(data_test.label);
t = zeros(n_test, 1);


for i = 1 : n_test
    y = data_test.Y(:,i);
    t(i) = LLRC(data_train.A, data_train.label, y, k);
end

acc = sum(t == data_test.label) / n_test;
fprintf('Test accuracy %f%%\n', 100 * acc);    
