#!/usr/bin/env bash
# @AUTHOR: Chun-Jie Liu
# @CONTACT: chunjie.sam.liu.at.gmail.com
# @DATE: 2022-09-11 02:14:18
# @DESCRIPTION:

# Number of input parameters
param=$#

HOST='ftp://ftp-private.ncbi.nlm.nih.gov'
USER='geoftp'
PASSWORD='rebUzyi1'

# DISTANT DIRECTORY
REMOTE_DIR='uploads/chunjie_sam_liu_GzCpMYQo'

#LOCAL DIRECTORY
LOCAL_DIR='/absolute/path/to/local/directory'


# RUNTIME!
echo
echo "Starting download $REMOTE_DIR from $HOST to $LOCAL_DIR"
date

lftp -u "$USER","$PASSWORD" $HOST <<EOF
# the next 3 lines put you in ftpes mode. Uncomment if you are having trouble connecting.
# set ftp:ssl-force true
# set ftp:ssl-protect-data true
# set ssl:verify-certificate no
# transfer starts now...
set sftp:auto-confirm yes
mirror --use-pget-n=10 $REMOTE_DIR $LOCAL_DIR;
exit
EOF
echo
echo "Transfer finished"
date