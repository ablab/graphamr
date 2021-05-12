// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process RGI {
    tag "$meta.id"

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "python=3.6 bioconda::rgi=5.1.1" : null)

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('*.json'), emit: json
    tuple val(meta), path('*.txt'), emit: txt

    script:
    def prefix  = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """

    rgi main -i $fasta -o ${prefix} --clean -n $task.cpus --alignment_tool DIAMOND --input_type contig
    """
}

process RGI_HEATMAP {
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    conda (params.enable_conda ? "python=3.6 bioconda::rgi=5.1.1" : null)

    input:
    path json

    output:
    path('*.png'), emit: heatmap

    script:
    """
    mkdir json
    cp ${json.join(' ')} json
    rgi heatmap -i json -o heatmap
    """
}
