#!/usr/bin/python
#-*- coding:utf-8 -*-
################################################
#File Name: find_gene_miRNA_by_symbol.py
#Author: C.J. Liu
#Mail: samliu@hust.edu.cn
#Created Time: Wed 30 Mar 2016 02:25:50 PM CST
################################################

import sys, os
import pickle
import pprint
import re

def help():
	if len(sys.argv) != 2:
		print "Description:"
		print "\tFind gene regulated by miRNAs"
		print "Input:"
		print "\tPlease input gene list with comma or semicolon seperated"
		print "\tOr input a file containing gene line by line"
		print "Example:"
		print "\t1. python %s NR3C1" % sys.argv[0]
		print "\t2. python %s genelistfile.txt" %sys.argv[0]
		sys.exit(1)

def target2mirna():
	miRNA2targetDict = dict()
	with open(os.path.dirname(os.path.realpath(__file__))+"/Total_miRNA2target.20160314.txt", "r") as foo:
		for line in foo:
			arr = line.rstrip().split("\t")
			if len(arr) <2 :
				continue
			try:
				miRNA2targetDict[arr[1]].append(arr[0])
			except:
				miRNA2targetDict.setdefault(arr[1],[arr[0]])
	pickle.dump(miRNA2targetDict, open("target2miRNA.dict.pickle","wb"))
	# pprint.pprint(miRNA2targetDict)
	
def run(f):
	miRNA2targetDict = pickle.load(open(os.path.dirname(os.path.realpath(__file__))+"/target2miRNA.dict.pickle","rb"))
	print "Search\tGene\tmiRNA"
	if os.path.isfile(f):	
		with open(f, 'r') as foo :
			for line in foo:
				line = line.rstrip()
				genes = [i for i,j in miRNA2targetDict.items() if re.search(line,i,re.IGNORECASE)]
				if len(genes) ==0:
					print line,"\t","-","\t","-"
				else:
					for i in genes:
						print line,"\t",i,"\t","\t".join(miRNA2targetDict[i])
	else:
		inputMiRNAList = re.split(",|;",f)
		for line in inputMiRNAList:
			line = line.rstrip()
			genes = [i for i,j in miRNA2targetDict.items() if re.search(line,i,re.IGNORECASE)]
			if len(genes) ==0:
				print line,"\t","-","\t","-"
			else:
				for i in genes:
					print line,"\t",i,"\t","\t".join(miRNA2targetDict[i])

def main():
	help()
	# target2mirna()
	run(sys.argv[1])

if __name__ == "__main__":
	main()







