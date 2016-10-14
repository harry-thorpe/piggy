library(cowplot)
library(reshape2)

roary_gene_divergences <- read.csv("/media/harry/extra/igry_test/roary_gene_divergences.csv")
#View(roary_gene_divergences)

roary_gene_divergences_nuc_summary <- summarySE(roary_gene_divergences, measurevar="Nuc_identity", groupvars="Gene")
roary_gene_divergences_len_summary <- summarySE(roary_gene_divergences, measurevar="Length_identity", groupvars="Gene")

roary_gene_divergences_nuc_summary$Category <- "Gene"
roary_gene_divergences_len_summary$Category <- "Gene"

ggplot(roary_gene_divergences_nuc_summary, aes(x=Nuc_identity)) +
  geom_histogram(binwidth=0.01)

ggplot(roary_gene_divergences_len_summary, aes(x=Length_identity)) +
  geom_histogram(binwidth=0.01)

#####

igry_IGR_divergences <- read.csv("/media/harry/extra/igry_test/igry_IGR_divergences.csv")
#View(igry_IGR_divergences)

igry_IGR_divergences_nuc_summary <- summarySE(igry_IGR_divergences, measurevar="Nuc_identity", groupvars="Gene")
igry_IGR_divergences_len_summary <- summarySE(igry_IGR_divergences, measurevar="Length_identity", groupvars="Gene")

igry_IGR_divergences_nuc_summary$Category <- "IGR"
igry_IGR_divergences_len_summary$Category <- "IGR"

ggplot(igry_IGR_divergences_nuc_summary, aes(x=Nuc_identity)) +
  geom_histogram(binwidth=0.01)

ggplot(igry_IGR_divergences_len_summary, aes(x=Length_identity)) +
  geom_histogram(binwidth=0.01)

#####

divergence_nuc_df <- rbind(roary_gene_divergences_nuc_summary, igry_IGR_divergences_nuc_summary)

div_nuc_plot <- ggplot(divergence_nuc_df, aes(x=Nuc_identity, fill=Category)) +
  geom_histogram(binwidth=0.005) +
  geom_vline(xintercept=0.9, linetype="dashed", colour="red") +
  scale_x_continuous(limits=c(0.8,1.01)) +
  labs(x="Nucleotide identity", y="Count") +
  facet_grid(Category~., scales="free")

tiff("/media/harry/extra/igry_test/figures/div_nuc_plot.tif", height=5, width=10, units="in", res=100)

div_nuc_plot

dev.off()

#####

divergence_len_df <- rbind(roary_gene_divergences_len_summary, igry_IGR_divergences_len_summary)

div_len_plot <- ggplot(divergence_len_df, aes(x=Length_identity, fill=Category)) +
  geom_histogram(binwidth=0.005) +
  geom_vline(xintercept=0.9, linetype="dashed", colour="red") +
  scale_x_continuous(limits=c(0.8,1.01)) +
  labs(x="Length identity", y="Count") +
  facet_grid(Category~., scales="free")

tiff("/media/harry/extra/igry_test/figures/div_len_plot.tif", height=5, width=10, units="in", res=100)

div_len_plot

dev.off()

#####

switched_region_divergences <- read.csv("/media/harry/extra/igry_test/switched_region_divergences.csv")
#View(switched_region_divergences)

switched_region_divergences_nuc_summary <- summarySE(switched_region_divergences, measurevar="Nuc_identity", groupvars="Gene")
switched_region_divergences_len_summary <- summarySE(switched_region_divergences, measurevar="Length_identity", groupvars="Gene")

ggplot(switched_region_divergences_nuc_summary, aes(x=Nuc_identity)) +
  geom_histogram(binwidth=0.01)

ggplot(switched_region_divergences_len_summary, aes(x=Length_identity)) +
  geom_histogram(binwidth=0.01)

switched_region_divergences_long <- melt(switched_region_divergences, id.vars="Gene", measure.vars=c("Length_identity", "Nuc_identity"))

sr_div_hist <- ggplot(switched_region_divergences_long, aes(x=value)) +
  geom_histogram(binwidth=0.005) +
  scale_x_continuous(limits=c(0,1.01)) +
  labs(x="Identity", y="Count") +
  facet_grid(variable~., scales="free")

tiff("/media/harry/extra/igry_test/figures/sr_div_hist.tif", height=5, width=10, units="in", res=100)

sr_div_hist

dev.off()

sr_div_point <- ggplot(switched_region_divergences, aes(x=Length_identity, y=Nuc_identity)) +
  geom_point() +
  geom_hline(yintercept=0.9, linetype="dashed", colour="red") +
  geom_vline(xintercept=0.9, linetype="dashed", colour="red") +
  labs(x="Length identity", y="Nucleotide identity")

tiff("/media/harry/extra/igry_test/figures/sr_div_point.tif", height=5, width=10, units="in", res=100)

sr_div_point

dev.off()

#####
library(ggiraph)

igraph_test <- ggplot(switched_region_divergences, aes(x=Length_identity, y=Nuc_identity)) +
  geom_point() +
  geom_point_interactive(aes(data_id=Id_2, tooltip=Id_2)) +
  geom_hline(yintercept=0.9, linetype="dashed", colour="red") +
  geom_vline(xintercept=0.9, linetype="dashed", colour="red") +
  labs(x="Length identity", y="Nucleotide identity")

ggiraph(code=print(igraph_test), zoom_max=10)
