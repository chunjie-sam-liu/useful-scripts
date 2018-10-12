#########################################################################
# File Name: downloadsra.sh
# Author: C.J. Liu
# Mail: samliu@hust.edu.cn
# Created Time: Mon 28 Sep 2015 09:23:24 AM CST
#########################################################################
#!/bin/bash

#download data from sra through lftp
#input srr id with comma delimited


[[ "$#" -eq 2 ]] && destdir=$2 || destdir=$PWD

if test -z "$1" 
then
	echo "Error: input srr id list with comma delimited"
	exit 1
fi

sraList=$1
sraList=(${sraList//,/ })

for i in ${sraList[@]}
do 
	dir=${i:0:6}
	nohup lftp -e "mirror /sra/sra-instant/reads/ByRun/sra/SRR/${dir}/${i} ${destdir}" ftp-trace.ncbi.nih.gov>${destdir}/${i}.nohup.out&
done


