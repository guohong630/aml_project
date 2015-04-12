clear 
profile on
a = eig(magic(350));
p = profile('info');
save myprofiledata p
clear p
load myprofiledata
profview(0,p)
