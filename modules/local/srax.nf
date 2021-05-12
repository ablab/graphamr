// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process SRAX {
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    conda (params.enable_conda ? "lgpdevtools::srax" : null)

    input:
    path fasta

    output:
    path('Results'), emit: result

    script:
    """
    mkdir srax_in
    cp ${fasta.join(' ')} srax_in
    sraX -i srax_in -o srax_out
    mv srax_out Results
    """
}
