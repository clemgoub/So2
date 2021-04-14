#! /bin/bash

# this script clusters repeats sequences and chooses the appropriate consensus sequence for each cluster (OTU)
# input a single multi-fasta file to merge different TE libraries, remove redundabcy and refine consensus.

# Authors: Jullien Flynn and Clément Goubert
# Changelog:
# v2.1 - Apr 2021, Clément Goubert: add cpu option and output dir
# v2 - Aug 2020, Clément Goubert: generalized from LTR to all TE in lib
# v1 - < Aug 2020, Jullien Flynn

# Parameters:
# $1 == concatenated fasta sequences
# $2 == output folder
# $3 == cpus

#date
d1=$(date +%s)
echo $1

# first cluster the sequences - shown to get them to the family level

# rename with line + leading zeros == consensus reference code
awk '/>/ {printf(">%09d\n",NR, $1)}; !/>/ {print $0}' $1 > $2/$1.2.fasta

# store the original TE name with new names if needed
paste <(awk '/>/ {printf(">%09d\n",NR)}' $1) <(grep '>' $1) > $2/consensi.input.names

# get the headers
cat $2/$1.2.fasta | grep '^>' | cut -f 2 -d '>' | awk -v OFS="\t" '{print $1,$1}' > $2/$1.names

# run mafft alignment -note, if using too much RAM, there is an alternative.
mafft --thread $3 $2/$1.2.fasta > $2/$1.aligned.fasta

# mothur first command
mothur "#dist.seqs(fasta=$2/$1.aligned.fasta, calc=onegap, countends=T, cutoff=0.20, processors=40)"

# now run clustering
mothur "#cluster(column=$2/$1.aligned.dist, name=$2/$1.names, method=nearest)"

# need to get the membership of the clusters.
mothur "#bin.seqs(list=$2/$1.aligned.nn.list, fasta=$2/$1.2.fasta, name=$2/$1.names, label=0.20)"

#attach the OTU number to the sequence
cat $2/$1.aligned.nn.0.*.fasta | sed 's/\t/-/g' > $2/$1.OTUs.fasta

#get the singletons - they will automatically be the consensus
cat $2/$1.OTUs.fasta | grep '^>' | sed 's/-/\t/g' | awk '{print $NF}' | uniq -c | awk '$1 == 1 {print $2}' > $2/singletons.OTUs

# grep the group
cat $2/$1.OTUs.fasta | grep '^>' | cut -f 2 -d '>' > $2/$1.OTUs.names # all seqs headers
grep -f $2/singletons.OTUs $2/$1.OTUs.names > $2/singleton_seqs # singl headers
grep -vf $2/singletons.OTUs $2/$1.OTUs.names | sed 's/>//g' > $2/refiner_candidates_seqs # redundants headers

# for non-singletons, run refiner. (join)
# perl line to INCLUDE sequences according to header. Works.
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/refiner_candidates_seqs $2/$1.OTUs.fasta > $2/refiner.candidates.fasta

# get the singleton sequences to combine with. perl to INCLUDE seqs according to header.
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/singleton_seqs $2/$1.OTUs.fasta > $2/singletons.fasta

# go through each OTU that has multiple members and run refiner
# get the OTU list
sed 's/-/\t/g' $2/refiner_candidates_seqs | cut -f 2 | sort | uniq > $2/refiner_Otus
# run refiner on each Otu using the script refiner.sh with Otu# as argument
cat $2/refiner_Otus | parallel -j $3 "../refiner.sh {}"

cat $2/*.refiner_cons singletons.fasta > $2/$1.clustered_refined_lib.fasta

rm $2/*.refiner.cons.fasta
rm $2/*refiner.stk
