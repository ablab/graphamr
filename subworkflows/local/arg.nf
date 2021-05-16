include { ABRICATE; ABRICATE_SUMMARIZE } from '../../modules/local/abricate'
include { SRAX } from '../../modules/local/srax'
include { RGI; RGI_HEATMAP } from '../../modules/local/rgi'

workflow ARG {
    take:
    fasta         // channel: [ val(meta), [ fasta ] ]

    main:
    ABRICATE(fasta)
    ABRICATE.out.report.collect{ it[1] } | ABRICATE_SUMMARIZE

    SRAX(fasta.collect { it[1] })

    RGI(fasta)
    RGI.out.json.collect{ it[1] } | RGI_HEATMAP

    emit:
    summary  = ABRICATE_SUMMARIZE.out.summary  // channel: [ summary ]
    out_srax = SRAX.out.result
    heatmap = RGI_HEATMAP.out.heatmap
}    
