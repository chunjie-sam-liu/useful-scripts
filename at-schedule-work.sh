#!/usr/bin/env bash
# @AUTHOR: Chun-Jie Liu
# @CONTACT: chunjie.sam.liu.at.gmail.com
# @DATE: 2019-09-17 21:33:21
# @DESCRIPTION:

# Number of input parameters

# test schedule
# echo "/usr/sbin/service apache2 stop" | at -m 21:52 2019-09-17
# echo "/usr/sbin/service apache2 start" | at -m 21:54 2019-09-17

# schedule one time process for stop apache2 at 06:00 2019-09-18
echo "/usr/sbin/service apache2 stop" | at -m 06:00 2019-09-18
# schedule one time process for start apache2 at 14:00 2019-09-20
echo "/usr/sbin/service apache2 start" | at -m 14:00 2019-09-20