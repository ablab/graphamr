process PATHRACER {
    input:
    path graph
    path hmm

    output:
    path 'pathracer'

    publishDir "${params.outdir}", mode:params.publish_dir_mode

    script:
    """
    pathracer $hmm $graph --output pathracer --rescore -t $task.cpus
    """
}

process EXTRACT_ALL_EDGES {
    input:
    path pathracer_dir

    output:
    path 'all.edges.fa'

    script:
    """
    cp ${pathracer_dir}/all.edges.fa all.edges.fa
    """
}
