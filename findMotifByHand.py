#!/usr/bin/python
#-*- coding:utf-8 -*-
################################################
#File Name: find_motif.py
#Author: C.J. Liu
#Mail: samliu@hust.edu.cn
#Created Time: Sun 09 Oct 2016 05:25:28 PM CST
################################################

import os,sys
import re
from itertools import product
from Bio import SeqIO
import numpy as np
ROOT = os.path.dirname(os.path.abspath(__file__))

def help():
    helpMessage='''    Description:
        Find motif through nt number. It relies on the exact match, not caculating the possibility or confidence coeffient like MEME, it's used for tuning motif results produced by MEME and speeding up handpick.
        It's based on the Cartesian product with 4 alphabets. The nt number is not recommended over 10nt. It's very slow when nt number is over 10 which will loop for one million times.
    Example:
        python find_motif.py seq.fasta motifLength 
    '''
    
    if len(sys.argv) < 3:
        print(helpMessage)
        sys.exit(1)
        
def motifList(motifLength):
    motifLength = int(motifLength)
    alpha = ["A", "G", "C", "T"]
    searchList = list(product(alpha, repeat=motifLength))
    searchList = [''.join(i) for i in searchList]
    return searchList
    
def run(fastaFile,motifLength):
    # print(motifList(motifLength))
    searchList = motifList(motifLength)
    for motif in searchList:
        searchedID = list()
        prog = re.compile(motif, re.I)
        for record in SeqIO.parse(fastaFile, 'fasta'):
            id = record.id
            seq = str(record.seq)
            if prog.search(seq):
                searchedID.append(id)
        if len(searchedID) < 5: continue
        print(motif,str(len(searchedID)),','.join(searchedID), sep="\t")

def main():
    help()
    run(sys.argv[1], sys.argv[2])

if __name__ == "__main__":
    main()
