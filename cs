#!/usr/bin/env bash

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
# load known iplist
readarray known_ips < ~/.ssh/known_iplist
# regular ip maps
ipmaps[1]=${known_ips[0]}
ipmaps[2]=${known_ips[1]}
ipmaps[3]=${known_ips[2]}
ipmaps[4]=${known_ips[3]}
ipmaps[10]=${known_ips[4]}
ipmaps[11]=${known_ips[5]}

# source file
src=$3
# destination directory
dest=${4:-${PWD}}


function errorinfo {
  echo "Usage:"
  echo "    connect server [login|copyto|download] [server]"
  echo "Details:"
  echo "    login -> login, log into server."
  echo "    copyto -> copyto, copyto files to server."
  echo "    download -> downlaod, download from server."
  echo "For example1:"
  echo "    connect server login 1."
  echo "    example2:"
  echo "    connect server copyto 1 source destination."
  echo "    example3:"
  echo "    connect server download 1 source destination."
  echo "Notice: The source and destination should be absolute path. Source is a file and destination is directory."
}

function inarray {
  # $1 is element
  # $2 is ${array[@]}
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function parse_ip {
  local ip_str="$1"
  line=${ip_str%#*}
  line=${line//@/ }
  echo $line
}

function usage {
  # The parameters should be in 2 3 4
  [[ ${param} -lt 2 || ${param} -gt 4 ]] \
  && echo "Error: Parameters should be in 2, 3, 4." \
  && echo "****************************************************" \
  && errorinfo \
  && exit 1

  # func should be in the funcs list
  ! inarray ${func} ${funcs[@]} && {
    echo "Error: Function '${func}' not in connect server."
    echo "****************************************************"
    errorinfo
    exit 1
  }

  # server should be valid.
  ! inarray ${server} ${!ipmaps[@]} \
  && echo "Error: Server '${server}' should be integer and in the '${!ipmaps[@]}'." \
  && echo "****************************************************" \
  && errorinfo \
  && exit 1

}

function login {
  # func == login, param should be equal to 2
  # copyto and download should be four parameters.

  [[ ${param} -ne 2 ]] \
    && echo "Error: login should be two parameters." \
    && echo "****************************************************" \
    && errorinfo \
    && exit 1

  cmd="sshpass -p '${loginfo[3]}' ssh -p ${loginfo[2]} ${loginfo[0]}@${loginfo[1]}"
  echo "Notice: login into ${server}."
  echo ${cmd}
  echo "****************************************************"
  eval ${cmd}
  exit 0
}

function copyto {
  # for copyto, src file should exist.
  [[ ! -e ${src} ]] \
  && echo "Error: file '${src}' not exits." \
  && echo "****************************************************" \
  && errorinfo \
  && exit 1

  cmd="sshpass -p '${loginfo[3]}' rsync -rvz  -e 'ssh -p ${loginfo[2]}' --progress ${src} ${loginfo[0]}@${loginfo[1]}:${dest} "
  eval ${cmd}
  exit 0
}

function download {
  # for download, dest directory should exist.
  [[ ! -d ${dest} ]] \
  && echo "Error: directory '${dest}' not exists." \
  && echo "****************************************************" \
  && errorinfo \
  && exit 1

  cmd="sshpass -p '${loginfo[3]}' rsync -rvz -e 'ssh -p  ${loginfo[2]}' --progress ${loginfo[0]}@${loginfo[1]}:${src} ${dest}"
  eval ${cmd}
  exit 0
}


# Usage
usage

# parse text ip
loginfo=($(parse_ip ${ipmaps[$server]}))

# Run
[[ ${func} = 'login' ]] && login || usage
[[ ${func} = 'copyto' ]] && copyto || usage
[[ ${func} = 'download' ]] && download || usage

# Alias
[[ ${func} = 'lg' ]] && login || usage
[[ ${func} = 'cp' ]] && copyto || usage
[[ ${func} = 'dl' ]] && download || usage
