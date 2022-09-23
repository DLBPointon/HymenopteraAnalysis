// SUB_WORKFLOW IMPORT
include { FILTER_AND_NETWORK as FILTER_AND_NETWORK_NUC      } from '../../subworkflows/local/filter_and_network'
include { FILTER_AND_NETWORK as FILTER_AND_NETWORK_PEP      } from '../../subworkflows/local/filter_and_network'
include { FILTER_AND_NETWORK as FILTER_AND_NETWORK_SIG_NUC  } from '../../subworkflows/local/filter_and_network'
include { FILTER_AND_NETWORK as FILTER_AND_NETWORK_SIG_PEP  } from '../../subworkflows/local/filter_and_network'

// MODULE IMPORT
include { CSV_GENERATOR as GENES_CSV_GENERATOR  } from '../../modules/local/csv_generator'
include { CSV_GENERATOR as GENOME_CSV_GENERATOR } from '../../modules/local/csv_generator'
include { CSV_GENERATOR as SIGS_CSV_GENERATOR   } from '../../modules/local/csv_generator'
include { BLAST_MAKEBLASTDB                     } from '../../modules/nf-core/modules/blast/makeblastdb/main'
include { SIGS_BLAST_MAKEBLASTDB                } from '../../modules/nf-core/modules/blast/makeblastdb/main'
include { GET_MAPPING                           } from '../../modules/local/get_mapping'
include { SPLIT_FASTA                           } from '../../modules/local/split_fasta'
include { BLAST_BLASTN                          } from '../../modules/nf-core/modules/blast/blastn/main'
include { SIGS_BLAST_BLASTN                     } from '../../modules/nf-core/modules/blast/blastn/main'
include { BLAST_TBLASTN                         } from '../../modules/sanger-tol/nf-core-modules/blast/tblastn/main'
include { SIGS_BLAST_TBLASTN                    } from '../../modules/sanger-tol/nf-core-modules/blast/tblastn/main'
include { CAT_BLAST as CAT_TSV                  } from '../../modules/local/cat_blast'


workflow BLAST_ANALYSIS {
    main:

    // Generates one gene related tuple
    ch_versions         = Channel.empty()

    ch_genes            = Channel.value(params.input_genes.genes)

    ch_genes_dir        = Channel.value(params.input_genes.directory)

    ch_sigs             = Channel.value(params.input_pep_sig.sigs)

    ch_sigs_dir         = Channel.value(params.input_pep_sig.directory)

    // Generates tuple([Apis_mellifera, fasta_file]) for GENOMES
    Channel
        .value(params.input_genomes.genomes.toString())
        .splitCsv()
        .flatten()
        .set { ch_genomes }

    Channel
        .value(params.input_genomes.directory)
        .set { ch_genomes_dir }

    // <------------ CHUNK TO PREPARE QUERY GENOMES FOR BLAST

    GENOME_CSV_GENERATOR ( ch_genomes, ch_genomes_dir )
    ch_versions = ch_versions.mix(GENOME_CSV_GENERATOR.out.versions)

    GET_MAPPING ( GENOME_CSV_GENERATOR.out.fasta )

    CAT_TSV ( GET_MAPPING.out.mapped_tsv.collect(), '' )

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

    // <----------------- Chunk for SUBJECT GENES
    GENES_CSV_GENERATOR ( ch_genes, ch_genes_dir )
    ch_versions = ch_versions.mix(GENES_CSV_GENERATOR.out.versions)

    BLAST_MAKEBLASTDB ( GENES_CSV_GENERATOR.out.fasta )
    ch_versions = ch_versions.mix(BLAST_MAKEBLASTDB.out.versions)

    // <----------------- Could be seperated off too.
    BLAST_BLASTN ( 
        split.fastas,
        split.database
    )
    ch_versions = ch_versions.mix(BLAST_BLASTN.out.versions)

    BLAST_BLASTN.out.txt
        .map { meta, file ->
            tuple( file )}
        .set { blast_nuc }

    FILTER_AND_NETWORK_NUC (    "NUC",
                                blast_nuc.collect(),
                                CAT_TSV.out.concat_blast )
    // <----------------- Could be seperated off too.
    
    if (params.run_pep_blast == "Y") {
        GENES_CSV_GENERATOR ( ch_genes, ch_genes_dir )
        ch_versions = ch_versions.mix(GENES_CSV_GENERATOR.out.versions)

        BLAST_MAKEBLASTDB ( GENES_CSV_GENERATOR.out.fasta )
        ch_versions = ch_versions.mix(BLAST_MAKEBLASTDB.out.versions)

        BLAST_TBLASTN (
            split.fastas,
            split.database
        )
        ch_versions = ch_versions.mix(BLAST_TBLASTN.out.versions)
        
        BLAST_TBLASTN.out.txt
            .map { meta, file ->
                tuple( file )}
            .set { blast_pep }

        FILTER_AND_NETWORK_PEP (    "PEP",
                                    blast_pep.collect(),
                                    CAT_TSV.out.concat_blast )
    }

    if (params.run_sig_blast == "Y") {
        SIGS_CSV_GENERATOR ( ch_sigs, ch_sigs_dir )
        ch_versions = ch_versions.mix( SIGS_CSV_GENERATOR.out.versions )

        SIGS_BLAST_MAKEBLASTDB ( SIGS_CSV_GENERATOR.out.fasta )
        ch_versions = ch_versions.mix( SIGS_BLAST_MAKEBLASTDB.out.versions )

        SIGS_BLAST_BLASTN ( 
            split.fastas,
            split.database
        )
        ch_versions = ch_versions.mix(SIGS_BLAST_BLASTN.out.versions)

        SIGS_BLAST_BLASTN.out.txt
            .map { meta, file ->
                tuple( file )}
            .set { blast_sig }

        SIGS_BLAST_TBLASTN (
            split.fastas,
            split.database
        )
        ch_versions = ch_versions.mix(SIGS_BLAST_TBLASTN.out.versions)

        SIGS_BLAST_TBLASTN.out.txt
            .map { meta, file ->
                tuple( file )}
            .set { blast_pep }

        FILTER_AND_NETWORK_SIGS_NUC (   "SIG-NUC",
                                        blast_sig.collect(),
                                        CAT_TSV.out.concat_blast )
        FILTER_AND_NETWORK_SIGS_PEP (   "SIG-PEP",
                                        blast_sig.collect(),
                                        CAT_TSV.out.concat_blast )
    }

    emit:
    // CONCAT results 1
    // CONCAT results 2
    // Graph results 1
    // Graph results 2

    version         = ch_versions.ifEmpty(null)

}