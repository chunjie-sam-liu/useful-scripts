#!/usr/bin/env bash

mir_dir=/public1/home/pg2204/target_predit/miRmap_02
altutr_out=${mir_dir}/altutr_out
altutr_out_complet=${mir_dir}/altutr_out_complet

filename=$1

nline="grep '>' ${filename}|wc -l"
[[ ${nline} -eq 8935410 ]] && mv ${filename} ${altutr_out_complet}
