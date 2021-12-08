// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process SRAX {
    tag "$meta.id"

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    conda (params.enable_conda ? "bioconda::srax" : null)

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('*_srax'), emit: result
    tuple val(meta), path('*_srax/Results/Summary_files/sraX_detected_ARGs.tsv'), emit: report

    script:
    def prefix  = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    mkdir srax_in
    cp ${fasta.join(' ')} srax_in
    sraX -i srax_in -o srax_out
    mv srax_out ${prefix}_srax
    """
}