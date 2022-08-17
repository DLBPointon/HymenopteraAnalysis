workflow BLAST_ANALYSIS {
    main:
    ch_versions = Channel.empty()

    // CSV GENERATOR of gene inputs

    // MAKEBLASTDB of inputs

    // CSV GENERATOR of organisms to compare against

    // SPLIT organisms into chunked fasta

    // BLASTN db against split fasta
    
    // CONCAT results together per gene

    // CONCAT gene results together

    // Generate Graph per gene

    // Generate Graph for both

    emit:
    // CONCAT results 1
    // CONCAT results 2
    // Graph results 1
    // Graph results 2

    version     = ch_versions.ifEmpty(null)


}