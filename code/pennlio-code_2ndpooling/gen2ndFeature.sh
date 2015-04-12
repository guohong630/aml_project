# !/bin/bash

#PBS -l nodes=1:ppn=4,walltime=10:00:00,vmem=50G
#PBS -o output/job_${PBS_JOBID}_output.txt
#PBS -e output/job_${PBS_JOBID}_error.txt
#cp $PBS_NODEFILE $PBS_O_WORKDIR/nodes
cd $PBS_O_WORKDIR	# Go to the directory the job was started in
# hostname > job_host_${PBS_JOBID}.txt
cd /home/h1/pli/1_paper_repro/Fumin_ECCV_2014/LFW/code_2ndPooling

matlab -nodesktop -nosplash -nodisplay -nojvm -r "GenerateFeature; quit;"