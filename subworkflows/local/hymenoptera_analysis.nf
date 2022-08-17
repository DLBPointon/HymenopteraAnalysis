include { CSV_GENERATOR as GENES_CSV_GENERATOR } from '../../modules/local/csv_generator'
include { CSV_GENERATOR as GENOME_CSV_GENERATOR } from '../../modules/local/csv_generator'

workflow BLAST_ANALYSIS {
    main:
    ch_versions         = Channel.empty()

    ch_genes            = Channel.value(params.input_genes.genes.toString())
                            .splitCsv()
                            .flatten()

    ch_genes_dir        = Channel.value(params.input_genes.directory)

    GENES_CSV_GENERATOR ( ch_genes, ch_genes_dir )
    ch_versions = ch_versions.mix(GENES_CSV_GENERATOR.out.versions)
    GENES_CSV_GENERATOR.out.fasta.view()

    ch_genomes          = Channel.value(params.input_genomes.genomes.toString())
                            .splitCsv()
                            .flatten()
                            .view()

    ch_genomes_dir      = Channel.value(params.input_genomes.directory)

    GENOME_CSV_GENERATOR ( ch_genomes, ch_genomes_dir )
    ch_versions = ch_versions.mix(GENOME_CSV_GENERATOR.out.versions)
    GENOME_CSV_GENERATOR.out.fasta.view()

    // MAKEBLASTDB of inputs

    // SPLIT organisms into chunked fasta

    // BLASTN db against split fasta

    // Convert input GENES to protien - Curl ExPASy?

    // BLASTX 
    
    // CONCAT results together per gene

    // CONCAT gene results together

    // Generate Graph per gene

    // Generate Graph for both

    emit:
    // CONCAT results 1
    // CONCAT results 2
    // Graph results 1
    // Graph results 2

    version         = ch_versions.ifEmpty(null)


}