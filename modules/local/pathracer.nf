// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process GET_NCBI_AMR_HMM {
    tag "NCBI AMRFinder HMM download"

    output:
    path "AMR.LIB", emit: hmm

    script:
    """
    wget https://ftp.ncbi.nlm.nih.gov/pathogen/Antimicrobial_resistance/AMRFinder/data/latest/AMR.LIB
    """
}

process CARD_AA {
    tag "CARD database download"

    output:
    path "protein_fasta_protein_homolog_model.fasta", emit: aa

    script:
    """
    wget https://card.mcmaster.ca/download/0/broadstreet-v3.1.3.tar.bz2
    tar -xjf broadstreet-v3.1.3.tar.bz2
    """
}

process PATHRACER {
    tag "$meta.id"

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::pathracer=3.15.0.dev" : null)

    input:
    tuple val(meta), path(graph)
    path  input
    val amino_acid

    output:
    tuple val(meta), path('*.all.edges.fa'), emit: all_edges
    tuple val(meta), path('*.log')         , emit: log

    script:
    def prefix      = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def type = amino_acid ? "--aa" : ""
    def component_size = params.component_max_size ? "--max-size ${params.component_max_size}" : ""


    """
    pathracer $input $graph --output ./ --rescore -t $task.cpus $component_size -E ${params.pathracer_e_value} $type
    mv pathracer.log ${prefix}.pathracer.log
    mv all.edges.fa ${prefix}.all.edges.fa
    """
}