include { ABRICATE; ABRICATE_SUMMARIZE } from '../..//modules/local/abricate'

workflow ARG {
    take:
    fasta         // channel: [ val(meta), [ fasta ] ]

    main:
    ABRICATE(fasta)
    
    ABRICATE.out.rep_seq.collect{ it[1] } | ABRICATE_SUMMARIZE

    emit:
    summary  = ABRICATE_SUMMARIZE.out.summary  // channel: [ summary ]
}    
