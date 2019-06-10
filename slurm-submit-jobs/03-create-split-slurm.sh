#!/usr/bin/env bash

src_dir=/public1/home/pg2204/src
split_dir=${src_dir}/split-not-run
split_slurm_dir=${src_dir}/split-slurm-submit-jobs

[[ -d ${split_slurm_dir} ]] && rm -rf ${split_slurm_dir}

mkdir -p ${split_slurm_dir}

for i in `ls ${split_dir}/x*`
do
  # create x.slurm
  filename=`basename $i`
  slurmfile=${split_slurm_dir}/${filename}.slurm
  echo $slurmfile
  cat <<EOF > ${slurmfile}
#!/usr/bin/env bash
#SBATCH -p v2_all
#SBATCH -N 5
#SBATCH -n 100
#SBATCH --ntasks-per-node=20
#SBATCH --job-name=${filename}
#SBATCH -o ${slurmfile}.log

source /public1/home/pg2204/soft/pypy-2.7-v7.1.1-cg2/pypy.sh
export PYTHONPATH=/public1/home/pg2204/tools/DendroPy-4.4.0/src:\$PYTHONPATH
export PYTHONPATH=/public1/home/pg2204/tools/miRmap-1.1/src:\$PYTHONPATH

while read mirna;
do
  srun --exclusive --nodes 1 --ntasks 1 pypy /public1/home/pg2204/tools/miRmap-1.1/scripts/run_mirmap.py \${mirna} /public1/home/pg2204/data/truncate_altutr_03.key /public1/home/pg2204/data/muture.fa.hsa.json /public1/home/pg2204/data/truncate_altutr_03.json /public1/home/pg2204/target_predit/miRmap_02/altutr_out/\${mirna}.res &
done < ${i}
wait
EOF
done
