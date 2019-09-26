#!/usr/bin/env bash
# @AUTHOR: Chun-Jie Liu
# @CONTACT: chunjie.sam.liu.at.gmail.com
# @DATE: 2019-09-26 10:32:59
# @DESCRIPTION:

# Number of input parameters


# log files
logs=/home/liucj/scripts/crontab-backup.logs
exec &>> ${logs}

echo "`date +%Y-%m-%d` Backup start."
# root path
root_dir=/home/backup-`date +%Y-%m-%d`
[[ -d ${root_dir} ]] && {
  echo "Backup data and scripts to ${root_dir}."
} || {
  echo "Path ${root_dir} not exists, create a new directory."
  mkdir ${root_dir}
  echo "Backup data and scripts to ${root_dir}."
}

# database path
database_dir=${root_dir}/database
[[ -d ${database_dir} ]] && {
  echo "Backup data to ${database_dir}."
} || {
  echo "Path ${database_dir} not exists, create a new directory."
  mkdir ${database_dir}
  echo "Backup data to ${database_dir}."
}

# MongoDB
{
  echo "Start backup MongoDB."
  mongo_dir=${database_dir}/mongo-all-data-`date +%Y-%m-%d`.mongo
  mongodump --username 🙃 --password '🙃' --port 🙃 -o ${mongo_dir}
  tar -czf ${mongo_dir}.tar.gz ${mongo_dir}
  rm -rf ${mongo_dir}
} &

# MySQL
{
  echo "Start backup MySQL."
  mysql_gz=mysql-all-data-`date +%Y-%m-%d`.sql.gz
  mysqldump -u🙃 -p🙃 -A --lock-tables=false | gzip > ${database_dir}/${mysql_gz}
} &


# Scripts

web_dir=${root_dir}/web
[[ -d ${web_dir} ]] && {
  echo "Backup web scripts to ${web_dir}."
} || {
  echo "Path ${web_dir} not exists, create a new directory."
  mkdir ${web_dir}
  echo "Backup web scripts to ${web_dir}."
}

echo "Backup apache2 configure file."
cp /etc/apache2/sites-available/000-default.conf ${web_dir}
conf=${web_dir}/000-default.conf

# apache configure file scripts path.
apache_conf=$(grep -v "#" ${conf}|grep -v 'liut'|sed -n -e '/python-path/p' |awk -F "=" '{print $2}')

# shiny apps path.
shiny_apps=$(find /srv/shiny-server -type l|xargs readlink|grep -v "shiny-server")

# other database scripts.
outside_conf="/home/liucj/web/miRNASNP2 /home/liucj/web/segdt /home/liucj/web/lncRInter /home/liut/EVmiRNA /home/liut/miR_path /home/liut/DODP /home/liut/comid1.0"

total_web_dir="${apache_conf} ${shiny_apps} ${outside_conf}"

for i in ${total_web_dir[@]}
do
    d=${i%:*}
    tmp=${d#/home/}
    user=${tmp%%/*}
    webname=`basename ${d}`
    gz=${user}-${webname}-`date +%Y-%m-%d`.tar.gz
    cmd="tar -zcvf ${web_dir}/${gz} ${i}"

    {
      echo "Start backup ${user}'s ${webname} from ${i} to ${web_dir}/${gz}"
      eval ${cmd}
      echo "End zip ${webname}"
    } &
done