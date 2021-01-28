process ABRICATE {
    input:
    path fasta

    output:
    tuple path('summary.tsv'), path('rep_seq.tsv')

    publishDir "${params.outdir}/abricate", mode:params.publish_dir_mode

    script:
    """
    abricate -db ${params.abricate_db} $fasta --threads $task.cpus --minid ${params.abricate_minid} --mincov ${params.abricate_mincov} > rep_seq.tsv
    abricate --summary rep_seq.tsv > summary.tsv
    """
}
