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

# ! output filename
filename="apache-${keyword}.log"
[[ -f ${filename} ]] && true > ${filename}

for log in ${logs}
do
    zgrep -i ${keyword} ${log} | awk -F ':' '{print $1}' | awk -F ' - - \\[' '{print $1,$2}' >> ${filename}
done

sed -i '/bin/Id' ${filename}

Rscript plot-website-access.R ${filename}