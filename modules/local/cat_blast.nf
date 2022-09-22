process CAT_BLAST {
    label "process_medium"

    input:
    file(input_files)

    output:
    tuple val('concat'), file ("concatenated_final_blast.tsv"),     emit: concat_blast

    script:
    """
    cat $input_files > concatenated_final_blast.tsv
    """
}
