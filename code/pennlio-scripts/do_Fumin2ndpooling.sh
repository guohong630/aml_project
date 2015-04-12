# !bin/bash
#PBS -l nodes=1:ppn=1,walltime=48:00:00,vmem=50G
#PBS -o output/job_${PBS_JOBID}_output.txt
#PBS -e output/job_${PBS_JOBID}_error.txt
#cp $PBS_NODEFILE $PBS_O_WORKDIR/nodes
cd $PBS_O_WORKDIR	# Go to the directory the job was started in
# hostname > job_host_${PBS_JOBID}.txt


cd /home/h1/pli/1_paper_repro/Fumin_ECCV_2014/LFW/code_2ndPooling

svm_flag=0 # 3 L1 norm;L2 loss
oper=sqdiff
C_reg=1
Bias=1

matlab -nodesktop -nosplash -nodisplay -nojvm -r "oper='"${oper}"';svm_flag ="${svm_flag}";C_reg ="${C_reg}";Bias ="${Bias}";Read_Features_LFW_funneled;"

# matlab -nodesktop -nosplash -nodisplay -nojvm -r "oper='mul';svm_flag =3;C_reg =2;Bias =1;test; quit;"

# matlab -nodesktop -nosplash -nodisplay -nojvm -r "oper='"${oper}"';svm_flag ="${svm_flag}";C_reg ="${C_reg}";Bias ="${Bias}";test; quit;"
# exit