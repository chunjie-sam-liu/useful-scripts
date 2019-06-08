#!/usr/bin/env bash

# The scripts is for connect, copyto and download for multiple servers.
# The known_iplist should be provided with username@ip@port@password@index@servername.
# The known_iplist should be put in ~/.ssh and status code change to 600.


# IP LIST
ipfile=${HOME}/.ssh/known_iplist

[[ ! -s ${ipfile} ]] && {
  echo "Error: ${ipfile} does not exist."
  exit 1
}

# check the mode of known_iplist
[[ $(stat -c "%a" ${ipfile}) -ne 600 ]] && {
  echo "Warning: The mode of file ${ipfile} is not 700. chmod 600 for ${ipfile}."
  chmod 600 ${ipfile}
}

# load ipmaps
declare -a ipmaps
readarray known_ips < ${ipfile}

# number of input parameters
param=$#

# set up functions
# in [login|copyto|download]
func=$1
funcs[1]='login'
funcs[2]='copyto'
funcs[3]='download'
funcs[4]='lg'
funcs[5]='cp'
funcs[6]='dl'

# interface to server
server=$2
# source file
src=$3
# destination directory
dest=${4:-${PWD}}


function fn_errorinfo {
  echo "Usage:"
  echo "    cs [login|copyto|download] [server]"
  echo "Details:"
  echo "    login|lg -> login, log into server."
  echo "    copyto|cp -> copyto, copyto files to server."
  echo "    download|dl -> downlaod, download from server."
  echo "For example1:"
  echo "    cs login 1."
  echo "    example2:"
  echo "    cs copyto 1 source destination."
  echo "    example3:"
  echo "    cs download 1 source destination."
  echo "Notice: The source and destination should be absolute path. Source is a file and destination is directory."
}

function fn_inarray {
  # $1 is element
  # $2 is ${array[@]}
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function fn_load_iplist {
  for line in ${known_ips[@]};
  do
    line=${line//#/ }
    line=(${line})
    ipmaps[${line[1]}]=${line[0]}
  done
}

function fn_parse_ip {
  local ip_str="$1"
  line=${ip_str%#*}
  line=${line//@/ }
  echo $line
}

function fn_usage {
  # The parameters should be in 2 3 4
  [[ ! (${param} -eq 2 || ${param} -eq 4) ]] && {
    echo "Error: Parameters should be in 2, 4."
    echo "****************************************************"
    fn_errorinfo
    exit 1
  }

  # func should be in the funcs list
  ! fn_inarray ${func} ${funcs[@]} && {
    echo "Error: Function '${func}' not in connect server."
    echo "****************************************************"
    fn_errorinfo
    exit 1
  }

  # server should be valid.
  ! fn_inarray ${server} ${!ipmaps[@]} && {
    echo "Error: Server '${server}' should be integer and in the '${!ipmaps[@]}'."
    echo "****************************************************"
    fn_errorinfo
    exit 1
  }

}

function fn_login {
  # func == login, param should be equal to 2
  # copyto and download should be four parameters.

  [[ ${param} -ne 2 ]] && {
    echo "Error: login should be two parameters."
    echo "****************************************************"
    fn_errorinfo
    exit 1
  }

  cmd="sshpass -p '${loginfo[3]}' ssh -p ${loginfo[2]} ${loginfo[0]}@${loginfo[1]}"
  echo "Notice: login into ${server}."
  echo ${cmd}
  echo "****************************************************"
  eval ${cmd}
  exit 0
}

function fn_copyto {
  # for copyto, src file should exist.
  [[ ! -e ${src} ]] && {
    echo "Error: file '${src}' not exits."
    echo "****************************************************"
    fn_errorinfo
    exit 1
  }

  cmd="sshpass -p '${loginfo[3]}' rsync -rvz  -e 'ssh -p ${loginfo[2]}' --progress ${src} ${loginfo[0]}@${loginfo[1]}:${dest} "
  eval ${cmd}
  exit 0
}

function fn_download {
  # for download, dest directory should exist.
  [[ ! -d ${dest} ]] && {
    echo "Error: directory '${dest}' not exists."
    echo "****************************************************"
    fn_errorinfo
    exit 1
  }

  cmd="sshpass -p '${loginfo[3]}' rsync -rvz -e 'ssh -p  ${loginfo[2]}' --progress ${loginfo[0]}@${loginfo[1]}:${src} ${dest}"
  eval ${cmd}
  exit 0
}

function fn_run {
  # Run
  [[ ${func} = 'login' ]] && fn_login || fn_usage
  [[ ${func} = 'copyto' ]] && fn_copyto || fn_usage
  [[ ${func} = 'download' ]] && fn_download || fn_usage

  # Alias
  [[ ${func} = 'lg' ]] && fn_login || fn_usage
  [[ ${func} = 'cp' ]] && fn_copyto || fn_usage
  [[ ${func} = 'dl' ]] && fn_download || fn_usage
}

function main {
  # load ip list
  fn_load_iplist

  # Usage
  fn_usage

  # parse text ip
  loginfo=($(fn_parse_ip ${ipmaps[$server]}))

  # main run function
  fn_run
}

main
