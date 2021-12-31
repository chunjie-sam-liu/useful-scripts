#!/usr/bin/env bash
# @AUTHOR: Chun-Jie Liu
# @CONTACT: chunjie.sam.liu.at.gmail.com
# @DATE: 2021-12-30 11:25:37
# @DESCRIPTION:

# Number of input parameters

#SBATCH --job-name=TestJob
#SBATCH --nodes=3
#SBATCH --ntasks=3
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=5


srun --ntasks 1 bash /home/liuc9/github/useful-scripts/generalParallel /home/liuc9/github/useful-scripts/slurm-parallel/scriptfile.sh 500