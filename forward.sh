#!/usr/bin/env bash
# @AUTHOR: Chun-Jie Liu
# @CONTACT: chunjie.sam.liu.at.gmail.com
# @DATE: 2020-05-17 10:46:50
# @DESCRIPTION:

errout_dir="/home/liuc9/tmp/errout/jrocker"

for j in $(ls ${errout_dir}/j*er.job.*); do
  suffix=$(basename ${j})
  cmd="grep -i 'ssh -N -L' ${j}"
  out=$(eval ${cmd})
  echo "${out} & # ${suffix}"
done
