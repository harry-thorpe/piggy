#!/usr/bin/env Rscript

## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column    
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}
#####

is.installed <- function(mypkg) is.element(mypkg, installed.packages()[,1]) 

library(ggplot2)
library(reshape2)

if(is.installed("cowplot") == TRUE){
  library(cowplot)
}

args <- commandArgs(trailingOnly=TRUE)

out_dir=args[1]
roary_dir=args[2]

#out_dir <- "/media/harry/extra/roary_piggy_comparison"
#roary_dir <- "/media/harry/extra/roary_piggy_comparison"

#####

in_file=paste(roary_dir, "/gene_presence_absence.csv", sep="")

gene_presence_absence <- read.csv(file=in_file, stringsAsFactors=FALSE, na.strings="", header=TRUE)
#View(gene_presence_absence)

Category <- rep("Gene", nrow(gene_presence_absence))

gene_presence_absence <- data.frame(Category, gene_presence_absence, stringsAsFactors=FALSE)

in_file=paste(out_dir, "/IGR_presence_absence.csv", sep="")

IGR_presence_absence <- read.csv(file=in_file, stringsAsFactors=FALSE, na.strings="", header=TRUE)
#View(IGR_presence_absence)

Category <- rep("IGR", nrow(IGR_presence_absence))

IGR_presence_absence <- data.frame(Category, IGR_presence_absence, stringsAsFactors=FALSE)

#####

all_presence_absence <- rbind(gene_presence_absence, IGR_presence_absence)

if(max(all_presence_absence$No..isolates) > 100){
  bin_width <- max(all_presence_absence$No..isolates) / 100
}else{
  bin_width <- 1
}

all_freq_plot <- ggplot(all_presence_absence, aes(x=No..isolates, fill=Category)) +
  geom_histogram(binwidth=bin_width, position="dodge") +
  labs(x="Isolates", y="Count")

out_file=paste(out_dir, "/gene_IGR_frequency.tif", sep="")

tiff(filename=out_file, height=5, width=10, units="in", res=100)

all_freq_plot

dev.off()

#####

col_array <- seq(16, ncol(gene_presence_absence), 1)
col_count <- length(col_array)

row_array <- seq(1, nrow(gene_presence_absence), 1)
row_count <- length(row_array)

Rep <- NULL
Isolates <- NULL
Count <- NULL
Category <- NULL

count <- 0
for(rep in 1:100){
  col_array_resampled <- sample(col_array, replace=FALSE)
  
  rep_array <- rep(0, row_count)
  for(col in 1:col_count){
    
    rep_array[ is.na(gene_presence_absence[,col_array_resampled[col]]) == FALSE ] <- 1
    
    count <- count + 1
    Category[count] <- "Gene"
    Rep[count] <- rep
    Isolates[count] <- col
    Count[count] <- sum(rep_array)
  }
}

gene_accumulation_df <- data.frame(Rep, Isolates, Category, Count, stringsAsFactors=FALSE)

gene_accumulation_df_summary <- summarySE(gene_accumulation_df, measurevar="Count", groupvars=c("Category", "Isolates"))

#####

col_array <- seq(16, ncol(IGR_presence_absence), 1)
col_count <- length(col_array)

row_array <- seq(1, nrow(IGR_presence_absence), 1)
row_count <- length(row_array)

Rep <- NULL
Isolates <- NULL
Count <- NULL
Category <- NULL

count <- 0
for(rep in 1:100){
  col_array_resampled <- sample(col_array, replace=FALSE)
  
  rep_array <- rep(0, row_count)
  for(col in 1:col_count){
    
    rep_array[ is.na(IGR_presence_absence[,col_array_resampled[col]]) == FALSE ] <- 1
    
    count <- count + 1
    Category[count] <- "IGR"
    Rep[count] <- rep
    Isolates[count] <- col
    Count[count] <- sum(rep_array)
  }
}

IGR_accumulation_df <- data.frame(Rep, Isolates, Category, Count, stringsAsFactors=FALSE)

IGR_accumulation_df_summary <- summarySE(IGR_accumulation_df, measurevar="Count", groupvars=c("Category", "Isolates"))

#####

all_accumulation_df_summary <- rbind(gene_accumulation_df_summary, IGR_accumulation_df_summary)

y_max <- max(all_accumulation_df_summary$Count)
y_max <- (((as.integer(y_max / 1000)) + 1) * 1000)

all_accumulation_plot <- ggplot(all_accumulation_df_summary, aes(x=Isolates, y=Count, colour=Category, group=Category)) +
  geom_line() +
  scale_y_continuous(limits=c(0,y_max))

out_file=paste(out_dir, "/gene_IGR_accumulation.tif", sep="")

tiff(filename=out_file, height=5, width=10, units="in", res=100)

all_accumulation_plot

dev.off()
