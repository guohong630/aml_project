#!/bin/bash
#PBS -l nodes=1:ppn=4,vmem=10G,walltime=10:00:00
#PBS -o output/job_${PBS_JOBID}_output.txt
#PBS -e output/job_${PBS_JOBID}_error.txt
#cp $PBS_NODEFILE $PBS_O_WORKDIR/nodes

cd $PBS_O_WORKDIR  # Go to the directory the job was started in
# hostname > job_host_${PBS_JOBID}.txt
cd /home/h1/pli/1_paper_repro/Yangqing_2013/code/caffe_caltech
python26 ./main_caffe_caltech.py ${PBS_JOBID}

exit
