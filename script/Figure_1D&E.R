
###Figure 1

setwd("F:\\#R\\AMF\\Miseq\\Medicago\\R_code_for_github")

library(ggplot2)

#############################################################################################
#############################################################################################
#############################################################################################
phylum_mean_data <- read.csv(file = "phylum_mean_sd_data.csv", row.names = 1)
phylum_cope_adjusted_mean_data <- read.csv(file = "phylum_cope_adjusted_mean_sd_data.csv", row.names = 1)
phylum_quant_mean_data <- read.csv(file = "phylum_quant_mean_sd_data.csv", row.names = 1)
phylum_quant_cope_adjusted_mean_data <- read.csv(file = "phylum_quant_cope_adjusted_mean_sd_data.csv", row.names = 1)

#############
phylum_mean_data$profiling <- "16S rRNA genes"
phylum_mean_data <- subset(phylum_mean_data, Niche != "Soil")
phylum_mean_data$Genotype <- factor(phylum_mean_data$Genotype,levels=c("A17","lyk3","nfp","ipd3","dmi2","dmi3","pt4"))
phylum_sort <- phylum_mean_data$tax[1:12]
phylum_mean_data$tax <- factor(phylum_mean_data$tax,levels=phylum_sort) ###后续也按这个排序，以防混乱


phylum_cope_adjusted_mean_data$profiling <- "Copy-number-weighted 16S rRNA genes"
phylum_cope_adjusted_mean_data <- subset(phylum_cope_adjusted_mean_data, Niche != "Soil")
phylum_cope_adjusted_mean_data$Genotype <- factor(phylum_cope_adjusted_mean_data$Genotype,levels=c("A17","lyk3","nfp","ipd3","dmi2","dmi3","pt4"))
phylum_cope_adjusted_mean_data$tax <- factor(phylum_cope_adjusted_mean_data$tax,levels=phylum_sort) ###后续也按这个排序，以防混乱


phylum_quant_mean_data$profiling <- "16S rRNA genes"
phylum_quant_mean_data <- subset(phylum_quant_mean_data, Niche != "Soil")
phylum_quant_cope_adjusted_mean_data$Genotype <- factor(phylum_quant_cope_adjusted_mean_data$Genotype,levels=c("A17","lyk3","nfp","ipd3","dmi2","dmi3","pt4"))
phylum_quant_mean_data$tax <- factor(phylum_quant_mean_data$tax,levels=phylum_sort) ###后续也按这个排序，以防混乱


phylum_quant_cope_adjusted_mean_data$profiling <- "Copy-number-weighted 16S rRNA genes"
phylum_quant_cope_adjusted_mean_data <- subset(phylum_quant_cope_adjusted_mean_data, Niche != "Soil")
phylum_quant_cope_adjusted_mean_data$Genotype <- factor(phylum_quant_cope_adjusted_mean_data$Genotype,levels=c("A17","lyk3","nfp","ipd3","dmi2","dmi3","pt4"))
phylum_quant_cope_adjusted_mean_data$tax <- factor(phylum_quant_cope_adjusted_mean_data$tax,levels=phylum_sort) ###后续也按这个排序，以防混乱


###
col_tax <- c("orangered",rainbow(12)[7],rainbow(12)[2],rainbow(12)[8],
             rainbow(12)[3],"deepskyblue",rainbow(12)[4],rainbow(12)[10],
             rainbow(12)[5],rainbow(12)[11],rainbow(12)[6],rainbow(12)[12]) #考虑红绿色盲


library(RColorBrewer)

col_tax <- colorRampPalette(brewer.pal(9,"Set1"))(12) ###离散型配色方案

###对色盲友好的调色板
#col_tax <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

###Figure 1D
windows()
p = ggplot(phylum_mean_data, aes(x=Genotype, y = value, fill = tax )) + 
  geom_bar(stat = "identity",position="fill", width=0.7)+ 
  scale_y_continuous(labels = scales::percent) + 
  scale_fill_manual(values=col_tax)  +
  facet_grid( ~ Niche, scales = "free_x", space = "free", switch = "x") + 
  xlab("")+ylab("RMP 16S frequency (%)")+ 
  theme_classic() +
  theme(axis.text.x=element_text(angle=45,vjust=1, hjust=1))

p 

windows()
p = ggplot(phylum_cope_adjusted_mean_data, aes(x=Genotype, y = value, fill = tax )) + 
  geom_bar(stat = "identity",position="fill", width=0.7)+ 
  scale_y_continuous(labels = scales::percent) + 
  scale_fill_manual(values=col_tax)  +
  facet_grid( ~ Niche, scales = "free_x", space = "free", switch = "x") + 
  xlab("")+ylab("RMP phyla abundance (%)")+ 
  theme_classic() +
  theme(axis.text.x=element_text(angle=45,vjust=1, hjust=1))

p

####################
windows()
p = ggplot(phylum_quant_mean_data, aes(x=Genotype, y = value, fill = tax )) +
  geom_col(width=0.7) +
  scale_fill_manual(values=col_tax)  +
  facet_grid( ~ Niche, scales = "free_x", space = "free", switch = "x") + 
  theme(strip.background = element_blank())+
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank())+
  xlab("")+ylab("QMP 16S abundance (g-1)")+ 
  theme_classic()+
  theme(axis.text.x=element_text(angle=45,vjust=1, hjust=1))
p

###
###Figure 1E
windows()
p = ggplot(phylum_quant_cope_adjusted_mean_data, aes(x=Genotype, y = value, fill = tax )) +
  geom_col(width=0.7) +
  scale_fill_manual(values=col_tax)  +
  facet_grid( ~ Niche, scales = "free_x", space = "free", switch = "x") + 
  theme(strip.background = element_blank())+
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank())+
  xlab("")+ylab("QMP phyla abundance (g-1)")+ 
  theme_classic()+
  theme(axis.text.x=element_text(angle=45,vjust=1, hjust=1))
p

