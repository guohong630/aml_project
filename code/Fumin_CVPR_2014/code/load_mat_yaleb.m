function [X] =load_mat_yaleb(X_path)
%% load .mat file of yaleB dataset give path,
% transform into single-precison to save memory
len = length(X_path);
X = [];
% X_path
for i = 1:len
	% X_path(i)
	load(X_path(i,:))
	tmp = scores{1,1}';
	size(tmp);
	X = cat(1,X,tmp);
end
