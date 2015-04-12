# !bin/bash

cmd="qsub"
subfolder="bash_scripts"

# directory="fumin2ndpooling"
directory="libSVM_diag_Learning"


python26 generateBashScripts.py

for num in {0..24}
do 
shell_file=./${subfolder}/${directory}/job_branch_"${num}".sh
echo $cmd $shell_file
$cmd $shell_file 
done 
exit;
