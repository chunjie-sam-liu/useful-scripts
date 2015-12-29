#########################################################################
# File Name: downloadsra.sh
# Author: C.J. Liu
# Mail: samliu@hust.edu.cn
# Created Time: Mon 28 Sep 2015 09:23:24 AM CST
#########################################################################
#!/bin/bash

#download data from sra through lftp
#input srr id with comma delimited

if test -z "$1" 
then
	echo "input srr id list with comma delimited"
	exit 1
fi 

sraList=$1
sraList=(${sraList//,/ })


for i in ${sraList[@]}
do 
	#echo $i;
	dir=${i:0:6}
	#echo $dir
	#sra=`echo $i|cut -c 7-9`
	nohup lftp -e "mirror /sra/sra-instant/reads/ByRun/sra/SRR/${dir}/${i} ." ftp-trace.ncbi.nih.gov>${i}.nohup.out&
done


