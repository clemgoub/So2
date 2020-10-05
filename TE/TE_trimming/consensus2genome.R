#! /bin/Rscript
#######################################################################################
### consensus2genome - v2 - Clement Goubert (2020) - goubert.clement@gmail.com      ###
### ------------------------------------------------------------------------------- ###
### This R function blast a TE consensus against a reference genome and then plots  ###
### the genomic fragments found relative to the consensus sequence                  ###
### see https://github.com/clemgoub/consensus2genome for the full documentation     ###
### to use, copy and paste the following code into a R console                      ###
### USAGE: consensus2genome(query, db , ...)                                        ###
### query: path to query (fasta file)                                               ###
### db: path to blast db (blast formated nucleotide database)                       ###
#######################################################################################
#
# Changelog V1 --> V2 | 03.13.2020
# Add a second graph with suggested cut points
# 
# V2=alpha | not for release
# TO FIX: trace the coverage on the left graph
# TO DO: convert breakpoints to bed for getfasta


query="../Sitophilus/So2.10-2019/reference_genome/GCF_002938485.1_Soryzae_2.0_genomic.fna"
db="tandem.fasta"
TE="testseq"
evalue=10e-8 
FL_thresh=0.9 
alpha=0.3
full_alpha=1 
auto_y=T 


  blast=read.table(text=system(paste("blastn -query", query, "-db", db , "-evalue", evalue, "-outfmt 6 | sed 's/#/-/g'"), intern = TRUE))
  #TE consensus size
  cons_len=as.numeric(system(paste("./getlength.sh", as.character(db), as.character(TE), sep=" "), intern = TRUE))
  #list of almost full length fragments
  full=blast[abs(blast$V9-blast$V10) >= FL_thresh*as.numeric(cons_len),]
  #graph
  par(mar=c(2.5,2.5,2.5,2.5))
  plot(range(0, cons_len), range(0, max(100-blast$V3)), type = "n", main=paste("TE: ", as.character(blast[1,1]), "\n consensus size: ", as.character(cons_len), "bp; fragments: ", as.character(length(blast$V1)), "; full length: ", as.character(length(full$V1))," (>=",as.character(as.numeric(FL_thresh)*100),"%)", sep = ""), cex.main = 0.9, xlab = "TE consensus (bp)", ylab = "divergence to consensus (%)")
  for(i in 1:length(blast$V1)){
    segments(blast$V9[i], 100-blast$V3[i], blast$V10[i], 100-blast$V3[i], col=rgb(0,0,0,alpha=alpha))
  }
  for(i in 1:length(blast$V1)){
    segments(full$V9[i], 100-full$V3[i], full$V9[i], 100-full$V3[i], col=rgb(1,0,0, alpha=full_alpha), lwd=1.5)
  }

 