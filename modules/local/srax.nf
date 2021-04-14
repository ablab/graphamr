// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process SRAX {
    tag "$meta.id"

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('*_result'), emit: result

    script:
    def prefix  = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    mkdir ${prefix}
    cp $fasta ./${prefix}/
    sraX -i ./${prefix}/ -o ./${prefix}_srax
    mv ./${prefix}_srax/Results ./${prefix}_result

    """
}