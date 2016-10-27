#Useful scripts
Downloadsra is to download SRA data by SRR ID in batch

##Add miRNA2target data and script
miRNA2target.dict.picke and target2miRNA.dict.pickle are the comprehensive miRNA target data we collected from main miRNA database with experimently validated or predicted target. We can use find.py to find corresponding target.

##Add `get_sequence_by_mir_name.py`
Use Bio.SeqIO to extract miRNA sequence from mature.fa downloaded from miRBase.  
It's stupid that it doesn't use regular expression but extact to match miRNA ID. The result file will named `input_miRNA_ID_list.fasta`.

##Add `findMotifByHand.py`
Find motif by hand.

##Add `Han Server`
New server address

##Add `sortChromosomeAndPosition.py`
Sort human vcf, bed, gff, gtf files in chromsome order.
