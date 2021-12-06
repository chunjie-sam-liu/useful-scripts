#!/usr/bin/env python
# demo.py:
# usage: python demo.py [job-number]

import sys
import socket
from time import sleep


def work(jobnum):
    print("Starting job {} on {}.".format(jobnum, socket.gethostname()))
    sleep(5)
    print("Finished job {}...\n".format(jobnum))


if __name__ == "__main__":
    jobnum = sys.argv[1]
    work(jobnum)

