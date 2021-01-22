#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process PATHRACER {
    input:
    path graph
    path hmm

    output:
    path 'pathracer'

    publishDir "${params.outdir}", mode:params.publish_dir_mode

    script:
    """
    pathracer $hmm $graph --output pathracer --rescore -t $task.cpus
    """
}

process EXTRACT_ALL_EDGES {
    input:
    path pathracer_dir

    output:
    path 'all.edges.fa'

    script:
    """
    cp ${pathracer_dir}/all.edges.fa all.edges.fa
    """
}

process MMSEQS_DB {
    input:
    path fasta

    output:
    path "mmseqs_db"

    if (params.save_mmseqs) {
        publishDir "${params.outdir}", mode:params.publish_dir_mode
    }

    script:
    """
    mmseqs createdb $fasta mmseqs.db
    mkdir mmseqs_db && mv mmseqs.db* mmseqs_db
    """
}

process EXTRACT_ORFS {
    input:
    path mmseqs_db

    output:
    path "mmseqs_orf_db"

    if (params.save_mmseqs) {
        publishDir "${params.outdir}", mode:params.publish_dir_mode
    }

    script:
    """
    mmseqs extractorfs $mmseqs_db/mmseqs.db mmseqs.orf.db --threads $task.cpus
    mkdir mmseqs_orf_db && mv mmseqs.orf.db* mmseqs_orf_db
    """
}

process EXTRACT_ORF_FASTA {
    input:
    path mmseqs_orf_db

    output:
    path 'all_orfs.fasta'

    publishDir "${params.outdir}/orfs", mode:params.publish_dir_mode

    script:
    """
    mmseqs convert2fasta $mmseqs_orf_db/mmseqs.orf.db all_orfs.fasta
    """
}

process MMSEQS_CLUSTER {
    input:
    path fasta

    output:
    path 'orfs_rep_seq.fasta'

    publishDir "${params.outdir}/orfs", mode:params.publish_dir_mode

    script:
    """
    mmseqs easy-linclust $fasta orfs tmp --min-seq-id ${params.cluster_idy}
    """
}

process ABRICATE {
    input:
    path fasta

    output:
    tuple path('summary.tsv'), path('rep_seq.tsv')

    publishDir "${params.outdir}/abricate", mode:params.publish_dir_mode

    script:
    """
    abricate -db ${params.abricate_db} $fasta --threads $task.cpus > rep_seq.tsv
    abricate --summary rep_seq.tsv > summary.tsv
    """
}

/*
 * Parse software version numbers
 */
process get_software_versions {
    publishDir "${params.outdir}/pipeline_info", mode: params.publish_dir_mode,
        saveAs: { filename ->
                      if (filename.endsWith(".csv")) filename
                      else null
                }

    output:
    path "software_versions_mqc.yaml"
    path "software_versions.csv"

    script:
    """
    echo $workflow.manifest.version > v_pipeline.txt
    echo $workflow.nextflow.version > v_nextflow.txt
    abricate --version > v_abricate.txt
    echo \$(mmseqs 2>&1) > v_varscan.txt
    scrape_software_versions.py &> software_versions_mqc.yaml
    """
}


def helpMessage() {
    log.info nfcoreHeader()
    log.info"""

    Usage:

    The typical command for running the pipeline is as follows:

    nextflow run nf-core/graphamr --graph 'assembly_graph_with_scaffolds.gfa' -profile docker

    Mandatory arguments:
      --graph [file]                  Path to input graph in GFA format  (must be surrounded with quotes)
      -profile [str]                  Configuration profile to use. Can use multiple (comma separated)
                                      Available: conda, docker, singularity, test, awsbatch, <institute> and more

    Options:
      --hmm [str]                     Full path to AMR hmms.

    Other options:
      --outdir [file]                 The output directory where the results will be saved
      --publish_dir_mode [str]        Mode for publishing results in the output directory. Available: symlink, rellink, link, copy, copyNoFollow, move (Default: copy)
      -name [str]                     Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic

    AWSBatch options:
      --awsqueue [str]                The AWSBatch JobQueue that needs to be set when running on AWSBatch
      --awsregion [str]               The AWS Region for your AWS Batch job to run on
      --awscli [str]                  Path to the AWS CLI tool
    """.stripIndent()
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

// Has the run name been specified by the user?
// this has the bonus effect of catching both -name and --name
custom_runName = params.name
if (!(workflow.runName ==~ /[a-z]+_[a-z]+/)) {
    custom_runName = workflow.runName
}

// Check AWS batch settings
if (workflow.profile.contains('awsbatch')) {
    // AWSBatch sanity checking
    if (!params.awsqueue || !params.awsregion) exit 1, "Specify correct --awsqueue and --awsregion parameters on AWSBatch!"
    // Check outdir paths to be S3 buckets if running on AWSBatch
    // related: https://github.com/nextflow-io/nextflow/issues/813
    if (!params.outdir.startsWith('s3:')) exit 1, "Outdir not on S3 - specify S3 Bucket to run on AWSBatch!"
    // Prevent trace files to be stored on S3 since S3 does not support rolling files.
    if (params.tracedir.startsWith('s3:')) exit 1, "Specify a local tracedir or run without trace! S3 cannot be used for tracefiles."
}

// Header log info
log.info nfcoreHeader()
def summary = [:]
if (workflow.revision) summary['Pipeline Release'] = workflow.revision
summary['Run Name']         = custom_runName ?: workflow.runName
summary['Graph']            = params.graph
summary['HMM']              = params.hmm
// FIXME: add more params
summary['Max Resources']    = "$params.max_memory memory, $params.max_cpus cpus, $params.max_time time per job"
if (workflow.containerEngine) summary['Container'] = "$workflow.containerEngine - $workflow.container"
summary['Output dir']       = params.outdir
summary['Launch dir']       = workflow.launchDir
summary['Working dir']      = workflow.workDir
summary['Script dir']       = workflow.projectDir
summary['User']             = workflow.userName
if (workflow.profile.contains('awsbatch')) {
    summary['AWS Region']   = params.awsregion
    summary['AWS Queue']    = params.awsqueue
    summary['AWS CLI']      = params.awscli
}
summary['Config Profile'] = workflow.profile
if (params.config_profile_description) summary['Config Profile Description'] = params.config_profile_description
if (params.config_profile_contact)     summary['Config Profile Contact']     = params.config_profile_contact
if (params.config_profile_url)         summary['Config Profile URL']         = params.config_profile_url
summary['Config Files'] = workflow.configFiles.join(', ')
if (params.email || params.email_on_fail) {
    summary['E-mail Address']    = params.email
    summary['E-mail on failure'] = params.email_on_fail
    summary['MultiQC maxsize']   = params.max_multiqc_email_size
}
log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
log.info "-\033[2m--------------------------------------------------\033[0m-"

// Check the hostnames against configured profiles
checkHostname()

workflow {
    graph = Channel.fromPath(params.graph, checkIfExists: true)
    def def_hmm = new File("$projectDir/assets/${params.hmm}")
    hmm = Channel.fromPath(def_hmm.exists() ? def_hmm : params.hmm, checkIfExists: true)

    PATHRACER(graph, hmm) | EXTRACT_ALL_EDGES | MMSEQS_DB | EXTRACT_ORFS | EXTRACT_ORF_FASTA | MMSEQS_CLUSTER | ABRICATE
}

workflow.onComplete {
    if (workflow.stats.ignoredCount > 0 && workflow.success) {
        log.info "-${c_purple}Warning, pipeline completed, but with errored process(es) ${c_reset}-"
        log.info "-${c_red}Number of ignored errored process(es) : ${workflow.stats.ignoredCount} ${c_reset}-"
        log.info "-${c_green}Number of successfully ran process(es) : ${workflow.stats.succeedCount} ${c_reset}-"
    }

    if (workflow.success) {
        log.info "-${c_purple}[nf-core/graphamr]${c_green} Pipeline completed successfully${c_reset}-"
    } else {
        checkHostname()
        log.info "-${c_purple}[nf-core/graphamr]${c_red} Pipeline completed with errors${c_reset}-"
    }

}

def nfcoreHeader() {
    // Log colors ANSI codes
    c_black = params.monochrome_logs ? '' : "\033[0;30m";
    c_blue = params.monochrome_logs ? '' : "\033[0;34m";
    c_cyan = params.monochrome_logs ? '' : "\033[0;36m";
    c_dim = params.monochrome_logs ? '' : "\033[2m";
    c_green = params.monochrome_logs ? '' : "\033[0;32m";
    c_purple = params.monochrome_logs ? '' : "\033[0;35m";
    c_reset = params.monochrome_logs ? '' : "\033[0m";
    c_white = params.monochrome_logs ? '' : "\033[0;37m";
    c_yellow = params.monochrome_logs ? '' : "\033[0;33m";

    return """    -${c_dim}--------------------------------------------------${c_reset}-
                                            ${c_green},--.${c_black}/${c_green},-.${c_reset}
    ${c_blue}        ___     __   __   __   ___     ${c_green}/,-._.--~\'${c_reset}
    ${c_blue}  |\\ | |__  __ /  ` /  \\ |__) |__         ${c_yellow}}  {${c_reset}
    ${c_blue}  | \\| |       \\__, \\__/ |  \\ |___     ${c_green}\\`-._,-`-,${c_reset}
                                            ${c_green}`._,._,\'${c_reset}
    ${c_purple}  nf-core/graphamr v${workflow.manifest.version}${c_reset}
    -${c_dim}--------------------------------------------------${c_reset}-
    """.stripIndent()
}

def checkHostname() {
    def c_reset = params.monochrome_logs ? '' : "\033[0m"
    def c_white = params.monochrome_logs ? '' : "\033[0;37m"
    def c_red = params.monochrome_logs ? '' : "\033[1;91m"
    def c_yellow_bold = params.monochrome_logs ? '' : "\033[1;93m"
    if (params.hostnames) {
        def hostname = "hostname".execute().text.trim()
        params.hostnames.each { prof, hnames ->
            hnames.each { hname ->
                if (hostname.contains(hname) && !workflow.profile.contains(prof)) {
                    log.error "====================================================\n" +
                            "  ${c_red}WARNING!${c_reset} You are running with `-profile $workflow.profile`\n" +
                            "  but your machine hostname is ${c_white}'$hostname'${c_reset}\n" +
                            "  ${c_yellow_bold}It's highly recommended that you use `-profile $prof${c_reset}`\n" +
                            "============================================================"
                }
            }
        }
    }
}
