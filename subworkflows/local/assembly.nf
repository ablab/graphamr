include { SPADES } from '../../modules/nf-core/software/spades/main.nf' addParams(spades_hmm: false, options: ['args': '--meta'])


workflow ASSEMBLY {
    take:
    reads         // channel: [ val(meta), [ reads ] ]

    main:
    // Cannot do --meta with single-ends
    reads
        .filter { meta, fastq -> !meta.single_end }
        .set { ch_reads }

    SPADES(ch_reads, [], false)

    // Filter for empty scaffold files
    SPADES
        .out
        .scaffolds
        .filter { meta, scaffold -> scaffold.size() > 0 }
        .set { ch_scaffolds }
    
    SPADES
        .out
        .gfa
        .filter { meta, gfa -> gfa.size() > 0 }
        .set { ch_gfa }

    emit:
    scaffolds          = SPADES.out.scaffolds               // channel: [ val(meta), [ scaffolds ] ]
    gfa                = SPADES.out.gfa                     // channel: [ val(meta), [ gfa ] ]
    log_out            = SPADES.out.log                     // channel: [ val(meta), [ log ] ]
}
