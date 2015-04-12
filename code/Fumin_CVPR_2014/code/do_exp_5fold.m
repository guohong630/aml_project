close all
clear
clc

addpath D:\work\package\l1benchmark\L1Solvers
addpath(genpath('D:\work\Face_Rec\RSC\l1_ls_matlab\'));
addpath(genpath('D:\work\Classification\FDDL\'));

dataset = 'FERET';
fprintf([dataset ':\n']);
num_run = 5;


num_test = 2;

DIM=[32 32];



method_set = {'CRC','SRC','RSC','FDDL_SRC'};

for ix_method = 3 : 4%length(method_set)
    alg  = method_set{ix_method};
    display(alg);
    for num_train = 5
        fprintf(['num_train: ', num2str(num_train), '\n']);
        for run = 1 : num_run
            fprintf(['run: ', num2str(run), '\n']);
            [data_train, data_test] = datapre(dataset, num_train, num_test,run);
            
            if strcmp(alg, 'FDDL_SRC')
                acc(num_train,run) = FDDL_SRC(data_train, data_test);
            else
                
                n_class = max(data_train.label);
                n_test = length(data_test.label);
                
                % normalize to have unit l2 norm
                data_train.A = normalize(data_train.A);
                data_test.Y = normalize(data_test.Y);
                
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
                                res(j) = norm(y - data_train.A * alph_j) / norm(alph_j);
                                %                             res(j) = norm(y - data_train.A * alph_j);
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
                
                acc(num_train,run) = sum(labels == data_test.label') / length(data_test.label);
            end
            
            fprintf('Test accuracy %f%%\n', 100 * acc(num_train, run));
        end
    end
    acc_mean = mean(acc,2);
    acc_std = std(acc');
    result = [acc_mean acc_std'];
    save(['./res_new/acc_' dataset '_' alg], 'result');
end

