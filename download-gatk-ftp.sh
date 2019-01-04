#!/bin/bash

# download references data from GATK best practice refrence data


# broad GATK ftp bundle
#? location: ftp.broadinstitue.org/bundle
#? username: gsapubftp-anonymous
#? password:

# lftp -u gsapubftp-anonymous,'' \
#     -e "mirror --continue --parallel=10 /bundle/hg38 $PWD; exit" \
#     ftp.broadinstitute.org

f=$1
[ -z $f ] && echo "Error: Input directory like: /bundle/hg38" && exit 1


#? login
host='ftp.broadinstitute.org'
user='gsapubftp-anonymous'
password=''

#? remote directory
remote_dir=${f}

#? local direcotry
local_dir='/home/liucj/data/data/refdata/bundle/hg38'

#? runtime
echo 
echo "Starting download ${remote_dir} from ${host} to ${local_dir}"
date

lftp -u ${user},${password} ${host} <<EOF
mirror --use-pget-n=60 ${remote_dir} ${local_dir};
exit
EOF

echo 
echo "Transfer finished"
date
