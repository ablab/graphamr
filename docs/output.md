# ablab/graphamr: Output

## Introduction

This document describes the output produced by the pipeline. 

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

<!-- TODO nf-core: Write this documentation describing your workflow's output -->

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/)
and processes data using the following steps:


* [FastQC](#fastqc) - Read quality control
* [metaSPAdes](#metaspades) - Assembly metagenome and building graph 

The first two steps are required only if the reads are used

* [Pathracer](#pathracer) - Aligning HMM profile to graph
* [MMseqs2](#mmseqs2) - Detection and clustering ORFs
* [Abricate](#abricate) - Annotation representative sequences
* [RGI](#rgi) - Annotation representative sequences
* [sraX](#srax) - Annotation representative sequences
* [hAMRonization](#hamronization) - Summarizing results
* [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

## FastQC

[FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) gives general quality metrics about your sequenced reads. It provides information about the quality score distribution across your reads, per base sequence content (%A/T/G/C), adapter contamination and overrepresented sequences.

For further reading and documentation see the [FastQC help pages](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/).

**Output files:**

* `fastqc/`
  * `*_fastqc.html`: FastQC report containing quality metrics for your untrimmed raw fastq files.
* `fastqc/zips/`
  * `*_fastqc.zip`: Zip archive containing the FastQC report, tab-delimited data file and plot images.


## metaSPAdes

[metaSPAdes](https://github.com/ablab/spades)  is an de Bruijn graph-based assembly tool.

**Output files:**

* `spades/`
  * `*.assembly.gfa`: SPAdes assembly graph and scaffolds paths in GFA 1.0 format
  * `*.contigs.fa`: resulting contigs
  * `*.scaffolds.fa`: resulting scaffolds
  * `*.spades.log`: SPAdes log


## Pathracer

[Pathracer](https://cab.spbu.ru/software/pathracer/) is a novel standalone tool that aligns profile HMM directly to the assembly graph. The tool provides the set of most probable paths traversed by a HMM through the whole assembly graph, regardless whether the sequence of interested is encoded on the single contig or scattered across the set of edges, therefore significantly improving the recovery of sequences of interest even from fragmented metagenome assemblies.

**Output files:**

* `pathracer/`
  * `*.all.edges.fa`: unique edge paths for all pHMMs in one file
  * `*.pathracer.log`: log file

## MMseqs2

[MMseqs2](https://github.com/soedinglab/MMseqs2) is a software suite to search and cluster huge protein and nucleotide sequence sets. The `extractorfs` module uses to detect all open reading frames (ORFs) on all six frames. For clustering `easy-linclust` module are used. 

**Output files:**

* `orfs/`
  * `*.all_orfs.fasta`: all open reading frames (ORFs) on all six frames in one file
  * `*.orfs_rep_seq.fasta`: representative sequences

## Abricate

[Abricate](https://github.com/tseemann/abricate) is used for mass screening of contigs for antimicrobial resistance or virulence genes. Please see the [Abricate docs](https://github.com/tseemann/abricate/blob/master/README.md) for more detailed information regarding the output files.

**Output files:**

* `abricate/`
  * `*.rep_seq.tsv`: a tap-separated output file with results
  * `all.summary.tsv`: representative sequences

## RGI 

[RGI](https://github.com/arpcard/rgi) is used to predict resistome(s) from protein or nucleotide data based on homology and SNP models. The application uses reference data from the [Comprehensive Antibiotic Resistance Database (CARD).](https://card.mcmaster.ca/) Please see the [RGI docs](https://github.com/arpcard/rgi#rgi-main-tab-delimited-output-details) for more detailed information regarding the output files.

**Output files:**

* `rgi/`
  * `*.json`: json format file with results
  * `*.txt`: a tap-separated output file with results
  * `*.png`: a heat map from pre-compiled RGI main JSON files, samples and AMR genes organized alphabetically

## sraX

[sraX](https://github.com/lgpdevtools/sraX) is used to systematically detect the presence of AMR determinants and, ultimately, describe the repertoire of antibiotic resistance genes (ARGs) within a collection of genomes (the “resistome” analysis).

**Output files:**

* `rgi/`
  * `Results/`: directory containing HTML report, plots and summary files

## hAMRonization

[hAMRonization](https://github.com/pha4ge/hAMRonization) is used to combine and summarize the results. 

**Output files:**

* `hamronize/`
  * `*_abricate_hamronized.tsv`: a tab-separated abricate report
  * `*_rgi_hamronized.tsv`: a tab-separated rgi report
  * `amr_summary.tsv`: general report
  * `amr_summary.html`: general HTML report

## Pipeline information

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.

**Output files:**

* `pipeline_info/`
  * Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  * Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.csv`.
  * Documentation for interpretation of results in HTML format: `results_description.html`.
