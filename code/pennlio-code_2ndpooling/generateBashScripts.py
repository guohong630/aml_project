'''This file auto generates mulitple bash files to be submitted 
as parelell jobs to the cluster
@authors : Peng
Data: on Chinese Labor's Day, 2014'''

import sys, os
import numpy as np

def putInApo(word):   # return the word put in apostrophe ''
	wordInApo = '\'' + word + '\''
	return wordInApo

tg_folder = './bash_scripts/'

# subfolder = 'fumin2ndpooling/'
# subfolder="libSVM_diag_Learning/"
subfolder = 'caffe_lfw_2layer/'
vmem = "10G" # Gigabytes
wt = "48:00:00"
counter = 0
# file parameter
scriptPath = "cd /home/h1/pli/1_paper_repro/Yangqing_2013/code/caffe_lfw\n" 
scrpt_name = "main_caffe_lfw.py ${PBS_JOBID}" # in matlab without .m
# scrpt_name = "test"
ouputPath = "output/job_${PBS_JOBID}_output.txt"
errorPath = "output/job_${PBS_JOBID}_error.txt"

matlabExeHead = "matlab -nodesktop -nosplash -nodisplay -nojvm -r "
pythonEXeHead = "python26 ./"
# running specific parameter
# svm_flag= 0 # 3 L1 norm;L2 loss
# Bias_set = [0,1,5,10,15]
oper_set = ['*','sqrt']
L_set = [0.1,1,5,10,50]
MODEL1_set = ['fc2']
MODEL2_set = ['fc3']
skip_std_be_set = ['0','1']
skip_std_ae_set = ['0']
skip_std_ac_set = ['1']



try:
	os.mkdir(tg_folder + subfolder)
except Exception, e:
	print "folder already exists; override anyway!"
	for oper in oper_set:
		for L in L_set:
			for MODEL1 in MODEL1_set:
				for MODEL2 in MODEL2_set:
					for skip_std_be in skip_std_be_set:
						for skip_std_ae in skip_std_ae_set:
							for skip_std_ac in skip_std_ac_set:
								filename = "job_branch_" + str(counter) + ".sh"
								f = open(tg_folder + subfolder + filename, 'w')
								# with open(tg_folder + subfolder + filename, 'w') as f:
								# exeCommand = matlabExeHead + "\"oper='" + oper + "';svm_flag=" + str(svm_flag) + ";C_reg=" + str(C_reg) + ";Bias=" + str(Bias) + ";" + scrpt_name + "; quit;\""
								exeCommand = pythonEXeHead + scrpt_name +' '+ putInApo(oper) + ' ' + putInApo(MODEL1) + ' ' + putInApo(MODEL2) + ' ' + str(L) + ' ' + skip_std_be + ' ' + skip_std_ae + ' ' + skip_std_ac
								f.write("#!/bin/bash\n" +
									"#PBS -l nodes=1:ppn=1,vmem=" + vmem + ",walltime=" + wt + "\n" +
									"#PBS -o "+ ouputPath + "\n" +
									"#PBS -e "+ errorPath + "\n" +
									"#cp $PBS_NODEFILE $PBS_O_WORKDIR/nodes\n" +
									"cd $PBS_O_WORKDIR\n" +
									"# hostname > job_host_${PBS_JOBID}.txt\n" +
									# below is file specific
									scriptPath +
									exeCommand + '\n'
									"exit\n")
								f.close()
							counter += 1
	print "generates " + str(counter) + " parallel tasks!"

