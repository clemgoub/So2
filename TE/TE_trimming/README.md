# TE trimming

This tool is designed to trim TE consensus based on RepeatMasker hits coverage.
It looks for dips in coverage (< 5% mean coverage) and split. A graph is provided to validate the decision.

## dependencies

- R
- bedtools
- samtools

## Input requirement

- TE header (`H` mode) or list of TE headers (`L` mode) as spelled in the TE consensus (reference) file
- TE consensus (reference) file (`.fasta`) used as library for `RepeatMasker` 
- RepeatMasker `.out` output file (typically `genome.fasta.out`)

## Usage 

In this example, the TE consensus file (`<TE-consensus-lib.fa>`) looks like this:

```
>TENAME#Class/Superfamily [info info]
ACTAGACTACG...
>TENAME2#Class2/Superfamily2 [info info]
TGCATACCAGA...
```

If you are investigating a single TE consensus, use the `H` (header) mode

```TE-trimmer.sh H TENAME#Class/Superfamily <genome.fasta.out> <TE-consensus-lib.fa> <outputdir>```

Or if you want to run the analysis inbatch, list the TE you want to trim in a file. 

```
TE-trimmer.sh L <TE-header/TE-header-list> <genome.fasta.out> <TE-consensus-lib.fa> <outputdir>
```

with `TE-header-list`:

```
TENAME#Class/Superfamily
TENAME2#Class2/Superfamily2
```

The trimmed TE and graphs will be written in the `outputdir` 

---
Support: please email goubert.clement@gmail.com
