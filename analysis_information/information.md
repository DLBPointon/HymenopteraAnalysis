# Hymenopteran Genome Information
All are taken from the NCBI database rather than from internal data sources.
Data is sourced post 2010 and primary haplotype.

All links start with `https://www.ncbi.nlm.nih.gov/` unless specified.

# Hymenoptera
## Apocrita/Aculeata/Apoidea
| Org | Assembly ID | Common | Link | Project | DL'ed |
|-----|-------------|--------|------|---------|-------|
| Apis cerana | ACSNU-2.0 | Asiatic Honeybee | genome/12051 | Korea | Y |
| Apis mellifera | Amel_HAv3.1 | The Honeybee | genome/48 | | Y |
| Apis dorsata | Apis dorsata 1.3 | Giant Honeybee | data-hub/genome/GCF_000469605.1/ | Cold Spring Harbour Lab | Y |
| Apis florea | Aflo_1.1 | Little Honeybee | genome/GCF_000184785.3/ | Baylor College of Medicine | Y |
| Apis laboriosa | ASM1406632v1 | Himalayan Giant Honeybee | assembly/GCF_014066325.1/ | Chongqing Normal University | Y |
| Bombus bifarius | Bbif_JDL3187 | genome/?term=txid103933[Organism:noexp] | University of Alabama | Y |
| Bombus campestris | iyBomCamp1.2 | genome/?term=txid207624[Organism:noexp] | DTOL | Y |
| Bombus hypnorum | iyBomHypn1.1 | genome/?term=txid30191[Organism:exp] | DTOL | Y |
| Bombus pratorum P| iyBomPrat1.1 | early bumblebee | genome/?term=txid30194[Organism:noexp] |DTOL | Y |
| Bombus pratorum H| iyBomPrat1.1 alt | early bumblebee | genome/110882?genome_assembly_id=1793825 |DTOL | Y |
| Bombus terrestris P| iyBomTerr1.2 | buff-tailed bumblebee | genome/2739 | DTOL | Y |
| Bombus terrestris H| iyBomTerr1.2 alt | buff-tailed bumblebee | genome/2739?genome_assembly_id=1791031 | DTOL | Y |
| Bombus vancouverensis | Bvanc_JDL1245 | genome/88779 | University of Alabama | Y |
| Cerceris rybyensis P| iyCerRyby1.1 | ornate tailed digger wasp | genome/104464?genome_assembly_id=1657208 | DTOL | Y |
| Cerceris rybyensis H| iyCerRyby1.1 alt| ornate tailed digger wasp | genome/104464?genome_assembly_id=1657208 | DTOL | Y | 
| Osmia bicornis P| iOsmBic2.1 | Red mason bee | genome/76072 | DTOL | Y |
| Osmia bicornis H| iOsmBic2.1 alt| Red mason bee | genome/76072?genome_assembly_id=1618809 | DTOL | Y |

## Apocrita/Parasitoida/Ichneumonoidae

| Org | Assembly ID | Common | Link | Project | DL'ed |
|-----|-------------|--------|------|---------|-------|
| Buathra laborator P| iyBuaLabo1.1 | | genome/?term=txid1419289[Organism:noexp] | DTOL | Y |
| Buathra laborator H| iyBuaLabo1.1 | | genome/111804?genome_assembly_id=1816943[Organism:noexp] | DTOL | Y |

## Apocrita/Parasitoida/Chalcidoidea

| Org | Assembly ID | Common | Link | Project | DL'ed |
|-----|-------------|--------|------|---------|-------|
| Ceratosolen fusciceps | ASM1888350v1 | Fig Wasp | genome/103403?genome_assembly_id=1642585 | Nankai University | Y |
| Ceratosolen solmsi marchali | CerSol1.0 | | genome/23331?genome_assembly_id=48818 | Ceratosolen solmsi Genome Consortium | Y |

```
curl https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/910/591/445/GCA_910591445.2_iyCerRyby1.2_alternate_haplotype/GCA_910591445.2_iyCerRyby1.2_alternate_haplotype_genomic.fna.gz -o data/genomes/Cerceris_rybyensis_alt.fasta.gz
```

# Key Notes
## Version 1 - Blast -> Network
At this point I have now produced a pipeline which will:
- Get the input genes (CSD,FEM) from a singular fasta file
    - Make a BLAST DB of this file.
- Get the input genomes. (Currently 24 genomes, listed above) Which can be horizontally scaled.
    - Split the input genomes into 100 entry long fastas (Generating 307 fasta files).
- Get mapping, this generates a tsv file linking the scaffolds of each file to the file name (which should be the species name).
- BLASTN to blast the split fasta against the BLASTDB.
- CAT together the blast results.
- CAT together the mapping information.
- Rename the mapping information, as this is the same name as the CAT-blast data.
- FILTER the blast data for 90% identity match
- Generate network based on gived min and max bp (MAX should equal 1mbp or size of largest input gene by default, MIN by default is 0)

## Version 2 - Add TBLASTN
- This will convert nucl fasta to pep sequence, this will help determine whether there is a conserved protein sequence. With the sequences being so divergent, this is unlikely but provides evidence of investigation.
- Adding this step will require some reorganising of the project in order to keep to the minimal style of nextflow.
    - [ ] Perhaps split the point after BLAST into a seperate sub-workflow that is used twice.


## Version 3 - Add Protein signature sequences?
Blasting the BTer CSD with the AMel CSD provides 2 regions of high similarity, if these are conserved in gene it could be possible to identify a match in more distantly related hymenopterans.