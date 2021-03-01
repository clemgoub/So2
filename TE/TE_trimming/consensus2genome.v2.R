#! /bin/Rscript
#######################################################################################
### consensus2genome - v2 - Clement Goubert (2020) - goubert.clement@gmail.com      ###
#######################################################################################

# RM 
# TE = TE name
# Lib = TE.consensi.fa

consensus2genome=function(TE=NULL, # TE name (character)
                          RM=NULL , # RepeatMasker .out (file path)
                          Lib=NULL, # Fasta library containing consensus TE sequences (file path)
                          evalue=10e-8, # default e-value threshold for blast
                          FL_thresh=0.9, # threshold to report putative full-length insertion
                          alpha=0.3, # transparency of mapped hits [0-1]
                          full_alpha=1, # transparency of full-length hits [0-1] 
                          auto_y=T, # automatic Y scaling
                          cover=T, # compute and plot coverage
                          covcol="blue"){

  par(mfrow=c(1,2)) # set window before anything else
  
  if(is.null(TE)){print('query TE not specified (string)')}
  if(is.null(Lib)){print('TE consensi file not specified (fasta)')}
  if(is.null(RM)){print('RepeatMasker .out file not specified (RM format)')}

#TE consensus size
cons_len=as.numeric(system(paste("./getlength.sh", Lib, as.character(TE), sep=" "), intern = TRUE))

# pull the RM output
blast=read.table(text=system(paste("grep -w $(echo", TE, " | sed 's/#/\t/g' | cut -f 1)", RM ,"| sed 's/)//g;s/(//g' | awk '{print $10, $11, $12, $13, $14, $2, $9}'", sep = " "), intern=TRUE))
# toss those with consensus shorter than hit (RM bug)
keep=(blast$V3 <= cons_len && blast$V4 <= cons_len)
blast=blast[,keep]
#return(blast)
#plot the copies vs divergence
source("c2g.copydiv.R", local = T, echo = T)

#compute and plot coverage with suggested
source("c2g.coverage.R", local = T, echo = T)                                                                   

}# Whole function
