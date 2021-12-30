#!/usr/bin/env bash
# @AUTHOR: Chun-Jie Liu
# @CONTACT: chunjie.sam.liu.at.gmail.com
# @DATE: 2021-12-30 11:25:37
# @DESCRIPTION:

# Number of input parameters

#SBATCH --job-name=TestJob
#SBATCH --nodes=2
#SBATCH --ntasks=4
#SBATCH --ntasks-per-node=2

sr="srun --exclusive --nodes 1 --ntasks 1"


while read line;
do
  # echo $line
  cmd="${sr} ${line} &"
  echo ${cmd}
  # srun --exclusive --nodes 1 --ntasks 1 ${line} &
  eval ${cmd}
done < scriptfile.sh

wait
