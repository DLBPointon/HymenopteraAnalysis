process GEN_NETWORK {
    input:
    tuple val(meta1), file(blast_out)
    tuple val(meta2), file(mapping)
    val(data_type)

    output:
    path("*png")   , emit: network_graphs

    script:
    def args        = task.ext.args
    """
    /software/grit/conda/envs/Damon_project/bin/python3 \\
    $projectDir/bin/network_graph.py \\
    $blast_out \\
    $mapping \\
    $data_type
    $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        filter_blast: \$(/software/grit/conda/envs/Damon_project/bin/python3 $projectDir/bin/network_graph.py --version)
    END_VERSIONS
    """
}