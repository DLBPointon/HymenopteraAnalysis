// SUB_WORKFLOW IMPORT
include { FILTER_AND_NETWORK as FILTER_AND_NETWORK_NUC } from '../../subworkflows/local/filter_and_network'
include { FILTER_AND_NETWORK as FILTER_AND_NETWORK_PEP } from '../../subworkflows/local/filter_and_network'

// MODULE IMPORT
include { CSV_GENERATOR as GENES_CSV_GENERATOR  } from '../../modules/local/csv_generator'
include { CSV_GENERATOR as GENOME_CSV_GENERATOR } from '../../modules/local/csv_generator'
include { BLAST_MAKEBLASTDB                     } from '../../modules/nf-core/modules/blast/makeblastdb/main'
include { GET_MAPPING                           } from '../../modules/local/get_mapping'
include { SPLIT_FASTA                           } from '../../modules/local/split_fasta'
include { BLAST_BLASTN                          } from '../../modules/nf-core/modules/blast/blastn/main'
include { BLAST_TBLASTN                         } from '../../modules/sanger-tol/nf-core//blast/tblastn/main'
include { CAT_BLAST as CAT_TSV                  } from '../../modules/local/cat_blast'


workflow BLAST_ANALYSIS {
    main:

    // Generates one gene related tuple
    ch_versions         = Channel.empty()

    ch_genes            = Channel.value(params.input_genes.genes)

    ch_genes_dir        = Channel.value(params.input_genes.directory)

    // Generates tuple([Apis_mellifera, fasta_file]) for GENOMES
    Channel
        .value(params.input_genomes.genomes.toString())
        .splitCsv()
        .flatten()
        .set { ch_genomes }

    Channel
        .value(params.input_genomes.directory)
        .set { ch_genomes_dir }

    GENES_CSV_GENERATOR ( ch_genes, ch_genes_dir )
    ch_versions = ch_versions.mix(GENES_CSV_GENERATOR.out.versions)

    BLAST_MAKEBLASTDB ( GENES_CSV_GENERATOR.out.fasta )
    ch_versions = ch_versions.mix(BLAST_MAKEBLASTDB.out.versions)

    GENOME_CSV_GENERATOR ( ch_genomes, ch_genomes_dir )
    ch_versions = ch_versions.mix(GENOME_CSV_GENERATOR.out.versions)

    GET_MAPPING ( GENOME_CSV_GENERATOR.out.fasta )

    GENOME_CSV_GENERATOR.out.fasta
        .map { fasta -> 
        tuple([ id:     fasta.toString().split('/')[-1].split('.fasta')[0],
                type:   fasta.toString().split('/')[-1].split('_')[0]
            ],
            file(fasta)
        )}
        .set { org_ch }

    SPLIT_FASTA ( org_ch )

    SPLIT_FASTA.out.split_fasta
        .flatten()
        .map { fasta -> 
                tuple([ id:     fasta.toString().split('/')[-1].split('.MOD')[0],
                        type:   fasta.toString().split('/')[-1].split('_')[0]
                    ],
                    fasta
            )}
        .combine(BLAST_MAKEBLASTDB.out.db)
        .multiMap { meta, tsv, db ->
            fastas      : tuple( meta, tsv )
            database    : db
            }
        .set { split }

    // FOR NUCLEOTIDE BLAST
    BLAST_BLASTN ( 
        split.fastas,
        split.fastas
                )
    ch_versions = ch_versions.mix(BLAST_BLASTN.out.versions)

    // FOR PEPTIDE BLAST
    BLAST_TBLASTN (
        split.fastas,
        split.fastas
    )
    ch_versions = ch_versions.mix(BLAST_TBLASTN.out.versions)

    // <--- split off as a subworkflow
    BLAST_BLASTN.out.txt
        .map { meta, file ->
            tuple( file )}
        .set { blast_nuc }
    
    BLAST_TBLASTN.out.txt
        .map { meta, file ->
            tuple( file )}
        .set { blast_pep }

    FILTER_AND_NETWORK_NUC (    "NUC",
                                blast_nucl.collect(),
                                CAT_TSV.out.concat_blast )
    FILTER_AND_NETWORK_PEP (    "PEP",
                                blast_pep.collect(),
                                CAT_TSV.out.concat_blast )

    emit:
    // CONCAT results 1
    // CONCAT results 2
    // Graph results 1
    // Graph results 2

    version         = ch_versions.ifEmpty(null)

}