process SPLIT_FASTA {
    tag "${meta.id}"
    label "process_small"
    
    container 'dlbpointon/split_fasta:latest'

    input:
    tuple val( meta ), path( fasta ) 

    output:
    path("*fa")         , emit: split_fasta
    path "versions.yml" , emit: versions

    script:
    def split_by = task.ext.split_by ?: 100
    """
    split_fasta.py \\
    $fasta \\
    $meta.id \\
    $split_by

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        split_fasta: \$(split_fasta.py -v)
    END_VERSIONS
    """
}