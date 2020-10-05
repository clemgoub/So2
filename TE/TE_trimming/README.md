# TE trimming

This tool is designed to trim TE consensus based on RepeatMasker hits coverage.
It looks for dips in coverage under mean-3*sd and split. A graph is provided to validate the decision.

## dependencies

- R
- bedtools

## Usage 


List the TE you want to trim in a file. The name MUST match the header name in the consensi file (fasta). I encourage the use of the "L" mode, even for one sequence (just add one sequence name to your input list)

```TE-trimmer.sh $1<H/L> $2<TE-header/TE-header-list (list of queries> $3<RepeatMasker.out> $4<TElib.fa (consensi)> $5<outputdir>```

Please email goubert.clement@gmail.com for help