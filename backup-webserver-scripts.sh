#########################################################################
# File Name: backup_scripts.sh
# Author: Chun-Jie Liu
# Mail: chunjie-sam-liu@foxmail.com
# Created Time: 2018 Jul 10
#########################################################################
#!/bin/bash

web=/home/backup/web
cp /etc/apache2/sites-available/000-default.conf ${web}
conf=${web}/000-default.conf
# The scripts backup based on the apapche sites available
# Supported by the main web framework Django and Flask.
# Parse 000-default.conf file to extract the directory of 
# the source scripts directory.

web_dir=$(grep -v "#" ${conf}|grep -v 'liut'|sed -n -e '/python-path/p' |awk -F "=" '{print $2}')
liut="/home/liut/EVmiRNA"

web_dir="${web_dir} ${liut}"

for i in ${web_dir[@]}
do
    d=${i%:*}
    tmp=${d#/home/}
    user=${tmp%%/*}
    webname=`basename ${d}`
    gz=${user}-${webname}-`date +%Y-%m-%d`.tar.gz
    cmd="tar -zcvf ${web}/${gz} ${i}"
    echo "Start zip ${user}'s ${webname}"
    eval ${cmd}
    echo "End zip ${webname}"
done

echo "Done!"