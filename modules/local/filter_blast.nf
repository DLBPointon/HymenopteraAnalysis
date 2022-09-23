process FILTER_BLAST {
    tag "${meta}"
    label "process_small"

    container 'dlbpointon/filter_blast:latest'

    input:
    tuple val( meta ), file( concat_blast_out )
    val ( dtype )

    output:
    tuple val( "results" ), file( "*.tsv" )   , emit: final_tsv
    path "versions.yml"                       , emit: versions

    script:
    def id = "results"
    def type = dtype ?: 'UNKNOWN'
    def filt_percent = task.ext.args ?: 90.00
    """
    filter_blast.py \\
    $id \\
    $type \\
    $concat_blast_out \\
    $filt_percent
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        filter_blast: \$(filter_blast.py -v)
    END_VERSIONS
    """
}