process CAT_BLAST {
    tag "All BLAST out"
    label "process_small"

    input:
    file( input_files )
    val ( dtype )

    output:
    tuple val('concat'), file ("*.tsv"),    emit: concat_blast
    path "versions.yml",                    emit: versions

    script:
    def data_type   =   dtype ?: 'X'
    """
    cat $input_files > concatenated_final_${dtype}blast.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        CAT_BLAST : BASH
    END_VERSIONS
    """
}
