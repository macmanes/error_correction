#!/bin/bash

#Commands for producing error corrected reads

#Trimmomatic available at: http://www.usadellab.org/cms/index.php?page=trimmomatic
#Reptile available at: http://aluru-sun.ece.iastate.edu/doku.php?id=reptile
#Trinity available at: http://trinityrnaseq.sourceforge.net/

######Trim reads with Trimmomatic
java -jar -Xmx10g trimmomatic-0.30.jar PE -phred33 -threads 32 \
left.fq \
right.fq \
left.pp.fastq \
left.up.fastq \
right.pp.fastq \
right.up.fastq \
ILLUMINACLIP:barcodes.fa:2:40:15 \
LEADING:5 TRAILING:5 SLIDINGWINDOW:4:5 MINLEN:25

######Cat everything together for prep for Reptile Correction
cat left.pp.fastq left.up.fastq > data/left.fastq
cat right.pp.fastq right.up.fastq > data/right.fastq

######Do Reptile Correction
perl ~/reptile-v1.1/reptile-v1.1/utils/fastq-converter-v2.0.pl data/ data/ 1 #files MUST have fastq extension
sed -i 's_[0-9]$_&/1_' data/left.fa #add /1 to ID reads as left
sed -i 's_[0-9]$_&/2_' data/right.fa #add /2 to ID reads as right
sed -i 's_^>.*[0-9]$_&/1_' data/left.q
sed -i 's_^>.*[0-9]$_&/2_' data/right.q
cat data/left.fa data/right.fa > data/both.fa
cat data/left.q data/right.q > data/both.q
seq-analy config.analy #Follow Reptile README for instructions on how to optimize parameters
reptile-omp config.analy #Do error corection
reptile_merger data/both.fa data/both.reptile.err ./both.reptile.corr.fa #make error corrected fasta file

######Split file back into left and right fastq's
grep -aA1 '/1' both.reptile.corr.fa > both.left.rept.corr.fa
grep -aA1 '/2' both.reptile.corr.fa > both.right.rept.corr.fa
