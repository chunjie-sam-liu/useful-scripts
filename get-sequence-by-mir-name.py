#!/usr/bin/python
#-*- coding:utf-8 -*-
################################################
#File Name: get_sequence_by_mir_name.py
#Author: C.J. Liu
#Mail: samliu@hust.edu.cn
#Created Time: Thu 24 Mar 2016 04:17:56 PM CST
################################################

import sys,os
from Bio import SeqIO
ROOT = os.path.dirname(os.path.abspath(__file__))


def run(mirnafile):
    fasta_file = ROOT + "/mature.fa" # Input fasta file
    wanted_file = mirnafile # Input interesting sequence IDs, one per line
    result_file = mirnafile + ".fasta" # Output fasta file

    wanted = set()
    with open(wanted_file) as f:
        for line in f:
            line = line.strip()
            if line != "":
                wanted.add(line)

    fasta_sequences = SeqIO.parse(open(fasta_file),'fasta')
    with open(result_file, "w") as f:
        for seq in fasta_sequences:
            # print seq
            if seq.id in wanted:
                SeqIO.write([seq], f, "fasta")
            
def main():
    run(sys.argv[1])
if __name__ == "__main__":
    main()
    # print ROOT



