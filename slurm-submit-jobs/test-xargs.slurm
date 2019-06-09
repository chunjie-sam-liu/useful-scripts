#!/usr/bin/env bash

#SBATCH --partition=pg2_128_pool
#SBATCH --nodes=2
#SBATCH --ntasks=40
#SBATCH --ntasks-per-node=20 # nodes * ntasks-per-node = ntasks, all three must be provided.
#SBATCH --cpus-per-task=1
#SBATCH --time=00:01:00
#SBATCH --job-name=test.slurm
#SBATCH --output=test.slurm-%j.out
#SBATCH --error=test.slurm-%j.err
#SBATCH --mail-user=chunjie-sam-liu@foxmail.com
#SBATCH --mail-type=end

module load anaconda3/3.5.2

echo $SLURM_TASKS_PER_NODE

# calculate how many tasks can we run simultaneously (i.e. how many cores are available)
NR_TASKS=$(echo $SLURM_TASKS_PER_NODE | sed 's/\([0-9]\+\)(x\([0-9]\+\))/\1*\2/' | bc)

echo $NR_TASKS

seq -w 1 300 | xargs -I {} --max-procs=$NR_TASKS bash -c "srun --exclusive --nodes 1 --ntasks 1 python demo.py {}"