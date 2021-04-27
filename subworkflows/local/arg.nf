include { ABRICATE; ABRICATE_SUMMARIZE } from '../..//modules/local/abricate'
include { SRAX } from '../..//modules/local/srax'


workflow ARG {
    take:
    fasta         // channel: [ val(meta), [ fasta ] ]

    main:
    ABRICATE(fasta)
    
    ABRICATE.out.rep_seq.collect{ it[1] } | ABRICATE_SUMMARIZE

    SRAX(fasta)

    RGI(fasta)

    RGI.out.json.collect{ it[1] } | RGI_HEATMAP


    emit:
    summary  = ABRICATE_SUMMARIZE.out.summary  // channel: [ summary ]
    out_srax = SRAX.out.result
    heatmap = RGI_HEATMAP.out.heatmap

}    
