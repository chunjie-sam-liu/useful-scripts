#!/usr/bin/env bash


#SBATCH -p v2_all
#SBATCH -N 2
#SBATCH -n 40
#SBATCH --job-name=check-result

mir_dir=/public1/home/pg2204/target_predit/miRmap_02
altutr_out=${mir_dir}/altutr_out
altutr_out_complet=${mir_dir}/altutr_out_complet



for i in `ls ${altutr_out}/*res`
do
  srun --exclusive --nodes 1 --ntasks 1 bash 00-checkfile-for-01.sh  ${i}  &
done

wait


