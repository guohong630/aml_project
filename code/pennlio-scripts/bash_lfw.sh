

cmd="qsub"
subfolder="bash_scripts"
# directory="caffe_lfw_2layer"
# directory="caffe_lfwf_136"
directory="caffe_lfwf_152"
# directory="caffe_lfwf_130"
# directory="caffe_lfwf_121"

# start=$1
# end=$2
# echo $1
# echo $2
for num in $(seq $1 $2)
do 
shell_file=./${subfolder}/${directory}/job_branch_"${num}".sh
echo $cmd $shell_file
$cmd $shell_file 
done 
exit;
