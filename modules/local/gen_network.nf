process GEN_NETWORK {
    tag "${meta}"
    label "process_low"
    
    container 'dlbpointon/network_blast:latest'

    input:
    tuple val( meta1 ), file( blast_out )
    tuple val( meta2 ), file( mapping )
    val( data_type )

    output:
    path("*png"),           emit: network_graphs
    path "versions.yml",    emit: versions

    script:
    def args        = task.ext.args ?: ''
    def filter_max  = task.ext.fmax ?: '-filter_max 1000000'
    def filter_min  = task.ext.fmin ?: '-filter_min 0'
    """
    network_graph.py \\
    $blast_out \\
    $mapping \\
    $data_type \\
    -filter_max 1000000 \\
    -filter_min 4000 \\
    $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        network_graph: \$(network_graph -v)
    END_VERSIONS
    """
}

// TO-DO: Alot of the not so great looking code wil be fixed once the modules are dockerised.