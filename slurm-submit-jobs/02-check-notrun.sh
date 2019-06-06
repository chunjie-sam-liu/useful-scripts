#!/usr/bin/env bash


mir_dir=/public1/home/pg2204/target_predit/miRmap_02

altutr_out=${mir_dir}/altutr_out
altutr_out_complet=${mir_dir}/altutr_out_complet

split_dir=/public1/home/pg2204/src/split-not-run

[[ ! -d ${split_dir} ]] && mkdir -p ${split_dir}

mirbase=/public1/home/pg2204/data/mirbase.mir
mirdone=/public1/home/pg2204/data/mirbase.mir.done
mirnotrun=/public1/home/pg2204/data/mirbase.mir.notrun

readarray mirnadone < ${mirdone}
readarray mirnabase < ${mirbase}

for i in `ls ${altutr_out_complet}/*res`
do
  mirna=${i##*/}
  mirna=${mirna%%.res}
  [[ ! ${mirnadone[@]} =~ ${mirna} ]] && echo ${mirna} >> ${mirdone}
done

echo ${mirnabase[@]} ${mirnadone[@]} | tr ' ' '\n' | sort | uniq -u > ${mirnotrun}

cd ${split_dir}
split -l 100 ${mirnotrun}

wc -l ${mirbase} ${mirdone} ${mirnotrun}

