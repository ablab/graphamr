// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)


process RGI {
    tag "$meta.id"

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::rgi=5.1.1" : null)

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('*.json'), emit: json

    script:
    def prefix  = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """

    rgi main -i $fasta -o ./${prefix} --clean -n 16

    """
}

process RGI_HEATMAP {
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    input:
    path('?.json')

    output:
    path('*.png'), emit: heatmap

    script:
    """
    mkdir json
    cp *.json ./json
    rgi heatmap -i ./json -o rgi_heatmap
    """
}
