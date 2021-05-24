include { ABRICATE; ABRICATE_SUMMARIZE } from '../../modules/local/abricate'
include { SRAX } from '../../modules/local/srax'
include { RGI; RGI_HEATMAP } from '../../modules/local/rgi'
include { HAMRONIZE_RGI; HAMRONIZE_ABRICATE; HAMRONIZE_SUMMARIZE } from '../../modules/local/hamronization'

workflow ARG {
    take:
    fasta         // channel: [ val(meta), [ fasta ] ]

    main:
    ABRICATE(fasta)
    ABRICATE.out.report.collect{ it[1] } | ABRICATE_SUMMARIZE

    SRAX(fasta.collect { it[1] })

    RGI(fasta)
    RGI.out.json.collect{ it[1] } | RGI_HEATMAP

    ABRICATE.out.report | HAMRONIZE_ABRICATE
    RGI.out.txt | HAMRONIZE_RGI

    HAMRONIZE_ABRICATE.out.hamronized.mix(HAMRONIZE_RGI.out.hamronized).collect{ it[1] } | HAMRONIZE_SUMMARIZE
    
    emit:
    summary  = ABRICATE_SUMMARIZE.out.summary  // channel: [ summary ]
    out_srax = SRAX.out.result
    heatmap = RGI_HEATMAP.out.heatmap
    hamronize_summary_tsv =  HAMRONIZE_SUMMARIZE.out.summary_tsv
    hamronize_summary_html =  HAMRONIZE_SUMMARIZE.out.summary_html
}    
