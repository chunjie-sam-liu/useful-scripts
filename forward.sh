#!/usr/bin/env bash
# @AUTHOR: Chun-Jie Liu
# @CONTACT: chunjie.sam.liu.at.gmail.com
# @DATE: 2020-05-17 10:46:50
# @DESCRIPTION:

errout_dir="/home/liuc9/tmp/errout/jrocker"

for j in `ls ${errout_dir}`
do
  cmd="grep -i 'ssh -N -L' ${errout_dir}/${j}"
  # echo ${cmd}
  out=`eval ${cmd}`
  echo "${out} &"
done