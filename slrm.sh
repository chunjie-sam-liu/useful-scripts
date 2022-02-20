#!/usr/bin/env bash
# @AUTHOR: Chun-Jie Liu
# @CONTACT: chunjie.sam.liu.at.gmail.com
# @DATE: 2022-02-20 18:22:36
# @DESCRIPTION:

params=$#
script=${1}



function usage {
  Description="Notice: The script aimed at running shell command in general parallel."
  Usage="Uage:  generalParallel shell_script.sh ntasks(default:20) nodes(default:5) ntasks_per_node(default:1)"
  ErrorNo="Error:  Number of arguments must be 1 or 2"
  ErrorScript="Error:  suffix of script file must be sh."
  if [ "$params" -lt 1 ]; then
    echo $ErrorNo
    echo $Description
    echo $Usage
    exit 1
  fi
  if [ "${script#*.}" != "sh" ]; then
    echo $ErrorScript
    echo $Description
    echo $Usage
    exit 1
  fi
}


function run {
sbatch << EOF
#!/usr/bin/env bash
#SBATCH --signal=USR2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=30G
#SBATCH --time=720:00:00
#SBATCH --output=${HOME}/tmp/errout/${name}.%j.out
#SBATCH --error=${HOME}/tmp/errout/${name}.%j.err
#SBATCH --mail-user=chunjie.sam.liu@gmail.com

bash ${script}

EOF
}

usage
name=`basename ${script%%.sh}`
run