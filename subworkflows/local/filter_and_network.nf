include { CAT_BLAST                             } from '../../modules/local/cat_blast'
include { RENAME                                } from '../../modules/local/rename'
include { FILTER_BLAST                          } from '../../modules/local/filter_blast'
include { GEN_NETWORK                           } from '../../modules/local/gen_network'

workflow FILTER_AND_NETWORK {
    take:
    dtype       // "PEP"|"NUCL"|"SIG_NUCL"
    blast_list  // tuple([list of blast output])
    id_mapping  // tuple(val("mapping"), path(mapping.tsv))

    main:
    ch_versions     = Channel.empty()

    CAT_BLAST (     blast_list,
                    dtype )
    ch_versions = ch_versions.mix(CAT_BLAST.out.versions)

    RENAME (        id_mapping,
                    dtype )
    
    FILTER_BLAST (  CAT_BLAST.out.concat_blast,
                    dtype )
    ch_versions = ch_versions.mix(FILTER_BLAST.out.versions)


    GEN_NETWORK (   FILTER_BLAST.out.final_tsv,
                    RENAME.out.renamed,
                    dtype )
    ch_versions = ch_versions.mix(FILTER_BLAST.out.versions)

    emit:
    all_blast       =       CAT_BLAST.out.concat_blast
    filtered_blast  =       FILTER_BLAST.out.final_tsv
    graphs          =       GEN_NETWORK.out.network_graphs.collect()

    version         =       ch_versions.ifEmpty(null)
}