import sys, os
import numpy as np
import operator

jobDict = {}
tg_folder = '/home/h1/pli/4_Results/'
# subfolder = 'caffe_lfwf_2layer/'
# subfolder = 'caffe_lfwf_121/'
# subfolder = 'caffe_lfwf_136_fc4/'
# subfolder = 'caffe_lfwf_136_sqrt/'
# subfolder = 'caffe_lfwf_v2/'
# subfolder = 'caffe_lfwf_136v/fc3_p4/'
# subfolder = 'caffe_lfwf_136v/f3_combine_normmodes/'
# subfolder = 'caffe_lfwf_136v/f3_normmodes/'
subfolder = 'caffe_lfwf_152/fc3&fc3_p4/'
counter = 0;
maxAcc = 0;
for subf in os.listdir(tg_folder+subfolder):
	if subf[-5] == "t":
		f = open(tg_folder + subfolder + subf,'r')
		lines = f.readlines()
		# print lines[-2]
		# print lines[-1]
		jobid = lines[2][:-1]
		tmpmax = lines[-1][16:24] # find the number of test accuracy
		jobDict[jobid] = float(tmpmax)
		print jobid + ' ' + tmpmax
		if float(tmpmax) > maxAcc:
			maxAcc = float(tmpmax)
			maxjobid = jobid
		counter+=1
		f.close()
print "read " + str(counter) + " files"
print "max:" + maxjobid + " " + str(maxAcc)
# print jobDict
sorted_job = sorted(jobDict.iteritems(), key=operator.itemgetter(1))
for i in range(1,10):
	job = sorted_job[counter-i]
	print job[0] + ':' + str(job[1])