#!/usr/bin/python
#-*- coding:utf-8 -*-
################################################
#File Name: sortChromosomeAndPosition.py
#Author: C.J. Liu
#Mail: samliu@hust.edu.cn
#Created Time: Mon 16 May 2016 03:50:08 PM CST
################################################

import os ,sys

def usage():
	if len(sys.argv) != 2 and len(sys.argv) != 4 :
		print ("Description:")
		print ("\tSort file by chromosome and position as chr1, chr2...")
		print ("Usage:")
		print ("\tpython %prog inputFile chromField positionField (default chrom and position is first two colunm)")
		print ("Example:")
		print ("\tpython %prog hello.world 1 2")
		sys.exit(1)
	
	
def sortFile(f, chrom = 1, position = 2):
	ofile = open(f + ".sortByChrom", 'a')
	sortOrder = ["chr" + str(i) for i in range(1,23)] + ["chrX","chrY", "chrM"]
	for c in sortOrder:
		posList = list()
		lineList = list()
		with open(f, 'r') as foo:
			for line in foo:
				line = line.rstrip()
				arr = line.split("\t")
				if arr[chrom - 1] != c:continue
				posList.append(int(arr[position - 1]))
				lineList.append(line)
			posListSort = sorted(range(len(posList)), key = lambda k : posList[k])
			for index in posListSort:
				ofile.write(lineList[index] + os.linesep)
			
			
			

def run():
	usage()
	if len(sys.argv) == 2:
		sortFile(sys.argv[1])
	else:
		sortFile(sys.argv[1], chrom = int(sys.argv[2]),position = int(sys.argv[3]))

def main():
	run()

if __name__ == "__main__":
	main()
