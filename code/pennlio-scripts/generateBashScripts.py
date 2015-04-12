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
# subfolder = 'caffe_lfw_2layer/'
# subfolder = 'caffe_lfwf_121/'
# subfolder = 'caffe_lfwf_136/'
subfolder = 'caffe_lfwf_152/'
vmem = "9G" # Gigabytes
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
oper_set = ['-sqrt']
std_plus_set = [0.1,5]
L_set = [0.1,0.5,1,5]
MODEL1_set = ['fc3']
MODEL2_set = ['fc3_p4nn']
flag1_set = ['5']
flag2_set = ['5']
flag3_set = ['4']
fnormmode1_set = ['c','m']
fnormmode2_set = ['c','m']
fnormmode3_set = ['c']

try:
	os.mkdir(tg_folder + subfolder)
except Exception, e:
	print "folder already exists; delete and rewrite anyway!"
	folder = tg_folder + subfolder
	for bash_file in os.listdir(folder):
		file_path = os.path.join(folder, bash_file)
		try:
			if os.path.isfile(file_path):
				os.unlink(file_path)
		except Exception, e:
			print e
finally:
	for oper in oper_set:
		for L in L_set:
			for std_plus in std_plus_set:
				for MODEL1 in MODEL1_set:
					for MODEL2 in MODEL2_set:
						for flg1 in flag1_set:
							if int(flg1) == 0:
								normmode1_set = ['no']
							else:
								normmode1_set = fnormmode1_set
							for norm_mode1 in normmode1_set:
								for flg2 in flag2_set:
									if int(flg2) == 0:
										normmode2_set = ['no']
									else:
										normmode2_set = fnormmode2_set
									for norm_mode2 in normmode2_set:
										for flg3 in flag3_set:
											if int(flg3) == 0:
												normmode3_set = ['no']
											else:
												normmode3_set = fnormmode3_set
											for norm_mode3 in normmode3_set:
												print oper, L, std_plus, MODEL1, MODEL2, flg1,flg2,flg3, norm_mode1,norm_mode2,norm_mode3
												filename = "job_branch_" + str(counter) + ".sh"
												f = open(tg_folder + subfolder + filename, 'w')
												# with open(tg_folder + subfolder + filename, 'w') as f:
												# exeCommand = matlabExeHead + "\"oper='" + oper + "';svm_flag=" + str(svm_flag) + ";C_reg=" + str(C_reg) + ";Bias=" + str(Bias) + ";" + scrpt_name + "; quit;\""
												exeCommand = pythonEXeHead + scrpt_name +' '+ putInApo(oper) + ' ' + putInApo(MODEL1) + ' ' + putInApo(MODEL2) + ' ' + str(std_plus) + ' ' + str(L) + ' ' + flg1 + norm_mode1 + ' ' + flg2 + norm_mode2+ ' ' + flg3+ norm_mode3
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

