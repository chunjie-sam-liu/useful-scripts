#########################################################################
# File Name: gdc_download.sh
# Author: C.J. Liu
# Mail: samliu@hust.edu.cn
# Created Time: Mon 21 Nov 2016 01:32:17 PM CST
#########################################################################
#!/bin/bash

#$1 is Manifest file
#$2 Total number of download files
#open a fifo file

# Update token regularly
token="/tokens_path/your_token_.txt"

[[ -f "$token" ]] || echo "Need gdc token or update token"

function usage {
	if [ "$param" -lt 1 ]; then
		echo "Usage:"
		echo "	bash gdc_download.sh manifest.csv parallel_number(default 20)"
		exit 1
	fi
	
	if [ ! -f $manifest ]; then
		echo "Error: First argument must be manifest file"
		echo "Usage:"
		echo "	bash gdc_download.sh manifest.csv parallel_number(default 20)"
		exit 1
	fi
}

manifest=$1
[[ ! -z $2 ]] && thread=$2 || thread=20
param=$#


# Usage 
usage

# Make fifo
tmp_fifofile='/tmp/$$.fifo'
mkfifo $tmp_fifofile
exec 6<>$tmp_fifofile
rm -rf $tmp_fifofile

for (( i=0; i < $thread; i++ ))
do
	echo ""
done>&6

# All file id
fileID=()
while read line;do name=(${line//"\t"/ }); fileID+=(${name[0]}); done < $manifest

# echo ${#fileID[@]}

# All task table with 
Total=${#fileID[@]}
for (( i=0; i < $Total; i++ ));
do
	read -u6
	{
		# echo ${fileID[i]}
		# sleep 5
		# Download data 20 parallel
		gdc-client download ${fileID[i]} -t $token
		echo "">&6
	}&
	
done
wait
exec 6>&-

# md5sum check download files.
Root=$PWD

#[[ -d ${Root}/md5check ]] && echo "${Root}/md5check already exists" || mkdir -p ${Root}/md5check

#ln -s ${Root}/*/*bam ${Root}/md5check/.
#awk '{print $3,$2}' $manifest > ${Root}/md5check/md5checklist.txt

#cd ${Root}/md5check/
#md5sum -c ${Root}/md5check/md5checklist.txt > ${Root}/md5check/md5check.result

exit 0








