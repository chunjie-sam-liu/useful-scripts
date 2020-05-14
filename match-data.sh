#!/usr/bin/env bash

htseq_file='/workspace/liucj/tongji-data-backup/htseq_count800.mod'
dir_root='/workspace/liucj/tongji-data-backup'
dir_target=${dir_root}/cj_tidy_data

# cat ${htseq_file}|while read line; do
#   find ${dir_root} -type d -name $line
# done > ${htseq_file}.find

cat ${htseq_file}.find|while read line; do
  cmd="cp -r ${line} ${dir_target}"
  echo ${cmd}
done > /tmp/cj-cp-target-dir.sh

nohup bash /home/liucj/scripts/generalParallel /tmp/cj-cp-target-dir.sh 20 1>cj-cp-target-dir.sh.log 2>cj-cp-target-dir.sh.err &
