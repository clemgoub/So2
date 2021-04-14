#! /bin/bash

# this script clusters repeats sequences and chooses the appropriate consensus sequence for each cluster (OTU)
# input a single multi-fasta file to merge different TE libraries, remove redundabcy and refine consensus.

# Authors: Jullien Flynn and Clément Goubert
# Changelog:
# v2.1 - Apr 2021, Clément Goubert: add cpu option and output dir
# v2 - Aug 2020, Clément Goubert: generalized from LTR to all TE in lib
# v1 - < Aug 2020, Jullien Flynn

# Parameters:
# $filename == concatenated fasta sequences
# $2 == output folder
# $3 == cpus

#date
d1=$(date +%s)
filename=$(sed 's/\//\t/g' | awk '{print $NF}')
echo $filename
echo $filename
mkdir -p $2

# first cluster the sequences - shown to get them to the family level

# rename with line + leading zeros == consensus reference code
awk '/>/ {printf(">%09d\n",NR, $filename)}; !/>/ {print $0}' $1 > $2/$filename.2.fasta

# store the original TE name with new names if needed
paste <(awk '/>/ {printf(">%09d\n",NR)}' $1) <(grep '>' $1) > $2/consensi.input.names

# get the headers
cat $2/$filename.2.fasta | grep '^>' | cut -f 2 -d '>' | awk -v OFS="\t" '{print $filename,$filename}' > $2/$filename.names

# run mafft alignment -note, if using too much RAM, there is an alternative.
mafft --thread $3 $2/$filename.2.fasta > $2/$filename.aligned.fasta

# mothur first command
mothur "#dist.seqs(fasta=$2/$filename.aligned.fasta, calc=onegap, countends=T, cutoff=0.20, processors=40)"

# now run clustering
mothur "#cluster(column=$2/$filename.aligned.dist, name=$2/$filename.names, method=nearest)"

# need to get the membership of the clusters.
mothur "#bin.seqs(list=$2/$filename.aligned.nn.list, fasta=$2/$filename.2.fasta, name=$2/$filename.names, label=0.20)"

#attach the OTU number to the sequence
cat $2/$filename.aligned.nn.0.*.fasta | sed 's/\t/-/g' > $2/$filename.OTUs.fasta

#get the singletons - they will automatically be the consensus
cat $2/$filename.OTUs.fasta | grep '^>' | sed 's/-/\t/g' | awk '{print $NF}' | uniq -c | awk '$filename == 1 {print $2}' > $2/singletons.OTUs

# grep the group
cat $2/$filename.OTUs.fasta | grep '^>' | cut -f 2 -d '>' > $2/$filename.OTUs.names # all seqs headers
grep -f $2/singletons.OTUs $2/$filename.OTUs.names > $2/singleton_seqs # singl headers
grep -vf $2/singletons.OTUs $2/$filename.OTUs.names | sed 's/>//g' > $2/refiner_candidates_seqs # redundants headers

# for non-singletons, run refiner. (join)
# perl line to INCLUDE sequences according to header. Works.
perl -ne 'if(/^>(\S+)/){$c=$i{$filename}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/refiner_candidates_seqs $2/$filename.OTUs.fasta > $2/refiner.candidates.fasta

# get the singleton sequences to combine with. perl to INCLUDE seqs according to header.
perl -ne 'if(/^>(\S+)/){$c=$i{$filename}}$c?print:chomp;$i{$_}=1 if @ARGV' $2/singleton_seqs $2/$filename.OTUs.fasta > $2/singletons.fasta

# go through each OTU that has multiple members and run refiner
# get the OTU list
sed 's/-/\t/g' $2/refiner_candidates_seqs | cut -f 2 | sort | uniq > $2/refiner_Otus
# run refiner on each Otu using the script refiner.sh with Otu# as argument
cat $2/refiner_Otus | parallel -j $3 "../refiner.sh {}"

cat $2/*.refiner_cons singletons.fasta > $2/$filename.clustered_refined_lib.fasta

rm $2/*.refiner.cons.fasta
rm $2/*refiner.stk
