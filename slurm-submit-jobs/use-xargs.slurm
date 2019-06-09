/usr/bin/env bash


#SBATCH -p v2_all
#SBATCH -N 2
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=20
#SBATCH --time=00:30:00
#SBATCH --job-name=check-done

mir_dir=/public1/home/pg2204/target_predit/miRmap_02
altutr_out=${mir_dir}/altutr_out
altutr_out_complet=${mir_dir}/altutr_out_complet
done_res=/public1/home/pg2204/src/done-res

[[ -f ${done_res} ]] && rm ${done_res}

ls ${altutr_out}/*res | xargs -I {} --max-procs=$SLURM_TASKS_PER_NODE bash -c "srun --exclusive --nodes 1 --ntasks 1 bash 00-check-done.sh {}"