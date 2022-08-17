process CSV_GENERATOR {
    tag "${ch_item}"
    label 'process_small'

    input:
    val ch_item
    val ch_dir

    output:
    tuple val(ch_item), path("*fasta")      , emit: fasta
    path "versions.yml"                     , emit: versions

    script:
    """
    cp "${ch_dir}${ch_item}.fasta" "${ch_item}.fasta"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        csvgenerator: BASH
    END_VERSIONS
    """
}