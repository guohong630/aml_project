# !bin/bash

cmd="qdel"
subfolder="bash_scripts"
directory="fumin2ndpooling"


for num in {52796..52804}
do 
# shell_file=./${subfolder}/${directory}/job_branch_"${num}".sh
echo $cmd $num
$cmd $num 
done 
exit;
