#!/usr/bin/env bash
#SBATCH --signal=USR2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=50
#SBATCH --mem=50G
#SBATCH --time=1080:00:00
#SBATCH --output=/home/%u/tmp/errout/jrocker/vscode.job.%j
# customize --output path as appropriate (to a directory readable only by the user!)

code tunnel --random-name --no-sleep
