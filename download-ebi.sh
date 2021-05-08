#!/usr/bin/env bash
# @AUTHOR: Chun-Jie Liu
# @CONTACT: chunjie.sam.liu.at.gmail.com
# @DATE: 2021-05-08 10:34:14
# @DESCRIPTION:

# Number of input parameters

url="ftp.ebi.ac.uk"
remote_dir="/pub/databases/metagenomics/mgnify_genomes/human-gut/v1.0/uhgg_catalogue"
prefix="MGYG-HGUT-0"

for i in `seq 0 4`;
do
  for j in `seq 0 9`;
  do
    [[ ${i} -eq 4 && ${j} -gt 6 ]] && continue
    dir1=${prefix}${i}${j}
    for m in `seq 0 9`;
    do
      for n in `seq 0 9`;
      do
        [[ ${i}${j}${m}${n} = "0000" ]] && continue
        [[ ${i}${j} = "46" && ${m}${n} -gt 44 ]] && continue
        dir2=${dir1}${m}${n}
        cmd="lftp -e \"get -c ${remote_dir}/${dir1}/${dir2}/genome/${dir2}.fna\" ftp.ebi.ac.uk"
        echo ${cmd}
      done
    done
  done
done