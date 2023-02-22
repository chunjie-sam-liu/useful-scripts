#!/usr/bin/env bash
#SBATCH --signal=USR2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=50G
#SBATCH --time=720:00:00
#SBATCH --output=/home/%u/tmp/errout/jrocker/jupyter.job.%j
# customize --output path as appropriate (to a directory readable only by the user!)

source ~/tools/anaconda3/bin/activate
USER=$(id -un)
PASSWORD=$(openssl rand -base64 15)

readonly PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
# PORT=22222
cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command:

  ssh -N -L ${PORT}:${HOSTNAME}:${PORT} ${USER}@hpc

  and point your web browser to http://${HOSTNAME}:${PORT}/lab

2. log in to Jupyter Server using the following credentials:

   user: ${USER}
   password: ${PASSWORD}

When done using RStudio Server, terminate the job by:

1. Exit the Jupyter Session ("power" button in the top right corner of the RStudio window)
2. Issue the following command on the login node:

      scancel -f ${SLURM_JOB_ID}
END

jupyter lab --ip 0.0.0.0 --port ${PORT} --no-browser --notebook-dir=/home/liuc9
