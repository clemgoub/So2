#!/bin/bash
#################################
# RM.out to gff3 with Colors!!! #
#################################
#Author: Clément Goubert
#Date created: 08-18-2020
#
# ***Changelog***
#
# - v1.2   03-29-2021 #  CURRENT (adds Maverick and Crypton in separate subclass)
# - v1.1   01-18-2021 # (add Penelope and DIRS as separate colors)
# - v1.    08-18-2020
# 
#################################
#
# arguments:
# $1 = RM.out

 
 #SALMON
Low_complexitycol="#d1d1e0" #blue/gray
Satellitecol="#ff99ff" #PINK
Simple_repeatcol="#8686ac" #darker blue/gray
Unknowncol="#f2f2f2" #pale grey

if [[ $1 == "" ]]; then
echo "no input provided (RepeatMasker ".out" file)"
echo "USAGE: ./rm2gff3.sh RM.out"
else 

#awk 'NR > 3 {print $5"\tRepeatMasker-4.0.1\tsimilarity\t"$6"\t"$7"\t"$1"\t"$9"\t.\tTarget="$10" "$11" "$12" "$13" "$14";Div="$2";Del="$3";Ind="$4}' $1 |\
awk 'NR > 3 {print $5"\tRepeatMasker-4.0.1\tsimilarity\t"$6"\t"$7"\t"$1"\t"$9"\t.\tTarget="$10" "$11" "$12" "$13" "$14"\tDiv="$2";Del="$3";Ins="$4";SWscore="$1}' $1 |\
sed 's/\tC\t/\t-\t/g;s/DNA/TIR/g;s/TIR\/Maverick/MAV\/Maverick/g;s/TIR\/Crypton/CRY\/Crypton/g' |\
awk '{if ($7 == "+") {print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9" "$10" "$11" "$12";"$NF} else {print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9" "$10" "$13" "$12";"$NF}}' |\
awk -v LINEcol="#3399ff" \
	-v SINEcol="#800080" \
	-v TIRcol="#ff6666" \
	-v LTRcol="#00cc44" \
	-v RCcol="#ff6600" \
	-v Low_complexitycol="#d1d1e0" \
	-v Satellitecol="#ff99ff" \
	-v Simple_repeatcol="#8686ac" \
	-v PLEcol="#b2edba" \
	-v DIRScols="#fce7bd" \
	-v CRYcols="#8f1800" \
	-v MAVcols="#669999" \
	-v Unknowncol="#c9c9c9" \
'BEGIN {print "\#\#gff-version 3"}; \
/LINE\// {print $0";color="LINEcol} \
/SINE\// {print $0";color="SINEcol} \
/TIR\// {print $0";color="TIRcol} \
/LTR\// {print $0";color="LTRcol} \
/RC\// {print $0";color="RCcol} \
/Low_complexity/ {print $0";color="Low_complexitycol} \
/Satellite/ {print $0";color="Satellitecol} \
/Simple_repeat/ {print $0";color="Simple_repeatcol} \
/Penelope/ {print $0";color="PLEcol} \
/DIRS/ {print $0";color="DIRScols} \
/CRY/ {print $0";color="CRYcols} \
/MAV/ {print $0";color="MAVcols} \
!/LINE\// && !/SINE\// && !/TIR\// && !/LTR\// && !/RC\// && !/Low_complexity/ && !/Satellite/ && !/Simple_repeat/ && !/Penelope/ && !/DIRS/ && !/CRY/ && !/MAV/ {print $0";color="Unknowncol}' 

fi
