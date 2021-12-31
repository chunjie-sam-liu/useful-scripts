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
#SBATCH --cpus-per-task=1

hostname &
hostname &
hostname &
hostname &
wait