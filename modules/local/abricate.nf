// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process ABRICATE {
    tag "$meta.id"

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('*.summary.tsv'), emit: summary
    tuple val(meta), path('*.rep_seq.tsv'), emit: rep_seq

    script:
    def prefix  = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def datadir = params.abricate_datadir ? "--datadir ${params.abricate_datadir}" : ""
    """
    abricate -db ${params.abricate_db} $fasta --threads $task.cpus --minid ${params.abricate_minid} --mincov ${params.abricate_mincov} $datadir  > ${prefix}.rep_seq.tsv
    abricate --summary ${prefix}.rep_seq.tsv > ${prefix}.summary.tsv
    extract_gene_fasta.py ${prefix}.rep_seq.tsv $fasta
    """
}

process ABRICATE_SUMMARIZE {
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }
    
    input:
    path('*.rep_seq.tsv')

    output:
    path('all.summary.tsv'), emit: summary

    script:
    """
    abricate --summary *.rep_seq.tsv > all.summary.tsv
    """
}
