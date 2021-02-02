process SPADES {

    input:
    tuple val (id) , path (reads)

    output:
    path 'assembly_graph_with_scaffolds.gfa', emit : graph

    publishDir "${params.outdir}/spades", mode:'copy'


    script:
    def input_reads = params.single_end ? "-s $reads" : "-1 ${reads[0]} -2 ${reads[1]}"
    """
    spades.py --meta -t $task.cpus $input_reads -o ./
    """
}

