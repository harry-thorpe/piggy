# Piggy

Piggy is a tool for analysing the intergenic component of bacterial genomes. It is designed to be used in conjunction with Roary (https://github.com/sanger-pathogens/Roary).

## Installation

Piggy has a number of dependencies:

* Roary
* Mafft, BLASTN, CD-HIT, GNU Parallel (these should all be installed with Roary by default)

To install Piggy, change to a directory and clone Piggy from Github:

`cd /some/directory`
`git clone https://github.com/harry-thorpe/piggy`

Add the Piggy folder to the PATH:

`export PATH="$PATH:/some/directory/piggy"`

Check that the piggy executible and all the scripts in piggy/bin have executible permissions, and test it by typing `piggy` into the terminal. This should bring up a list of options.

## Usage

Piggy requires bacterial genome assemblies in GFF3 format (such as those produced by Prokka) as input.

Piggy accepts the following options:

    --in_dir|-i	    input folder [default - current folder]
    --out_dir|-o	output folder [default - current folder/piggy_out]
    --roary_dir|-r	folder where roary output is stored [required]
    --threads|-t	threads [default - 1]
    --nuc_id|-n	    min percentage nucleotide identity [default - 90]
    --len_id|-l	    min percentage length identity [default - 90]
    --method|-m	    method for detecting switched IGRs [g - gene_pair, u - upstream] 
                    [default - g]
    --R_plots|-R	make R plots (requires R, Rscript, ggplot2, reshape2) [default - 
                    off]
    --fast|-f	    fast mode (doesn't align IGRs or detect switched regions) 
                    [default - off]
    --help|-h	    help

In order for Piggy to work, Roary must be run first. The output folder produced by Roary is required as an input to Piggy (specified by --roary_dir). We recommend running Roary with the -s option to keep paralogs together. This is because when Piggy searches for switched IGRs it uses only single copy genes and cannot distinguish between paralogs.

## Output files

