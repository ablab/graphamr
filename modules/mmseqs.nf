process MMSEQS_DB {
    input:
    path fasta

    output:
    path "mmseqs_db"

    if (params.save_mmseqs) {
        publishDir "${params.outdir}", mode:params.publish_dir_mode
    }

    script:
    """
    mmseqs createdb $fasta mmseqs.db
    mkdir mmseqs_db && mv mmseqs.db* mmseqs_db
    """
}

process EXTRACT_ORFS {
    input:
    path mmseqs_db

    output:
    path "mmseqs_orf_db"

    if (params.save_mmseqs) {
        publishDir "${params.outdir}", mode:params.publish_dir_mode
    }

    script:
    """
    mmseqs extractorfs $mmseqs_db/mmseqs.db mmseqs.orf.db --threads $task.cpus
    mkdir mmseqs_orf_db && mv mmseqs.orf.db* mmseqs_orf_db
    """
}

process EXTRACT_ORF_FASTA {
    input:
    path mmseqs_orf_db

    output:
    path 'all_orfs.fasta'

    publishDir "${params.outdir}/orfs", mode:params.publish_dir_mode

    script:
    """
    mmseqs convert2fasta $mmseqs_orf_db/mmseqs.orf.db all_orfs.fasta
    """
}

process MMSEQS_CLUSTER {
    input:
    path fasta

    output:
    path 'orfs_rep_seq.fasta'

    publishDir "${params.outdir}/orfs", mode:params.publish_dir_mode

    script:
    """
    mmseqs easy-linclust $fasta orfs tmp --min-seq-id ${params.cluster_idy}
    """
}
process CHANGE_NAME {
    input:
    path fasta

    output:
    path 'orfs_rep_seq_new.fasta'

    publishDir "${params.outdir}/orfs", mode:params.publish_dir_mode

    script:
    """
    change_name.py $fasta orfs_rep_seq_new.fasta
    """
}
