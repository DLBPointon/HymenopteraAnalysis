process GET_MAPPING {
    input:
    path fasta

    output:
    tuple val('mapping'), path ( "*tsv" )   , emit: mapped_tsv

    script:
    def version = 'v1'
    """
    /software/grit/conda/envs/Damon_project/bin/python3 $projectDir/bin/get_mapping.py $fasta
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        get_mapping: $version
    END_VERSIONS
    """
}