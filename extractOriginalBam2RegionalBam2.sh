#########################################################################
# File Name: extractOriginalBam2RegionalBam2.sh
# Author: C.J. Liu
# Mail: samliu@hust.edu.cn
# Created Time: Tue 06 Dec 2016 03:34:19 PM CST
#########################################################################
#!/bin/bash

index='/data/hg38/genomeBuild/hg38.fasta'
tumorDir='/WXS_RAW/tumor'

[ $# -eq 0 ] && echo "Error: Input regional file" && exit 1

region=$1

[ ! -f "$region" ] && echo "Error: $region does not exist or not regional file" && exit 1

allBams=(`find $tumorDir -name "*bam" -type f `)

outputDir=`readlink -f $region`
outputDir=`dirname $outputDir`

extractedBams=(`ls $outputDir`)

unExtractedBams=()
 
for bam in ${allBams[@]}
do
  name=${bam%%.*}
  bname=`basename $name`
  [[ "${extractedBams[@]}" =~ "${bname}" ]] || unExtractedBams+=($bam)
done
echo ${#unExtractedBams[@]}

# Make fifo file.
tmp_fifo='/tmp/$$.fifo'
mkfifo $tmp_fifo
exec 6<>$tmp_fifo
rm -rf $tmp_fifo

for (( i=0; i<30; i++ ))
do 
  echo ""
done >&6

for bam in "${unExtractedBams[@]}"
do
  read -u6 
  {
  name=`basename $bam`
  name=${name%.bam}.extracted.bam
  cmd="samtools view -b -L $region $bam -o ${outputDir}/${name}"
  echo "Notice - Running the command : $cmd"
  eval $cmd
  echo "Success - $bam was extracted to ${outputDir}/${name}!"
  echo "" >&6
  }&
done
wait
exec 6>&-






