include { MMSEQS_DB; MMSEQS_EXTRACT_ORFS; MMSEQS_CLUSTER } from '../../modules/local/mmseqs' addParams(options: [:])

workflow CLUSTER_ORFS {
    take:
    fasta         // channel: [ val(meta), [ fasta ] ]

    main:
    MMSEQS_DB(fasta) | MMSEQS_EXTRACT_ORFS | MMSEQS_CLUSTER

    emit:
    orfs_rep_seq  = MMSEQS_CLUSTER.out.orfs_rep_seq  // channel: [ val(meta), [ orfs_rep_seq ] ]
}
