#!/bin/bash

# download references data from GATK best practice refrence data


# broad GATK ftp bundle
#? location: ftp.broadinstitue.org/bundle
#? username: gsapubftp-anonymous
#? password:

lftp -u gsapubftp-anonymous,'' \
    -e "mirror -c bundle/hg38 $PWD; exit" \
    ftp.broadinstitute.org