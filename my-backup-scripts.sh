#########################################################################
# File Name: backup_databases.sh
# Author: C.J. Liu
# Mail: samliu@hust.edu.cn
# Created Time: Thu 15 Mar 2018 04:27:45 PM CST
#########################################################################
#!/bin/bash

# Directory
web=/home/liucj/web
web_backup=/home/liucj/tmp/web_backup
s3_backup=/home/liucj/data/web_backup

# For logs
scpd=/home/liucj/scripts
backup_time=`date +"%y-%m"`
log=${scpd}/.webbackup_${backup_time}.log

zipweb () {
    # $1 is the web name
    dest=${web_backup}/${1}_$backup_time.tar.gz
    src=${web}/$1

    echo "Notice: Backup ${1} to ${dest}!" >> ${log}
    cmd="tar -zcvf ${dest} ${src} >> ${log}"
    echo ${cmd} >> $log
    eval ${cmd}

    echo "Notice: Backup ${dest} to server 3" >> ${log}
    cmd="copyto.sh 3 ${s3_backup} ${dest} >> ${log}"
    echo ${cmd} >> $log
    eval ${cmd}
}

for w in `ls ${web}`
do
    zipweb ${w}
done
