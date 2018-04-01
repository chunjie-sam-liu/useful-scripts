#########################################################################
# File Name: cron-mysql.sh
# Author: C.J. Liu
# Mail: samliu@hust.edu.cn
# Created Time: Fri 23 Feb 2018 10:47:16 AM CST
#########################################################################
#!/bin/bash

# */30 * * * * /home/liucj/scripts/cron-mysql.sh
#!/bin/bash
PATH=/usr/sbin:/usr/bin:/sbin:/bin
SHELL=/bin/bash
LOG=/home/liucj/scripts/.cron.log

[[ -f $LOG ]] || touch $LOG

echo "`date` Check MySQL Status" >> $LOG

if [[ ! "$(/usr/sbin/service mysql status)" =~ "running" ]]
then
    echo "Warnging: MySQL Stop at `date`" >> $LOG
    service mysql start
    echo "Success: MySQL Restarted" >> $LOG
fi
