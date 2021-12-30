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

srun --exclusive --nodes 1 --ntasks 1 sleep 10 &
srun --exclusive --nodes 1 --ntasks 1 sleep 20 &
srun --exclusive --nodes 1 --ntasks 1 sleep 10 &
srun --exclusive --nodes 1 --ntasks 1 sleep 30 &
srun --exclusive --nodes 1 --ntasks 1 sleep 20 &
srun --exclusive --nodes 1 --ntasks 1 sleep 10 &
srun --exclusive --nodes 1 --ntasks 1 sleep 30 &
srun --exclusive --nodes 1 --ntasks 1 sleep 20 &
srun --exclusive --nodes 1 --ntasks 1 sleep 10 &
srun --exclusive --nodes 1 --ntasks 1 sleep 20 &
srun --exclusive --nodes 1 --ntasks 1 sleep 10 &
srun --exclusive --nodes 1 --ntasks 1 sleep 30 &
srun --exclusive --nodes 1 --ntasks 1 sleep 20 &
srun --exclusive --nodes 1 --ntasks 1 sleep 10 &
srun --exclusive --nodes 1 --ntasks 1 sleep 30 &
srun --exclusive --nodes 1 --ntasks 1 sleep 20 &
wait
