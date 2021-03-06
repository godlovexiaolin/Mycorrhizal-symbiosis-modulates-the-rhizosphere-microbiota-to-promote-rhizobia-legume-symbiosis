
####苜蓿rpoB数据-数据准备
setwd("F:\\#R\\AMF\\Miseq\\Medicago\\R_code_for_github")

##########################################################
library(ggplot2)
library(agricolae)
library(vegan)

metadata <- read.csv(file = "rpoB_metadata.csv", row.names = 1)
feature_table <- read.csv(file = "rpoB_feature_table.csv", row.names = 1)
feature_table_quant <- read.csv(file = "rpoB_feature_table_quant.csv", row.names = 1)


########################################################################
###几大根瘤菌属水平
rhizobium_id <- subset(feature_table, ID2 != "")$ID ###592 OTUs

rhizobium_feature_table <- feature_table[row.names(feature_table) %in% rhizobium_id,]
rhizobium_feature_table_quant <- feature_table_quant[row.names(feature_table_quant) %in% rhizobium_id,]

########################################################################
###已知共生根瘤菌水平
symbiotic_rhizobium_id <- subset(feature_table, ID3 != "")$ID ###67 OTUs, 99样本，有6个样本没有

symbiotic_rhizobium_feature_table <- feature_table[row.names(feature_table) %in% symbiotic_rhizobium_id,]
symbiotic_rhizobium_feature_table_quant <- feature_table_quant[row.names(feature_table_quant) %in% symbiotic_rhizobium_id,]


##############################################################################
###67共生根瘤菌聚到种水平

rhizobia_species_feature_table_quant <- as.data.frame(aggregate(symbiotic_rhizobium_feature_table_quant[,8:82], 
                                                          list(symbiotic_rhizobium_feature_table_quant$Taxon.1),
                                                          sum))

row.names(rhizobia_species_feature_table_quant) <- rhizobia_species_feature_table_quant$Group.1

quant_rhizobium_spe <- as.data.frame(t(rhizobia_species_feature_table_quant[,2:76]))
quant_rhizobium_spe <- quant_rhizobium_spe[, colSums(quant_rhizobium_spe) > 0]

##########
quant_rhizobium_spe_metadata <- merge.data.frame(metadata[,1:5],quant_rhizobium_spe, by="row.names")
quant_rhizobium_spe_metadata$SUM <- rowSums(quant_rhizobium_spe_metadata[,7:22])
quant_rhizobium_spe_metadata$Noncompatible <- quant_rhizobium_spe_metadata$SUM - quant_rhizobium_spe_metadata$Sinorhizobium_medicae - quant_rhizobium_spe_metadata$Sinorhizobium_meliloti
quant_rhizobium_spe_metadata$Compatible <- quant_rhizobium_spe_metadata$Sinorhizobium_medicae + quant_rhizobium_spe_metadata$Sinorhizobium_meliloti

###
rhizosphere_quant_rhizobium_spe_metadata <- subset(quant_rhizobium_spe_metadata, Niche == "Rhizosphere")
rhizosphere_quant_rhizobium_spe_metadata$Genotype <- factor(rhizosphere_quant_rhizobium_spe_metadata$Genotype,levels=c("A17","lyk3","nfp","ipd3","dmi2","dmi3","pt4"))
###
root_quant_rhizobium_spe_metadata <- subset(quant_rhizobium_spe_metadata, Niche == "Root")
root_quant_rhizobium_spe_metadata$Genotype <- factor(root_quant_rhizobium_spe_metadata$Genotype,levels=c("A17","lyk3","nfp","ipd3","dmi2","dmi3","pt4"))


####根际土中根瘤菌的数目
#####Figure 4A

windows(6,4) 
ggplot(rhizosphere_quant_rhizobium_spe_metadata, aes(Genotype,SUM)) + scale_y_log10() +
  geom_boxplot(aes(colour=Genotype),size=1) +
  geom_jitter(aes(colour=Genotype, shape=Genotype), size=3, position = position_dodge(width=0.75)) +
  scale_shape_manual(values=c(17,17,17,17,19,19,19)) +
  xlab("") + ylab("Quantified rhizobia rpoB abundance (g-1)") + theme_bw() +
  theme_bw() +
  theme(legend.position="right") + 
  theme(legend.title = element_text(size=12,color="black", face = "bold"),
        legend.text= element_text(size=12,color="black"),
        axis.text= element_text(size=12,color="black"),
        axis.title= element_text(size=14,color="black", face= "bold")) 


#
rs <- kruskal(rhizosphere_quant_rhizobium_spe_metadata$SUM, rhizosphere_quant_rhizobium_spe_metadata$Genotype, group=TRUE, p.adj="fdr")


######Supplemental Figure 8
####去除苜蓿共生根瘤菌
windows(6,4) 
ggplot(rhizosphere_quant_rhizobium_spe_metadata, aes(Genotype,Noncompatible)) + scale_y_log10() +
  geom_boxplot(aes(colour=Genotype),size=1) +
  geom_jitter(aes(colour=Genotype, shape=Genotype), size=3, position = position_dodge(width=0.75)) +
  scale_shape_manual(values=c(17,17,17,17,19,19,19)) +
  xlab("") + ylab("Quantified non-compatible rhizobia rpoB abundance (g-1)") + theme_bw() +
  theme_bw() +
  theme(legend.position="right") + 
  theme(legend.title = element_text(size=12,color="black", face = "bold"),
        legend.text= element_text(size=12,color="black"),
        axis.text= element_text(size=12,color="black"),
        axis.title= element_text(size=14,color="black", face= "bold")) 


#
rs_non <- kruskal(rhizosphere_quant_rhizobium_spe_metadata$Noncompatible, rhizosphere_quant_rhizobium_spe_metadata$Genotype, group=TRUE, p.adj="fdr")


####只保留苜蓿共生根瘤菌
windows(6,4) 
ggplot(rhizosphere_quant_rhizobium_spe_metadata, aes(Genotype,Compatible)) + scale_y_log10() +
  geom_boxplot(aes(colour=Genotype),size=1) +
  geom_jitter(aes(colour=Genotype, shape=Genotype), size=3, position = position_dodge(width=0.75)) +
  scale_shape_manual(values=c(17,17,17,17,19,19,19)) +
  xlab("") + ylab("Quantified compatible rhizobia rpoB abundance (g-1)") + theme_bw() +
  theme_bw() +
  theme(legend.position="right") + 
  theme(legend.title = element_text(size=12,color="black", face = "bold"),
        legend.text= element_text(size=12,color="black"),
        axis.text= element_text(size=12,color="black"),
        axis.title= element_text(size=14,color="black", face= "bold")) 


#
rs_com <- kruskal(rhizosphere_quant_rhizobium_spe_metadata$Compatible, rhizosphere_quant_rhizobium_spe_metadata$Genotype, group=TRUE, p.adj="fdr")

####根内根瘤菌的数目
#####Supplementary Figure 7
#########
windows(6,4) 
ggplot(root_quant_rhizobium_spe_metadata, aes(Genotype,SUM)) + scale_y_log10() +
  geom_boxplot(aes(colour=Genotype),size=1) +
  geom_jitter(aes(colour=Genotype, shape=Genotype), size=3, position = position_dodge(width=0.75)) +
  scale_shape_manual(values=c(17,17,17,17,19,19,19)) +
  xlab("") + ylab("Quantified rhizobia rpoB abundance (g-1)") + theme_bw() +
  theme_bw() +
  theme(legend.position="right") + 
  theme(legend.title = element_text(size=12,color="black", face = "bold"),
        legend.text= element_text(size=12,color="black"),
        axis.text= element_text(size=12,color="black"),
        axis.title= element_text(size=14,color="black", face= "bold")) 


#
root <- kruskal(root_quant_rhizobium_spe_metadata$SUM, root_quant_rhizobium_spe_metadata$Genotype, group=TRUE, p.adj="fdr")


####Supplemental Figure 8:
####去除苜蓿共生根瘤菌
windows(6,4) 
ggplot(root_quant_rhizobium_spe_metadata, aes(Genotype,Noncompatible)) + scale_y_log10() +
  geom_boxplot(aes(colour=Genotype),size=1) +
  geom_jitter(aes(colour=Genotype, shape=Genotype), size=3, position = position_dodge(width=0.75)) +
  scale_shape_manual(values=c(17,17,17,17,19,19,19)) +
  xlab("") + ylab("Quantified non-compatible rhizobia rpoB abundance (g-1)") + theme_bw() +
  theme_bw() +
  theme(legend.position="right") + 
  theme(legend.title = element_text(size=12,color="black", face = "bold"),
        legend.text= element_text(size=12,color="black"),
        axis.text= element_text(size=12,color="black"),
        axis.title= element_text(size=14,color="black", face= "bold")) 


#
root_non <- kruskal(root_quant_rhizobium_spe_metadata$Noncompatible, root_quant_rhizobium_spe_metadata$Genotype, group=TRUE, p.adj="fdr")



####只保留苜蓿共生根瘤菌
windows(6,4) 
ggplot(root_quant_rhizobium_spe_metadata, aes(Genotype,Compatible)) + scale_y_log10() +
  geom_boxplot(aes(colour=Genotype),size=1) +
  geom_jitter(aes(colour=Genotype, shape=Genotype), size=3, position = position_dodge(width=0.75)) +
  scale_shape_manual(values=c(17,17,17,17,19,19,19)) +
  xlab("") + ylab("Quantified compatible rhizobia rpoB abundance (g-1)") + theme_bw() +
  theme_bw() +
  theme(legend.position="right") + 
  theme(legend.title = element_text(size=12,color="black", face = "bold"),
        legend.text= element_text(size=12,color="black"),
        axis.text= element_text(size=12,color="black"),
        axis.title= element_text(size=14,color="black", face= "bold")) 


#
root_com <- kruskal(root_quant_rhizobium_spe_metadata$Compatible, root_quant_rhizobium_spe_metadata$Genotype, group=TRUE, p.adj="fdr")

root_quant_rhizobium_spe_metadata$Infection <- c(rep("P",5),rep("N",10),rep("P",5),rep("N",10),rep("P",5))

####the presence of infection threads would be expected to harbour 
####a comparatively large load of symbiotically compatible rhizobia in roots 
####[Kruskal Wallis test, PFDR = 0.002].
root_infection <- kruskal(root_quant_rhizobium_spe_metadata$Compatible, root_quant_rhizobium_spe_metadata$Infection, group=TRUE, p.adj="fdr")


##############################################
#######################################
##############################################
#######################################
#######根瘤菌OTU PCOA分析
metadata_root <- subset(metadata, Niche == "Root")
symbiotic_rhizobium_feature_table_quant_root <- symbiotic_rhizobium_feature_table_quant[, names(symbiotic_rhizobium_feature_table_quant) %in% row.names(metadata_root)]
t_symbiotic_rhizobium_feature_table_quant_root <- as.data.frame(t(symbiotic_rhizobium_feature_table_quant_root))

metadata_rhizosphere <- subset(metadata, Niche == "Rhizosphere")
symbiotic_rhizobium_feature_table_quant_rhizosphere <- symbiotic_rhizobium_feature_table_quant[, names(symbiotic_rhizobium_feature_table_quant) %in% row.names(metadata_rhizosphere)]
t_symbiotic_rhizobium_feature_table_quant_rhizosphere <- as.data.frame(t(symbiotic_rhizobium_feature_table_quant_rhizosphere))


################################pcoa

t_symbiotic_rhizobium_feature_table_quant_rhizosphere_bray <- vegdist(t_symbiotic_rhizobium_feature_table_quant_rhizosphere, method="bray")

t_symbiotic_rhizobium_feature_table_quant_rhizosphere_pcoa <- cmdscale(t_symbiotic_rhizobium_feature_table_quant_rhizosphere_bray, eig = T, add = T)

t_symbiotic_rhizobium_feature_table_quant_rhizosphere_pcoa12 <- scores(t_symbiotic_rhizobium_feature_table_quant_rhizosphere_pcoa)[,1:2]
t_symbiotic_rhizobium_feature_table_quant_rhizosphere_prop <- t_symbiotic_rhizobium_feature_table_quant_rhizosphere_pcoa$eig/sum(t_symbiotic_rhizobium_feature_table_quant_rhizosphere_pcoa$eig)


###用以下代码
metadata_t_symbiotic_rhizobium_feature_table_quant_rhizosphere_pcoa12 <- cbind(metadata_rhizosphere, t_symbiotic_rhizobium_feature_table_quant_rhizosphere_pcoa12)
metadata_t_symbiotic_rhizobium_feature_table_quant_rhizosphere_pcoa12$Genotype <- factor(metadata_t_symbiotic_rhizobium_feature_table_quant_rhizosphere_pcoa12$Genotype,levels=c("A17","lyk3","nfp","ipd3","dmi2","dmi3","pt4", "Soil"))

####
windows(8,6)
p = ggplot(metadata_t_symbiotic_rhizobium_feature_table_quant_rhizosphere_pcoa12, aes(Dim1, Dim2, color=Genotype, shape=MS)) +
  geom_point(cex=5) +
  theme_bw() + 
  labs(x=paste("Unconstrained PCoA 1 (", format(100 * t_symbiotic_rhizobium_feature_table_quant_rhizosphere_prop[1], digits=4), "%)", sep=""),
       y=paste("Unconstrained PCoA 2 (", format(100 * t_symbiotic_rhizobium_feature_table_quant_rhizosphere_prop[2], digits=4), "%)", sep="")) +
  ggtitle(paste("PCoA for the microbial load of rhizobial cells in rhizosphere"))+
  theme_bw() + 
  theme(legend.position= "right",
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black")) +
  theme(title = element_text(size = 12, colour = "black"),
        legend.text = element_text(size = 12, colour = "black"),
        axis.title = element_text(size = 12, colour = "black", face = "bold"),
        axis.text = element_text(size = 10, colour = "black"))

p = p + stat_ellipse(level=0.68)
p


##########################################################pcoa
t_symbiotic_rhizobium_feature_table_quant_root_bray <- vegdist(t_symbiotic_rhizobium_feature_table_quant_root, method="bray")

t_symbiotic_rhizobium_feature_table_quant_root_pcoa <- cmdscale(t_symbiotic_rhizobium_feature_table_quant_root_bray, eig = T, add = T)

t_symbiotic_rhizobium_feature_table_quant_root_pcoa12 <- scores(t_symbiotic_rhizobium_feature_table_quant_root_pcoa)[,1:2]
t_symbiotic_rhizobium_feature_table_quant_root_prop <- t_symbiotic_rhizobium_feature_table_quant_root_pcoa$eig/sum(t_symbiotic_rhizobium_feature_table_quant_root_pcoa$eig)


###用以下代码
metadata_t_symbiotic_rhizobium_feature_table_quant_root_pcoa12 <- cbind(metadata_root, t_symbiotic_rhizobium_feature_table_quant_root_pcoa12)
metadata_t_symbiotic_rhizobium_feature_table_quant_root_pcoa12$Genotype <- factor(metadata_t_symbiotic_rhizobium_feature_table_quant_root_pcoa12$Genotype,levels=c("A17","lyk3","nfp","ipd3","dmi2","dmi3","pt4", "Soil"))

####
windows(8,6)
p = ggplot(metadata_t_symbiotic_rhizobium_feature_table_quant_root_pcoa12, aes(Dim1, Dim2, color=Genotype, shape=MS)) +
  geom_point(cex=5) +
  theme_bw() + 
  labs(x=paste("Unconstrained PCoA 1 (", format(100 * t_symbiotic_rhizobium_feature_table_quant_root_prop[1], digits=4), "%)", sep=""),
       y=paste("Unconstrained PCoA 2 (", format(100 * t_symbiotic_rhizobium_feature_table_quant_root_prop[2], digits=4), "%)", sep="")) +
  ggtitle(paste("PCoA for the microbial load of rhizobial cells in root"))+
  theme_bw() + 
  theme(legend.position= "right",
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black")) +
  theme(title = element_text(size = 12, colour = "black"),
        legend.text = element_text(size = 12, colour = "black"),
        axis.title = element_text(size = 12, colour = "black", face = "bold"),
        axis.text = element_text(size = 10, colour = "black"))

p = p + stat_ellipse(level=0.68)
p


#################################species level heatmap
##############################################
root_quant_rhizobium_spe.fdr <- read.csv(file="基于根际genotype的差异root_quant_rhizobium_spe.fdr均值检验.csv", row.names=1)
rhizosphere_quant_rhizobium_spe.fdr <- read.csv(file="基于根际genotype的差异rhizosphere_quant_rhizobium_spe.fdr均值检验.csv",row.names=1)


rpoB_rhizobium_spe_tree <- read.tree(file="rpoB_rhizobium_spe_used.nwk")
match_id <- match(rpoB_rhizobium_spe_tree$tip.label, row.names(rhizosphere_quant_rhizobium_spe.fdr))

root_quant_rhizobium_spe.fdr <- root_quant_rhizobium_spe.fdr[match_id, ]
rhizosphere_quant_rhizobium_spe.fdr <- rhizosphere_quant_rhizobium_spe.fdr[match_id, ]

###根瘤菌种水平 
###根际土比值
rs_rhizobium_spe_ratio <- data.frame(lyk3 = log((rhizosphere_quant_rhizobium_spe.fdr$lyk3+1)/(rhizosphere_quant_rhizobium_spe.fdr$A17+1),base = 2),
                                     nfp = log((rhizosphere_quant_rhizobium_spe.fdr$nfp+1)/(rhizosphere_quant_rhizobium_spe.fdr$A17+1),base = 2),
                                     ipd3 = log((rhizosphere_quant_rhizobium_spe.fdr$ipd3+1)/(rhizosphere_quant_rhizobium_spe.fdr$A17+1),base = 2),
                                     dmi2 = log((rhizosphere_quant_rhizobium_spe.fdr$dmi2+1)/(rhizosphere_quant_rhizobium_spe.fdr$A17+1),base = 2),
                                     dmi3 = log((rhizosphere_quant_rhizobium_spe.fdr$dmi3+1)/(rhizosphere_quant_rhizobium_spe.fdr$A17+1),base = 2),
                                     pt4 = log((rhizosphere_quant_rhizobium_spe.fdr$pt4+1)/(rhizosphere_quant_rhizobium_spe.fdr$A17+1),base = 2))

row.names(rs_rhizobium_spe_ratio) <- row.names(rhizosphere_quant_rhizobium_spe.fdr)

###显著性
names(rhizosphere_quant_rhizobium_spe.fdr)

rhizosphere_quant_rhizobium_spe.fdr$log10_lyk3 <- -log10(rhizosphere_quant_rhizobium_spe.fdr$p.chisq_A17_lyk3)
rhizosphere_quant_rhizobium_spe.fdr$log10_lyk3 <- ifelse(rhizosphere_quant_rhizobium_spe.fdr[,1] < rhizosphere_quant_rhizobium_spe.fdr[,5],
                                                         rhizosphere_quant_rhizobium_spe.fdr$log10_lyk3,-rhizosphere_quant_rhizobium_spe.fdr$log10_lyk3)

rhizosphere_quant_rhizobium_spe.fdr$log10_nfp <- -log10(rhizosphere_quant_rhizobium_spe.fdr$p.chisq_A17_nfp)
rhizosphere_quant_rhizobium_spe.fdr$log10_nfp <- ifelse(rhizosphere_quant_rhizobium_spe.fdr[,1] < rhizosphere_quant_rhizobium_spe.fdr[,6],
                                                        rhizosphere_quant_rhizobium_spe.fdr$log10_nfp,-rhizosphere_quant_rhizobium_spe.fdr$log10_nfp)

rhizosphere_quant_rhizobium_spe.fdr$log10_ipd3 <- -log10(rhizosphere_quant_rhizobium_spe.fdr$p.chisq_A17_ipd3)
rhizosphere_quant_rhizobium_spe.fdr$log10_ipd3 <- ifelse(rhizosphere_quant_rhizobium_spe.fdr[,1] < rhizosphere_quant_rhizobium_spe.fdr[,4],
                                                         rhizosphere_quant_rhizobium_spe.fdr$log10_ipd3,-rhizosphere_quant_rhizobium_spe.fdr$log10_ipd3)

rhizosphere_quant_rhizobium_spe.fdr$log10_dmi2 <- -log10(rhizosphere_quant_rhizobium_spe.fdr$p.chisq_A17_dmi2)
rhizosphere_quant_rhizobium_spe.fdr$log10_dmi2 <- ifelse(rhizosphere_quant_rhizobium_spe.fdr[,1] < rhizosphere_quant_rhizobium_spe.fdr[,2],
                                                         rhizosphere_quant_rhizobium_spe.fdr$log10_dmi2,-rhizosphere_quant_rhizobium_spe.fdr$log10_dmi2)

rhizosphere_quant_rhizobium_spe.fdr$log10_dmi3 <- -log10(rhizosphere_quant_rhizobium_spe.fdr$p.chisq_A17_dmi3)
rhizosphere_quant_rhizobium_spe.fdr$log10_dmi3 <- ifelse(rhizosphere_quant_rhizobium_spe.fdr[,1] < rhizosphere_quant_rhizobium_spe.fdr[,3],
                                                         rhizosphere_quant_rhizobium_spe.fdr$log10_dmi3,-rhizosphere_quant_rhizobium_spe.fdr$log10_dmi3)

rhizosphere_quant_rhizobium_spe.fdr$log10_pt4 <- -log10(rhizosphere_quant_rhizobium_spe.fdr$p.chisq_A17_pt4)
rhizosphere_quant_rhizobium_spe.fdr$log10_pt4 <- ifelse(rhizosphere_quant_rhizobium_spe.fdr[,1] < rhizosphere_quant_rhizobium_spe.fdr[,7],
                                                        rhizosphere_quant_rhizobium_spe.fdr$log10_pt4,-rhizosphere_quant_rhizobium_spe.fdr$log10_pt4)

rhizosphere_quant_rhizobium_spe.fdr[,36:41][is.na(rhizosphere_quant_rhizobium_spe.fdr[,36:41])] <- 0


rs_rhizobium_spe_sig <- rhizosphere_quant_rhizobium_spe.fdr[,36:41]


###
library(ComplexHeatmap)
library(circlize)

mycol <- colorRamp2(c(-2, 0, 2), c("green4","white", "orangered"))
Heatmap_rs_spe <- Heatmap(t(rs_rhizobium_spe_ratio), col = mycol, name = "log10(mutants/A17)",
                          cluster_columns = F, cluster_rows = F, 
                          show_row_names = T, show_column_names = T,
                          rect_gp = gpar(col = "black",lty = 1, lwd = 1),
                          row_dend_width = unit(4, "cm"),
                          show_heatmap_legend = T)

windows(6,4)
Heatmap_rs_spe

###
mycol <- colorRamp2(c(-2, 0, 2), c("green4","white", "red"))
Heatmap_rs_sig <- Heatmap(t(rs_rhizobium_spe_sig), col = mycol, name = "log10(FDR)",
                          cluster_columns = F, cluster_rows = F, 
                          show_row_names = T, show_column_names = T,
                          rect_gp = gpar(col = "black",lty = 1, lwd = 1),
                          row_dend_width = unit(4, "cm"),
                          column_names_side = "top",
                          show_heatmap_legend = T)

windows(6,4)
Heatmap_rs_sig


###去除根际土没有检测到的种
rs_rhizobium_spe_sig2 <- rs_rhizobium_spe_sig[-c(3,6),]

###
mycol <- colorRamp2(c(-2, 0, 2), c("#0093A9", "white", "#AD1E47"))
Heatmap_rs_sig2 <- Heatmap(t(rs_rhizobium_spe_sig2), col = mycol, name = "log10(FDR)",
                           cluster_columns = F, cluster_rows = F, 
                           show_row_names = T, show_column_names = T,
                           rect_gp = gpar(col = "black",lty = 1, lwd = 1),
                           row_dend_width = unit(4, "cm"),
                           column_names_side = "top",
                           show_heatmap_legend = T)

windows(6,4)
Heatmap_rs_sig2


###########################
##根内比值
root_rhizobium_spe_ratio <- data.frame(lyk3 = log((root_quant_rhizobium_spe.fdr$lyk3+1)/(root_quant_rhizobium_spe.fdr$A17+1),base = 2),
                                       nfp = log((root_quant_rhizobium_spe.fdr$nfp+1)/(root_quant_rhizobium_spe.fdr$A17+1),base = 2),
                                       ipd3 = log((root_quant_rhizobium_spe.fdr$ipd3+1)/(root_quant_rhizobium_spe.fdr$A17+1),base = 2),
                                       dmi2 = log((root_quant_rhizobium_spe.fdr$dmi2+1)/(root_quant_rhizobium_spe.fdr$A17+1),base = 2),
                                       dmi3 = log((root_quant_rhizobium_spe.fdr$dmi3+1)/(root_quant_rhizobium_spe.fdr$A17+1),base = 2),
                                       pt4 = log((root_quant_rhizobium_spe.fdr$pt4+1)/(root_quant_rhizobium_spe.fdr$A17+1),base = 2))

row.names(root_rhizobium_spe_ratio) <- row.names(root_quant_rhizobium_spe.fdr)

###显著性
names(root_quant_rhizobium_spe.fdr)

root_quant_rhizobium_spe.fdr$log10_lyk3 <- -log10(root_quant_rhizobium_spe.fdr$p.chisq_A17_lyk3)
root_quant_rhizobium_spe.fdr$log10_lyk3 <- ifelse(root_quant_rhizobium_spe.fdr[,1] < root_quant_rhizobium_spe.fdr[,5],
                                                  root_quant_rhizobium_spe.fdr$log10_lyk3,-root_quant_rhizobium_spe.fdr$log10_lyk3)

root_quant_rhizobium_spe.fdr$log10_nfp <- -log10(root_quant_rhizobium_spe.fdr$p.chisq_A17_nfp)
root_quant_rhizobium_spe.fdr$log10_nfp <- ifelse(root_quant_rhizobium_spe.fdr[,1] < root_quant_rhizobium_spe.fdr[,6],
                                                 root_quant_rhizobium_spe.fdr$log10_nfp,-root_quant_rhizobium_spe.fdr$log10_nfp)

root_quant_rhizobium_spe.fdr$log10_ipd3 <- -log10(root_quant_rhizobium_spe.fdr$p.chisq_A17_ipd3)
root_quant_rhizobium_spe.fdr$log10_ipd3 <- ifelse(root_quant_rhizobium_spe.fdr[,1] < root_quant_rhizobium_spe.fdr[,4],
                                                  root_quant_rhizobium_spe.fdr$log10_ipd3,-root_quant_rhizobium_spe.fdr$log10_ipd3)

root_quant_rhizobium_spe.fdr$log10_dmi2 <- -log10(root_quant_rhizobium_spe.fdr$p.chisq_A17_dmi2)
root_quant_rhizobium_spe.fdr$log10_dmi2 <- ifelse(root_quant_rhizobium_spe.fdr[,1] < root_quant_rhizobium_spe.fdr[,2],
                                                  root_quant_rhizobium_spe.fdr$log10_dmi2,-root_quant_rhizobium_spe.fdr$log10_dmi2)

root_quant_rhizobium_spe.fdr$log10_dmi3 <- -log10(root_quant_rhizobium_spe.fdr$p.chisq_A17_dmi3)
root_quant_rhizobium_spe.fdr$log10_dmi3 <- ifelse(root_quant_rhizobium_spe.fdr[,1] < root_quant_rhizobium_spe.fdr[,3],
                                                  root_quant_rhizobium_spe.fdr$log10_dmi3,-root_quant_rhizobium_spe.fdr$log10_dmi3)

root_quant_rhizobium_spe.fdr$log10_pt4 <- -log10(root_quant_rhizobium_spe.fdr$p.chisq_A17_pt4)
root_quant_rhizobium_spe.fdr$log10_pt4 <- ifelse(root_quant_rhizobium_spe.fdr[,1] < root_quant_rhizobium_spe.fdr[,7],
                                                 root_quant_rhizobium_spe.fdr$log10_pt4,-root_quant_rhizobium_spe.fdr$log10_pt4)

root_quant_rhizobium_spe.fdr[,36:41][is.na(root_quant_rhizobium_spe.fdr[,36:41])] <- 0


root_rhizobium_spe_sig <- root_quant_rhizobium_spe.fdr[,36:41]


###
library(ComplexHeatmap)
library(circlize)

mycol <- colorRamp2(c(-2, 0, 2), c("green4","white", "orangered"))
Heatmap_root_spe <- Heatmap(t(root_rhizobium_spe_ratio), col = mycol, name = "log10(mutants/A17)",
                            cluster_columns = F, cluster_rows = F, 
                            show_row_names = T, show_column_names = T,
                            rect_gp = gpar(col = "black",lty = 1, lwd = 1),
                            row_dend_width = unit(4, "cm"),
                            show_heatmap_legend = T)

windows(6,4)
Heatmap_root_spe

###
mycol <- colorRamp2(c(-2, 0, 2), c("green4","white", "red"))
Heatmap_root_sig <- Heatmap(t(root_rhizobium_spe_sig), col = mycol, name = "log10(FDR)",
                            cluster_columns = F, cluster_rows = F, 
                            show_row_names = T, show_column_names = T,
                            rect_gp = gpar(col = "black",lty = 1, lwd = 1),
                            row_dend_width = unit(4, "cm"),
                            column_names_side = "top",
                            show_heatmap_legend = T)

windows(6,4)
Heatmap_root_sig


###去除根内没有检测到的种
root_rhizobium_spe_sig2 <- root_rhizobium_spe_sig[-c(3,6,8,9,14),]

###
mycol <- colorRamp2(c(-2, 0, 2), c("#0093A9", "white", "#AD1E47"))
Heatmap_root_sig2 <- Heatmap(t(root_rhizobium_spe_sig2), col = mycol, name = "log10(FDR)",
                             cluster_columns = F, cluster_rows = F, 
                             show_row_names = T, show_column_names = T,
                             rect_gp = gpar(col = "black",lty = 1, lwd = 1),
                             row_dend_width = unit(4, "cm"),
                             column_names_side = "top",
                             show_heatmap_legend = T)

windows(6,4)
Heatmap_root_sig2








