#########################################################################
# File Name: guo.sh
# Author: Chun-Jie Liu
# Mail: chunjie-sam-liu@foxmail.com
# 
#########################################################################
#!/bin/bash

# ! access log files

keyword=$1

# ! Test input keywords
[[ -z ${keyword} ]] && echo "Notice: Input the website name." && echo "Notice: such as gscalite or snoric." && exit 

# ! apache2 log directory
log_dir="/var/log/apache2/"
logs=`find ${log_dir} -name "access*"`
archive_dir="/home/liucj/tmp/stat-web-access"

# ! output filename
today=`date +'%Y-%m-%d'`
filename="${archive_dir}/${keyword}-${today}.log"
[[ -f ${filename} ]] && true > ${filename}

for log in ${logs}
do
    zgrep -i ${keyword} ${log} | awk -F ':' '{print $1}' | awk -F ' - - \\[' '{print $1,$2}' >> ${filename}
done
sed -i '/bin/Id' ${filename}

# ? plot website access by time
Rscript plot-access-by-time.R ${filename} & 

# ? plot website access by location
Rscript plot-access-by-address.R ${filename} &