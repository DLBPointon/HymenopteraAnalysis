process SPLIT_FASTA {
    input:
    tuple val( meta ), path( fasta ) 

    output:
    path("*fa")    , emit: split_fasta

    script:
    def split_by = task.ext.split_by ?: 100
    """
    python3 \\
    ${projectDir}/bin/split_fasta.py \\
    $fasta \\
    $meta.id \\
    $split_by
    """
}