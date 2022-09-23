process GET_MAPPING {
    tag "${fasta}"
    label "process_small"
    
    container 'dlbpointon/get_mapping:latest'

    input:
    path fasta

    output:
    tuple val('mapping'), path ( "*tsv" )   , emit: mapped_tsv

    script:
    """
    get_mapping.py $fasta
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        get_mapping: \$(get_mapping.py -v)
    END_VERSIONS
    """
}