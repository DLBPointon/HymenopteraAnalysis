process FILTER_BLAST {
    tag "$meta"
    label "process_medium"

    def version = '0.001-c2'

    input:
    tuple val(meta), file( concat_blast_out )

    output:
    tuple val( "results" ), file( "*.tsv")   , emit: final_tsv
    path "versions.yml"                      , emit: versions

    script:
    def id = "results"
    def type = "CDNA"
    def filt_percent = task.ext.args ?: 90.00
    """
    /software/grit/conda/envs/Damon_project/bin/python3 $projectDir/bin/filter_blast.py $id $type $concat_blast_out $filt_percent
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        filter_blast: $version
    END_VERSIONS
    """
}