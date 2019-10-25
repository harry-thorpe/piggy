# Piggy

Piggy is a tool for analysing the intergenic component of bacterial genomes. It is designed to be used in conjunction with Roary (https://github.com/sanger-pathogens/Roary).

The paper describing Piggy can be found at: https://doi.org/10.1093/gigascience/giy015

## Installation

### Dependencies

Piggy has a number of dependencies, and these are all also required by Roary. The easiest way to install piggy is to install Roary first with conda, and then clone the piggy repository. Create a new conda environment and install Roary v3.12.0:

`conda install roary=3.12.0`

If you don't want to use conda then the following dependencies will have to be installed manually:

* Roary
* Mafft, BLASTN, CD-HIT, GNU Parallel (these should all be installed with Roary by default)

### Piggy

Once the dependencies are installed clone the piggy repository from github:

`git clone https://github.com/harry-thorpe/piggy.git`

The piggy executable is in piggy/bin, so either add this directory to your $PATH or run it by specifying its location in the terminal. When piggy is run with no options it should print a help menu.

## Usage

Piggy requires bacterial genome assemblies in GFF3 format (such as those produced by Prokka) as input.

Piggy accepts the following options:

`--in_dir|-i `&emsp;` <STR> `&emsp;` input folder [default - current folder]`\
`--out_dir|-o `&emsp;` <STR> `&emsp;` output folder [default - current folder/piggy_out]`\
`--roary_dir|-r `&emsp;` <STR> `&emsp;` folder where roary output is stored [required]`\
`--threads|-t `&emsp;` <INT> `&emsp;` threads [default - 1]`\
`--nuc_id|-n `&emsp;` <INT> `&emsp;` min percentage nucleotide identity [default - 90]`\
`--len_id|-l `&emsp;` <INT> `&emsp;` min percentage length identity [default - 90]`\
`--edges|-e `&emsp;` keep IGRs at the edge of contigs [default - off]`\
`--size|-s `&emsp;` <STR> `&emsp;` size of IGRs to extract [i-j] [default 30-1000]`\
`--method|-m `&emsp;` <STR> `&emsp;` method for detecting switched IGRs [g - gene_pair, u - upstream] [default - g]`\
`--R_plots|-R `&emsp;` make R plots (requires R, Rscript, ggplot2, reshape2) [default - off]`\
`--fast|-f `&emsp;` fast mode (doesn't align IGRs or detect switched regions) [default - off]`\
`--help|-h `&emsp;` help`\
`--version|-v `&emsp;` version`

In order for Piggy to work, Roary must be run first. The output folder produced by Roary is required as an input to Piggy (specified by --roary_dir). We recommend running Roary with the -s option to keep paralogs together. This is because when Piggy searches for switched IGRs it uses only single copy genes and cannot distinguish between paralogs.

## Output files

Piggy produces a number of output files:

cluster_intergenic_alignment_files - This is a folder containing alignments of each IGR cluster defined by Piggy. Where sequences have been reversed complemented to align them, the fasta headers have been appended with '\_R'.

switched_region_alignment_files - This is a folder containing alignments of alternative "switched" IGRs identified by Piggy. Where sequences have been reversed complemented to align them, the fasta headers have been appended with '\_R'.

IGR_presence_absence.csv - An IGR presence/absence matrix with the same structure as that produced by Roary. The IGRs in this file are named according to the genome and gene neighbourhood of the IGR, and follow the form: Genome Gene_1 Gene_2 X, where X can be DP, CO_F, CO_R, DT (further described in Figure 1 in the preprint). `_+_+_` is used as a delimiter between fields. Gene_1 and Gene_2 are the two flanking genes for the IGR, and these may be replaced by NA if the IGR is at the edge of a contig (so only has one flanking gene). In this case the gene orientation information (X) will also be replaced by NA. The gene orientation information is as follows:
* DP - Double Promoter   <---- IGR ----> genes are divergently transcribed.
* DT - Double Terminator ----> IGR <---- genes are convergently transcribed.
* CO_F - Co-oriented Forward ----> IGR ----> genes are co-oriented forward.
* CO_R - Co-oriented Reverse <---- IGR <---- genes are co-oriented reverse.

switched_region_divergences.csv - This contains information about the candidate "switched" IGRs identified by Piggy. The methods for identifying these are described in the preprint. The columns are as follows:
* Gene - This gives information on the gene neighbourhood and IGR clusters. `_+_+_` is used as a delimiter between fields, and the form is: Gene_1 Gene_2 IGR_1 IGR_2. This means that between Gene_1 and Gene_2, there are two divergent IGRs (IGR_1 and IGR_2), present in different strains. If the upstream method has been used then only one gene will be present.
* Id_1, and Id_2 - These are the names of the IGR sequences which have been aligned against each other.
* SNPs - The number of SNPs in the alignment.
* Sites - The number of shared sites in the alignment.
* Length - The length of the alignment.
* Nuc_identity - SNPs/Sites
* Length_identity - Sites/Length
