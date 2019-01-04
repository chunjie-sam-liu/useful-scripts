#########################################################################
# File Name: download-annova.sh
# Author: Chun-Jie Liu
# Mail: chunjie-sam-liu@foxmail.com
# Created Time: Thu 20 Dec 2018 02:18:51 PM CST
#########################################################################
#!/bin/bash

download='/home/liucj/tools/annovar-201806/annotate_variation.pl -buildver hg38 -downdb -webfrom annovar'
path='/data/liucj/data/refdata/humandb-annovar-201812'

ref=('refGene' 'knownGene' 'ensGene' 'ljb26_all' 'dbnsfp30a' 'dbnsfp31a_interpro' 'dbnsfp33a' 'dbnsfp35a' 'dbscsnv11' 'intervar_20180118' 'cosmic70' 'esp6500siv2_ea' 'esp6500siv2_aa' 'esp6500siv2_all' 'exac03' 'gnomad_exome' 'gnomad_genome' 'kaviar_20150923' 'hrcr1' '1000g2015aug' 'gme' 'mcap' 'revel' 'avsnp150' 'nci60' 'clinvar_20180603' 'regsnpintron')

for i in ${ref[*]}
do 
  cmd="${download} ${i} ${path} &"
  echo ${cmd}
  eval ${cmd}
done

