#!/bin/bash
#PBS -l nodes=1:ppn=4,vmem=50G,walltime=10:00:00
#PBS -o output/job_${PBS_JOBID}_output.txt
#PBS -e output/job_${PBS_JOBID}_error.txt
#cp $PBS_NODEFILE $PBS_O_WORKDIR/nodes
cd $PBS_O_WORKDIR  # Go to the directory the job was started in
cd ./1_paper_repro/Yangqing_2013/code/caffe_lfw
# pwd
# matlab -nojvm -nosplash nodesktop -r "run 
# ./do_facemean_lfw.m"

matlab -nojvm -nosplash nodesktop -r "run ./do_facemean_lfw.m"


exit