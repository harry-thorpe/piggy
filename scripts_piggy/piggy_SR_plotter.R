#!/usr/bin/env Rscript

is.installed <- function(mypkg) is.element(mypkg, installed.packages()[,1]) 

#####
library(ggplot2)
library(reshape2)

if(is.installed("cowplot") == TRUE){
  library(cowplot)
}

args <- commandArgs(trailingOnly=TRUE)

out_dir=args[1]
nuc_identity=args[2]
nuc_identity <- as.double(nuc_identity)
len_identity=args[2]
len_identity <- as.double(len_identity)

#####

in_file=paste(out_dir, "/switched_region_divergences.csv", sep="")

switched_region_divergences <- read.csv(file=in_file, header=TRUE)
#View(switched_region_divergences)

switched_region_divergences_long <- melt(switched_region_divergences, id.vars="Gene", measure.vars=c("Length_identity", "Nuc_identity"))

sr_div_hist <- ggplot(switched_region_divergences_long, aes(x=value)) +
  geom_histogram(binwidth=0.005) +
  labs(x="Identity", y="Count") +
  facet_grid(variable~., scales="free")

out_file=paste(out_dir, "/switched_region_divergences_hist.tif", sep="")

tiff(filename=out_file, height=5, width=10, units="in", res=100)

sr_div_hist

dev.off()

#####

sr_div_point <- ggplot(switched_region_divergences, aes(x=Length_identity, y=Nuc_identity)) +
  geom_point(alpha=0.3) +
  geom_vline(xintercept=len_identity, linetype="dashed", colour="red") +
  geom_hline(yintercept=nuc_identity, linetype="dashed", colour="red") +
  labs(x="Length identity", y="Nucleotide identity")

out_file=paste(out_dir, "/switched_region_divergences_point.tif", sep="")

tiff(filename=out_file, height=5, width=10, units="in", res=100)

sr_div_point

dev.off()

#####

switched_region_divergences_subset <- switched_region_divergences[(switched_region_divergences$Nuc_identity < nuc_identity & switched_region_divergences$Length_identity < len_identity), ]
Switched <- nrow(switched_region_divergences_subset)

switched_region_divergences_subset <- switched_region_divergences[(switched_region_divergences$Nuc_identity < nuc_identity & switched_region_divergences$Length_identity >= len_identity), ]
Divergent <- nrow(switched_region_divergences_subset)

switched_region_divergences_subset <- switched_region_divergences[(switched_region_divergences$Nuc_identity >= nuc_identity & switched_region_divergences$Length_identity < len_identity), ]
Insertion_Deletion <- nrow(switched_region_divergences_subset)

switched_region_divergences_subset <- switched_region_divergences[(switched_region_divergences$Nuc_identity >= nuc_identity & switched_region_divergences$Length_identity >= len_identity), ]
False_positive <- nrow(switched_region_divergences_subset)

types_df <- data.frame(Insertion_Deletion, Switched, Divergent, False_positive, stringsAsFactors=FALSE)

types_df_long <- melt(types_df, variable.name="Category", value.name="Count")

types_plot <- ggplot(types_df_long, aes(x=Category, y=Count)) +
  geom_bar(stat="identity")

out_file=paste(out_dir, "/switched_region_divergences_types.tif", sep="")

tiff(filename=out_file, height=5, width=10, units="in", res=100)

types_plot

dev.off()

#####

in_file=paste(out_dir, "/cluster_IGR_divergences.csv", sep="")

cluster_IGR_divergences <- read.csv(file=in_file, header=TRUE)
#View(cluster_IGR_divergences)

cluster_IGR_divergences_long <- melt(cluster_IGR_divergences, measure.vars=c("Length_identity", "Nuc_identity"), variable.name="Category", value.name="Identity")

within_IGR_cluster_divergence_plot <- ggplot(cluster_IGR_divergences_long, aes(x=Identity)) +
  geom_histogram(binwidth=0.001) +
  facet_grid(Category~.) +
  labs(y="Count")

out_file=paste(out_dir, "/within_IGR_cluster_divergence_plot.tif", sep="")

tiff(filename=out_file, height=5, width=10, units="in", res=100)

within_IGR_cluster_divergence_plot

dev.off()

#####
# library(ggiraph)
# 
# igraph_test <- ggplot(switched_region_divergences, aes(x=Length_identity, y=Nuc_identity)) +
#   geom_point() +
#   geom_point_interactive(aes(data_id=Gene, tooltip=Gene)) +
#   geom_hline(yintercept=threshold, linetype="dashed", colour="red") +
#   geom_vline(xintercept=threshold, linetype="dashed", colour="red") +
#   labs(x="Length identity", y="Nucleotide identity")
# 
# ggiraph(code=print(igraph_test), zoom_max=10)
