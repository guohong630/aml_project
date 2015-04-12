#!/bin/bash
#PBS -l nodes=1:ppn=4,vmem=8G,walltime=48:00:00
#PBS -o output/job_${PBS_JOBID}_output.txt
#PBS -e output/job_${PBS_JOBID}_error.txt
#cp $PBS_NODEFILE $PBS_O_WORKDIR/nodes
cd $PBS_O_WORKDIR  # Go to the directory the job was started in
# hostname > job_host_${PBS_JOBID}.txt
cd /home/h1/pli/1_paper_repro/Yangqing_2013/code/caffe_lfw
python26 ./main_caffe_lfw.py ${PBS_JOBID} '*' 'fc3' 'no' 5 0 0 1
# python26 ./testarg.py ${PBS_JOBID} '*' 'fc2' 'no' '' 10 1 0 1

exit
