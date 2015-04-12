#!/bin/bash

# back up following folder to bitbucket
# /home/h1/pli/1_paper_repro/Yangqing_2013/code/caffe_yaleB
# /home/h1/pli/1_paper_repro/Yangqing_2013/code/caffe/trunk
# /home/h1/pli/1_paper_repro/Yangqing_2013/code/caffe_lfw
# /home/h1/pli/



# cd /home/h1/pli/1_paper_repro/Yangqing_2013/code/caffe_yaleB
# git add . -A
# git status
# git commit -m "auto upgrade/backup"
# git push origin master


cd /home/h1/pli/1_paper_repro/Yangqing_2013/code/caffe/trunk
git add . -A
git status
git commit -m "auto upgrade/backup"
git push origin master

cd /home/h1/pli/1_paper_repro/Yangqing_2013/code/caffe_lfw
git add . -A
git status
git commit -m "auto upgrade/backup"
git push origin master


cd /home/h1/pli/
git add *.sh 
git add *.py 
git status
git commit -m "auto upgrade/backup"
git push origin master