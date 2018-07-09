#!/usr/bin/python
#-*- coding:utf-8 -*-
################################################
#File Name: find_miRNA_target.py
#Author: C.J. Liu
#Mail: samliu@hust.edu.cn
#Created Time: Thu 24 Mar 2016 01:39:06 PM CST
################################################

import sys, os
import pickle
import pprint
import re

def miRNA2target():
	miRNA2targetDict = dict()
	with open(os.path.dirname(os.path.realpath(__file__))+"/Total_miRNA2target.20160314.txt", "r") as foo:
		for line in foo:
			arr = line.rstrip().split("\t")
			if len(arr) <2 :
				continue
			try:
				miRNA2targetDict[arr[0]].append(arr[1])
			except:
				miRNA2targetDict.setdefault(arr[0],[arr[1]])
	pickle.dump(miRNA2targetDict, open("miRNA2target.dict.pickle","wb"))
	# pprint.pprint(miRNA2targetDict)
	
def run(f):
	miRNA2targetDict = pickle.load(open(os.path.dirname(os.path.realpath(__file__))+"/miRNA2target.dict.pickle","rb"))
	print "Search\tmiRNA\tTarget"
	if os.path.isfile(f):	
		with open(f, 'r') as foo :
			for line in foo:
				if not line.startswith("hsa-"): continue
				line = line.rstrip()
				miRNAs = [i for i,j in miRNA2targetDict.items() if re.search(line+"\D",i,re.IGNORECASE)]
				miRNAs.extend([i for i,j in miRNA2targetDict.items() if re.search(line+"$",i,re.IGNORECASE)])
				if len(miRNAs) ==0:
					print line,"\t","-","\t","-"
				else:
					for i in miRNAs:
						print line,"\t",i,"\t","\t".join(miRNA2targetDict[i])
	else:
		inputMiRNAList = re.split(",|;",f)
		for line in inputMiRNAList:
			if not line.startswith("hsa-"): continue
			line = line.rstrip()
			miRNAs = [i for i,j in miRNA2targetDict.items() if re.search(line+"\D",i,re.IGNORECASE)]
			miRNAs.extend([i for i,j in miRNA2targetDict.items() if re.search(line+"$",i,re.IGNORECASE)])
			if len(miRNAs) ==0:
				print line,"\t","-","\t","-"
			else:
				for i in miRNAs:
					print line,"\t",i,"\t","\t".join(miRNA2targetDict[i])

def help():
	if len(sys.argv) != 2:
		print "Description:"
		print "\tFind miRNA targets"
		print "Input:"
		print "\tPlease input miRNA list with comma or semicolon seperated"
		print "\tOr input a file containing miRNA line by line"
		print "Example:"
		print "\t1. python %s hsa-mir-1,hsa-mir-2" % sys.argv[0]
		print "\t2. python %s miRNAfile.txt" %sys.argv[0]
		sys.exit(1)
def main():
	help()
	run(sys.argv[1])
	# miRNA2target()
	
if __name__ == "__main__":
	main()
