**Antimicrobial Resistance Gene Detection from Metagenome Assembly Graphs**.

[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A520.04.0-brightgreen.svg)](https://www.nextflow.io/)

[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg)](https://bioconda.github.io/)

## Introduction

**ablab/graphamr** is a bioinformatics best-practise analysis pipeline for recovery and identification of antibiotic resistance genes from fragmented metagenomic assemblies. The pipeline involves the alignment of profile hidden Markov models of target genes directly to the assembly graph of a metagenome with further dereplication and annotation of the results using state-of-the art tools. The pipeline supports reads or assembly graph as input. For reads the pipeline does quality control and assembles metagenome and builds graph.    

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It comes with docker containers making installation trivial and results highly reproducible. The Nextflow DSL2 implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies.

## Quick Start

1. Install [`nextflow`](https://nf-co.re/usage/installation)

2. Install any of [`Conda`](https://conda.io/miniconda.html) for full pipeline reproducibility 

3. Download the pipeline and test it on a minimal dataset with a single command:

    ```bash
    nextflow run ablab/graphamr -profile test,<conda>
    ```

4. Start running your own analysis!
    > Typical command for analysis using reads:

    ```bash
    nextflow run ablab/graphamr -profile <conda> --reads '*_R{1,2}.fastq.gz' --hmm '*.HMM'
    ```

    > Typical command for analysis using graph:

    ```bash
    nextflow run ablab/graphamr -profile <conda> --graph '*.gfa' --hmm '*.HMM'
    ```



See [usage docs](docs/) for all of the available options when running the pipeline.

## Pipeline Summary

Optionally, if raw reades are used:

<!-- TODO nf-core: Fill in short bullet-pointed list of default steps of pipeline -->

* Sequencing quality control (`FastQC`)
* Assembly metagenome and building graph (`metaSPAdes`)

By default, the pipeline currently performs the following:

* Aligning HMM profile to graph (`Pathracer`)
* Detection and clustering ORFs (`MMseqs2`)
* Annotation representative sequences (`Abricate, RGI, sraX`)
* Summarizing results (`hAMRonization`)


## Documentation

The nf-core/graphamr pipeline comes with documentation about the pipeline: [usage](docs/usage.md) and [output](docs/output.md).

<!-- TODO nf-core: Add a brief overview of what the pipeline does and how it works -->

## Credits

graphamr was originally written by Daria Shafranskaya, Anton Korobeynikov.



<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

