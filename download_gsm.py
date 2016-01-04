#!/usr/bin/python
#-*- coding:utf-8 -*-
################################################
#File Name: download_gsm.py
#Author: C.J. Liu
#Mail: samliu@hust.edu.cn
#Created Time: Wed 11 Nov 2015 02:52:14 PM CST
################################################


import os,sys
import urllib
import re
from bs4 import BeautifulSoup as bs


def geturl(gsm):
	url = "http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=" + gsm
	try:
		os.mkdir('html')
	except:
		print 'exist'
	os.system('wget -O html/%s %s &' %(gsm, url))

def gethtml(gsm):
	
	f = 'html/' + gsm
	soup = bs(open(f),'lxml')
	# print soup.input
	for it in soup.find_all('input'):
		if 'fulltable' == it['name']:
			click = it['onclick']
			downloaddata(click,gsm)
			
def downloaddata(onclick,gsm):
	location = onclick.split('\'')[1]
	url='http://www.ncbi.nlm.nih.gov' + location
	# print url
	if not os.path.exists('result'):
		os.mkdir('result')
	os.system('wget -O result/%s.tmp "%s"' %(gsm, url))
	os.system('grep -v  "<" result/%s.tmp |grep -v ">" |grep -v "#" |grep -v "GEO Accession viewer"|grep -v ^$ >result/%s' %(gsm, gsm))
	os.system('rm result/*.tmp')
	
	
	
def run(f):
	with open(f, 'r') as foo:
		for gsm in foo:
			gsm = gsm.rstrip()
			geturl(gsm)
			gethtml(gsm)
			print 'Done'
			
			
	


if __name__ =="__main__":
	run(sys.argv[1])



