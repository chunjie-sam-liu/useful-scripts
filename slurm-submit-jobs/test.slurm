#!/usr/bin/env bash

#SBATCH --partition=pg2_128_pool
#SBATCH --nodes=2
#SBATCH --ntasks=40
#SBATCH --ntasks-per-node=20
#SBATCH --cpus-per-task=1
#SBATCH --time=00:01:00
#SBATCH --job-name=test.slurm
#SBATCH --output=test.slurm-%j.out
#SBATCH --error=test.slurm-%j.err
#SBATCH --mail-user=chunjie-sam-liu@foxmail.com
#SBATCH --mail-type=end

module load anaconda3/3.5.2


for i in $(seq -w 1 40)
do
  srun --exclusive --nodes 1 --ntasks 1 python demo.py ${i}  &
  #python demo.py ${i} &
done

wait

# log into specific node
# srun --pty  --nodelist=d0806 --partition=v3_64_single bash