// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process ABRICATE {
    tag "$meta.id"

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }
    
    conda (params.enable_conda ? "bioconda::abricate=1.0.1" : null)
    
    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('*.tsv'), emit: report

    script:
    def prefix  = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def datadir = params.abricate_datadir ? "--datadir ${params.abricate_datadir}" : ""
    """
    [ ! -f  ${prefix}.fasta ] && ln -s $fasta ${prefix}.fasta
    abricate -db ${params.abricate_db} ${prefix}.fasta --threads $task.cpus --minid ${params.abricate_minid} --mincov ${params.abricate_mincov} $datadir  > ${prefix}.tsv
    extract_gene_fasta.py ${prefix}.tsv $fasta
    """
}

process ABRICATE_SUMMARIZE {
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }
   
    conda (params.enable_conda ? "bioconda::abricate=1.0.1" : null)

    input:
    path('?.tsv')

    output:
    path('all.summary.tsv'), emit: summary

    script:
    """
    abricate --summary *.tsv > all.summary.tsv
    """
}