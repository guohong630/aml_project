close all
clear

addpath D:\work\package\l1benchmark\L1Solvers
addpath(genpath('D:\work\Face_Rec\RSC\l1_ls_matlab\'));
addpath(genpath('D:\work\Classification\FDDL\'));

% dataset = 'lfw';
% data_DIR = '../dataset/LFW_158_split.mat';

dataset = 'YaleB';
data_DIR='../dataset/YaleB/data_YaleB.mat';
%
% dataset = 'AR';
% data_DIR='../dataset/AR/data_AR.mat';
% 
% dataset = 'AR_ALL';
% data_DIR='../dataset/AR/data_AR_all.mat';





load(data_DIR,'data_train','data_test');

% [data_train, data_test] = datapre(dataset, 5,  2, 1);

n_class = max(data_train.label);
n_test = length(data_test.label);

% normalize to have unit l2 norm
data_train.A = normalize(data_train.A);
data_test.Y = normalize(data_test.Y);

% alg  = 'FDDL_SRC';
% display(alg);
% acc = FDDL_SRC(data_train, data_test);
% save(['./res_new/acc_' dataset '_FDDL_SRC'], 'acc');
% fprintf('Test accuracy %f%%\n', 100 * acc);


method = 'CRC_R';
display(method);
lambda = 0.001 * length(data_train.label) / 700;
pinv_A = (data_train.A'*data_train.A +...
         lambda*eye(length(data_train.label)))\(data_train.A');
Rep_train = pinv_A*data_train.A;
Rep_test = pinv_A*data_test.Y;
% classification
W = RRC(Rep_train', data_train.label, 100);
[val,labels] = max(Rep_test'*W, [], 2);
acc = sum(labels == data_test.label) / length(data_test.label);
fprintf('Test accuracy %f%%\n', 100 * acc);



method_set = {'RSC','LRC','CRC','SRC'};

for ix_method = 3 : 3%length(method_set)
    alg  = method_set{ix_method};
    display(alg);
    
    if strcmp(alg,'CRC')
        lambda = 0.001 * length(data_train.label) / 700;
        pinv_A = (data_train.A'*data_train.A +...
            lambda*eye(length(data_train.label)))\(data_train.A');
    end
    if strcmp(alg,'SRC')
        lambda = 0.001;
    end
    
    
    
    labels = [];
    for i= 1:n_test
        y = data_test.Y(:,i);
        res = [];
        switch alg
            case 'SRC'
                tolerance = 1e-6;
                isNonnegative = false;
                [alph, ~] = SolveHomotopy(data_train.A, y, ...
                    'isNonnegative', isNonnegative, ...
                    'lambda', lambda/2, ...%see SolveHomotopy
                    'tolerance', tolerance);
                for j = 1: n_class
                    id = (data_train.label == j);
                    alph_j = alph .* id;
                    res(j) = norm(y - data_train.A * alph_j);
                end
                [~, I] = min(res);
                labels(i) = I;
            case 'CRC'
                alph = pinv_A*y;
                for j = 1 : n_class
                    id = (data_train.label == j);
                    alph_j = alph .* id;
                    % res(j) = norm(y - A * alph_j) / norm(alph_j);
                    res(j) = norm(y - data_train.A * alph_j);
                end
                [~, I] = min(res);
                labels(i) = I;
            case 'LRC'
                alph = [];
                for j = 1 : n_class
                    id = (data_train.label == j);
                    A_j = data_train.A(:,id);
                    %beta_j = ( A_j' * A_j) \ A_j' * y;
                    alph_j = ( A_j' * A_j + 1e-8 * eye(size(A_j,2))) \ A_j' * y;
                    res(j) = norm( y - A_j * alph_j );
                end
                [~, I] = min(res);
                labels(i) = I;
            case 'RSC'
                labels(i) = RSC(data_train.A, data_train.label, y);
                
                
        end
        clear alph alph_j
        
        
    end
    acc = sum(labels == data_test.label') / length(data_test.label);
    save(['./res_new/acc_' dataset '_' alg], 'acc');
    fprintf('Test accuracy %f%%\n', 100 * acc);
end
