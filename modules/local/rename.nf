process RENAME {
    tag "${name}"
    label "process_low"

    input:
    tuple val( name ), path( input )
    val (dtype)

    output:
    tuple val("mappedID"), path( "*.tsv" )    , emit: renamed

    script:
    def data_type = dtype ?: name
    """
    mv $input mapped_ids_${dtype}.tsv
    """
}