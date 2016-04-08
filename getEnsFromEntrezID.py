#!/usr/bin/python
#-*- coding:utf-8 -*-
################################################
#File Name: getEnsFromEntrezID.py
#Author: C.J. Liu
#Mail: samliu@hust.edu.cn
#Created Time: Fri 08 Apr 2016 04:08:25 PM CST
################################################

import os,sys
import pickle
import pprint
root = os.path.dirname(os.path.realpath(__file__))

def storeEntrezID():
	entrez2Ens = dict()
	with open(root + os.sep + "Homo_sapiens.gene_info_20160408") as foo:
		for line in foo:
			
			if line.startswith("#"): continue
			arr = line.split("\t")
			dbref = dict(item.split(":") for item in arr[5].split("|") if len(item.split(":")) == 2)
			try:
				ens = dbref["Ensembl"]
			except:
				ens = "-"
			entrez2Ens[arr[1]] = ens
	pprint.pprint(entrez2Ens)
	# pickle.dump(entrez2Ens, open("entrez2Ens.pickle","wb"))

def idConvertion(f):
	entrezEnsIdList = pickle.load(open(root + os.sep + "entrez2Ens.pickle", "rb"))
	ensEntrezIdList = {v:k for k, v in entrezEnsIdList.items()}
	with open(f, 'r') as foo:
		for line in foo:
			if line.startswith("#"): continue
			line = line.rstrip()
			if line.startswith("ENSG"):
				try:
					print line,"\t",ensEntrezIdList[line]
				except:
					print line,"\t","-"
			else:
				try:
					print line,"\t",entrezEnsIdList[line]
				except:
					print line,"\t","-"

def run():
	# storeEntrezID()
	idConvertion(sys.argv[1])

def help():
		if len(sys.argv) != 2:
			print "Description:"
			print "\tEntrez gene ID and Ensembl gene ID convertion"
			print "\tInput one file with one column entrez or ensembl ID"
			print "Usage:"
			print "\tpython %s entrezIDList.txt" %sys.argv[0]
			sys.exit(1)

def main():
	help()
	run()

if __name__ == "__main__":
	main()


