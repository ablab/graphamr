// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process MMSEQS_DB {
    tag "$meta.id"

    input:
    tuple val(meta), path(fasta)
    
    output:
    tuple val(meta), path('*.mmseqs_db'), emit : mmseqs_db

    if (params.save_mmseqs) {
        publishDir "${params.outdir}",
            mode: params.publish_dir_mode,
            saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }
    }

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    mmseqs createdb ${fasta} mmseqs.db
    mkdir ${prefix}.mmseqs_db && mv mmseqs.db* ${prefix}.mmseqs_db
    """
}

process EXTRACT_ORFS {
    tag "$meta.id"

    input:
    tuple val(meta), path(mmseqs_db)

    output:
    tuple val(meta), path('*.mmseqs_orf_db'), emit: mmseqs_orf_db

    if (params.save_mmseqs) {
        publishDir "${params.outdir}",
            mode: params.publish_dir_mode,
            saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }
    }

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    mmseqs extractorfs $mmseqs_db/mmseqs.db mmseqs.orf.db --threads $task.cpus
    mkdir ${prefix}.mmseqs_orf_db && mv mmseqs.orf.db* ${prefix}.mmseqs_orf_db
    """
}

process EXTRACT_ORF_FASTA {
    tag "$meta.id"

    input:
    tuple val(meta), path(mmseqs_orf_db)

    output:
    tuple val(meta), path('*.all_orfs.fasta')

    publishDir "${params.outdir}/orfs",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    mmseqs convert2fasta $mmseqs_orf_db/mmseqs.orf.db ${prefix}.all_orfs.fasta
    """
}

process MMSEQS_CLUSTER {
    tag "$meta.id"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('*.orfs_rep_seq.fasta')

    publishDir "${params.outdir}/orfs",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    mmseqs easy-linclust $fasta orfs tmp --min-seq-id ${params.cluster_idy}
    change_name.py orfs_rep_seq.fasta ${prefix}.orfs_rep_seq.fasta
    """
}