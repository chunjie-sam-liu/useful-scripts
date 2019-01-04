#########################################################################
# File Name: backup_scripts.sh
# Author: C.J. Liu
# Mail: samliu@hust.edu.cn
# Created Time: Thu 15 Mar 2018 05:31:25 PM CST
#########################################################################
#!/bin/bash

backup_time=`date +"%y-%m"`
backup_dir="/home/liucj/tmp/web_backup"
s3_backup=/home/liucj/data/web_backup
databases=('lncRInter' 'lncRNAediting_fly' 'lncRNAediting_human' 'lncRNAediting_mouse' 'lncRNAediting_rhesus' 'bioguoor_miRNA_SNP' 'bioguoor_miRNA_SNP_V2' 'snoric')

for i in ${databases[@]};
do
    backup_name=$backup_dir/${i}.${backup_time}.sql.gz
    cmd="mysqldump -u**** -p**** ${i} >  ${backup_name}"
    echo $cmd
    eval $cmd


    cmd="copyto.sh 3 ${s3_backup} ${backup_name}"
    echo ${cmd}
    eval ${cmd}
done
