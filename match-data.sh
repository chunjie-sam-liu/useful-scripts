#!/usr/bin/env bash

htseq_file='/workspace/liucj/tongji-data-backup/htseq_count800.mod'
dir_root='/workspace/liucj/tongji-data-backup'

cat ${htseq_file}|while read line; do
  find ${dir_root} -type d -name $line
done > ${htseq_file}.find