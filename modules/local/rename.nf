process RENAME {
    input:
    tuple val( name ), path( input )

    output:
    tuple val("mappedID"), path( "mapped_ids.tsv" )    , emit: renamed

    script:
    """
    mv $input mapped_ids.tsv
    """
}