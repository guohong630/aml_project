#!/bin/bash

cmd="qsub"
subfolder="bash_scripts"
directory="caffe_lfw_2layer"

python26 generateBashScripts.py

for num in {0..19}
do 
shell_file=./${subfolder}/${directory}/job_branch_"${num}".sh
echo $cmd $shell_file
$cmd $shell_file 
done 
exit;
