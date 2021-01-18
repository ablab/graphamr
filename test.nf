#!/usr/bin/env nextflow

/*
 * Command : nextflow run test.nf --graph "path to graph" --output "path to output dir" --hmm "path to hmm"
 */

params.graph = "/Iceking/dshafranskaya/nf/*.gfa"
params.hmm = "/Iceking/dshafranskaya/nf/all.hmm"
params.outdir="/Iceking/dshafranskaya/nf/test"

nextflow.enable.dsl=2

/*
 * STEP 1 Pathracer
 */

process pathracer {

        publishDir "${params.outdir}/pathracer", mode: 'copy', overwrite: false
        input:
        path x
        output:
        path 'all.edges.fa'
        script:
      """
        pathracer ${params.hmm} $x --output ${params.output}/pathracer --rescore -t 16
        cp ${params.output}/pathracer/all.edges.fa all.edges.fa
        """
}
/*
 * STEP 2 Creating DB 
 */

process create_db {  
        publishDir "${params.output}/mmseqs", mode: 'copy'
        input:
        path y
        output:
        path 'all.edges.db'
        path 'all.edges.db.index'
        path 'all.edges.db_h'
        path 'all.edges.db_h.index'
        path 'all.edges.db.dbtype'
        script:
        """
        mmseqs createdb $y all.edges.db
        """
}

/*
 * STEP 3 Extracting orfs
 */

process extract_orf {
        publishDir "${params.output}/mmseqs_orfs", mode: 'copy'
        input:
        path x
        path y
        path a
        path b
        path c
        output:
        path 'all.edges.orfs.db'
        path 'all.edges.orfs.db.index'
        path 'all.edges.orfs.db_h'
        path 'all.edges.orfs.db_h.index'
        script:
        """
        mmseqs extractorfs $x all.edges.orfs.db
        """
}
/*
 * STEP 4 Creating FASTA file with orfs
 */
process create_fasta {
        publishDir "${params.outdir}/mmseqs_orfs", mode: 'copy'
        input:
        path x
        path y
        path a
        path b
        output:
        path 'all.orfs.fasta'
        script:
        """
        mmseqs convert2fasta $x all.orfs.fasta
        """
}
/*
 * STEP 5 Clustering orfs
 */
process clustering_orfs {
        publishDir "${params.outdir}/mmseqs_clustering", mode: 'copy'
        input:
        path x
        output:
        path 'cluster_Res_rep_seq.fasta'
        script:
        """
        mmseqs easy-linclust $x cluster_Res tmp --min-seq-id 0.9
        """
}
/*
 * STEP 6 Abricate
 */
process abricate {
        publishDir "${params.outdir}/abricate", mode: 'copy', pattern: 'summary.tsv' , saveAs : {"summary.tsv"}
        input:
        path x
        output:
        path 'summary.tsv'
        script:
        """
            abricate -db ncbi cluster_Res_rep_seq.fasta > rep_seq.tsv
        abricate --summary rep_seq.tsv > summary.tsv
        """
}
workflow {
        //data=Channel.fromFilePairs(params.graph)
        pathracer(params.graph) | create_db | extract_orf | create_fasta | clustering_orfs | abricate
}
