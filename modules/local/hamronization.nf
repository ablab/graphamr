// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process HAMRONIZE_ABRICATE {
    tag "$meta.id"

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::hamronization=1.0.3" : null)

    input:
    tuple val(meta), path(report)

    output:
    tuple val(meta), path('*.tsv'), emit: hamronized

    script:
    def prefix  = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    hamronize abricate ${report} --reference_database_version db_v_1 --analysis_software_version tool_v_1 --output ${prefix}_abricate_hamronized.tsv
    """
}

process HAMRONIZE_RGI {
    tag "$meta.id"

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::hamronization=1.0.3" : null)

    input:
    tuple val(meta), path(report)

    output:
    tuple val(meta), path('*.tsv'), emit: hamronized

    script:
    def prefix  = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    hamronize rgi ${report} --input_file_name ${prefix} --reference_database_version db_v_1 --analysis_software_version tool_v_1 --output ${prefix}_rgi_hamronized.tsv
    """
}

process HAMRONIZE_SRAX {

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::hamronization=1.0.3" : null)

    input:
    tuple val(meta), path(report)

    output:
    tuple val(meta), path('*.tsv'), emit: hamronized

    script:
    def prefix  = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    hamronize srax ${report} --input_file_name ${prefix} --reference_database_version db_v_1 --analysis_software_version tool_v_1 --reference_database_id srax_default --output ${prefix}_srax_hamronized.tsv
    """
}

process HAMRONIZE_SUMMARIZE {
    publishDir "${params.outdir}", mode: params.publish_dir_mode

    conda (params.enable_conda ? "bioconda::hamronization=1.0.3" : null)

    input:
    path('?.tsv')

    output:
    path('amr_summary.tsv'), emit: summary_tsv
    path('amr_summary.html'), emit: summary_html

    script:
    """
    hamronize summarize --output amr_summary.tsv --summary_type tsv *.tsv
    hamronize summarize --output amr_summary.html --summary_type interactive *.tsv
    """
}