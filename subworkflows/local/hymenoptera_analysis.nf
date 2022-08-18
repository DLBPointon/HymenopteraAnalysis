include { CSV_GENERATOR as GENES_CSV_GENERATOR  } from '../../modules/local/csv_generator'
include { CSV_GENERATOR as GENOME_CSV_GENERATOR } from '../../modules/local/csv_generator'

include { BLAST_MAKEBLASTDB                     } from '../../modules/nf-core/modules/blast/makeblastdb/main'
include { SPLIT_FASTA                           } from '../../modules/local/split_fasta'

workflow BLAST_ANALYSIS {
    main:

    // Generates tuple([AM-CSD, fasta_tile]) FOR GENES
    ch_versions         = Channel.empty()

    ch_genes            = Channel.value(params.input_genes.genes.toString())
                            .splitCsv()
                            .flatten()

    ch_genes_dir        = Channel.value(params.input_genes.directory)

    GENES_CSV_GENERATOR ( ch_genes, ch_genes_dir )
    ch_versions = ch_versions.mix(GENES_CSV_GENERATOR.out.versions)
    GENES_CSV_GENERATOR.out.fasta.view()

    // Generates tuple([Apis_mellifera, fasta_file]) for GENOMES
    ch_genomes          = Channel.value(params.input_genomes.genomes.toString())
                            .splitCsv()
                            .flatten()

    ch_genomes_dir      = Channel.value(params.input_genomes.directory)

    GENOME_CSV_GENERATOR ( ch_genomes, ch_genomes_dir )
    ch_versions = ch_versions.mix(GENOME_CSV_GENERATOR.out.versions)
    GENOME_CSV_GENERATOR.out.fasta.view()

    // MAKE DB PER INPUT GENE
    BLAST_MAKEBLASTDB ( GENES_CSV_GENERATOR.out.fasta )
    BLAST_MAKEBLASTDB.out.db.view()

    org_ch = GENOME_CSV_GENERATOR.out.fasta
                .map { fasta -> 
                tuple(
                    [id   :   fasta.toString().split('/')[-1].split('.fasta')[0]],
                fasta
                )}
    
    SPLIT_FASTA ( org_ch )
    SPLIT_FASTA.out.split_fasta.view()
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