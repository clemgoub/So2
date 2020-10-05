#! /bin/bash

# $1 == {1} (Otu#)
echo "$1"
# grab the sequences headers of the Otu
headers=$(grep "$1" refiner.candidates.fasta | sed 's/>//g')
echo "$headers"
# extract the sequences
perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' <(echo "$headers") refiner.candidates.fasta > $1.refiner.fasta
# run refiner
perl Refiner $1.refiner.fasta
