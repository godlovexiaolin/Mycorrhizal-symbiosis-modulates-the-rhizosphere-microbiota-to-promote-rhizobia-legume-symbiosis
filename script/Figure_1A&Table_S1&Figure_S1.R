
###菌根真菌-差异OTU分析
setwd("F:\\#R\\AMF\\Miseq\\Medicago\\R_code_for_github")

#####################
metadata <- read.csv(file = "AMF_metadata.csv", row.names = 1)
feature_table <- read.csv(file = "AMF_feature_table.csv")
feature_table_quant <- read.csv(file = "AMF_feature_table_quant.csv")

########因为有的样本就没有菌根真菌，所以不对样本进行标准化，只分析绝对丰度
###MAARJAM注释信息
otu_taxonomy <- read.csv(file = "AMF_OTU_MAARJAM.csv",header = T)
otu_taxonomy <- otu_taxonomy[!duplicated(otu_taxonomy$QueryID),]
names(otu_taxonomy)
otu_taxonomy_vt <- subset(otu_taxonomy, Identity >= 90 & AlignmentLen >= 140)

###总共48个OTU注释为VT
vt_table_quant <- merge.data.frame(otu_taxonomy_vt, feature_table_quant, by.x="QueryID", by.y="Feature.ID", all.x = T)
row.names(vt_table_quant) <- paste(vt_table_quant$ID, vt_table_quant$SubjectDef, sep = "|")
#write.csv(vt_table_quant, file = "AMF_vt_table_quant.csv")

quant_vt <- as.data.frame(t(vt_table_quant[,17:91]))
quant_vt <- quant_vt[, colSums(quant_vt) > 0]


####################################################################################
####################################################################################
####################################################################################
###only root amf are used

#############Root_genotype
metadata_root <- subset(metadata, Niche == "Root")
metadata_root$Genotype <- factor(metadata_root$Genotype,levels=c("A17","lyk3","nfp","ipd3","dmi2","dmi3","pt4"))

root_quant_vt <- quant_vt[row.names(quant_vt) %in% row.names(metadata_root),]
root_quant_vt_metadata <- merge.data.frame(metadata_root[,1:5],root_quant_vt[, colSums(root_quant_vt) > 0], by="row.names")
names(root_quant_vt_metadata)

####Table S1
root_quant_vt_metadata$AMF <- rowSums(root_quant_vt_metadata[,7:34])
###########根内只检测到了28个VT

library(ggplot2)
library(agricolae)

###Figure 1A

windows(6,4) 
ggplot(root_quant_vt_metadata, aes(Genotype,AMF)) +
  geom_boxplot(aes(colour=Genotype),size=1) +
  geom_jitter(aes(colour=Genotype), size=3, position = position_dodge(width=0.75)) +
  xlab("") + ylab("Quantified AMF 18S abundance (g-1)") + theme_bw() +
  theme_bw() +
  theme(legend.position="right") + 
  theme(legend.title = element_text(size=12,color="black", face = "bold"),
        legend.text= element_text(size=12,color="black"),
        axis.text= element_text(size=12,color="black"),
        axis.title= element_text(size=14,color="black", face= "bold"))


quant_vt_SE <- summarySE(root_quant_vt_metadata, measurevar= "AMF", groupvars= "Genotype")

windows(4,3)
g1 <- ggplot(quant_vt_SE, aes(Genotype, AMF, fill=Genotype)) + 
  geom_bar(stat="identity", width = 0.8) +
  xlab("") + ylab("Quantified AMF 18S abundance in root (g-1)") + theme_bw() +
  theme_bw() +
  theme(legend.position="none") + 
  theme(legend.title = element_text(size=8,color="black", face = "bold"),
        legend.text= element_text(size=8,color="black"),
        axis.text.x = element_text(size=8,color="black", angle = 45, hjust = 1),
        axis.text.y = element_text(size=8,color="black"),
        axis.title= element_text(size=8,color="black", face= "bold")) 

g2 <- g1 + geom_jitter(data = root_quant_vt_metadata, aes(Genotype, AMF), size=2, width = 0.2) +
  geom_errorbar(aes(ymin=AMF-se, ymax=AMF+se), data = quant_vt_SE, width=.2, colour = "black") 

g2

#
a <- kruskal(root_quant_vt_metadata$AMF, root_quant_vt_metadata$Genotype, group=TRUE, p.adj="fdr")

##################################################################
####PCOA分析
####因为有的样本没有检测到菌根真菌，所以把非菌根真菌及spike作为其它
names(vt_table_quant)
names(feature_table_quant)

colSums(vt_table_quant[,17:51]) 
colSums(feature_table_quant[,4:38]) 


root_quant_vt_others <- cbind(root_quant_vt, Others = metadata$Cope_per_g[1:35] + colSums(feature_table_quant[,4:38]) - colSums(vt_table_quant[,17:51]))

root_quant_vt_bray <- vegdist(root_quant_vt_others[, colSums(root_quant_vt_others) > 0], method="bray")

root_quant_vt_pcoa <- cmdscale(root_quant_vt_bray, eig = T, add = T)

root_quant_vt_pcoa12 <- scores(root_quant_vt_pcoa)[,1:2]
root_quant_vt_prop <- root_quant_vt_pcoa$eig/sum(root_quant_vt_pcoa$eig)


###用以下代码
metadata_root_quant_vt_pcoa12 <- cbind(metadata_root[, 1:5], root_quant_vt_pcoa12)
metadata_root_quant_vt_pcoa12$Genotype <- factor(metadata_root_quant_vt_pcoa12$Genotype,levels=c("A17","lyk3","nfp","ipd3","dmi2","dmi3","pt4", "Soil"))

####Figure S1
###对色盲友好的调色板
col_Genotype <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

windows(4,3)
p = ggplot(metadata_root_quant_vt_pcoa12, aes(Dim1, Dim2, color=Genotype, shape=MS)) +
  geom_point(cex=5) +
  scale_color_manual(values=col_Genotype)  +
  labs(x=paste("Unconstrained PCoA 1 (", format(100 * root_quant_vt_prop[1], digits=4), "%)", sep=""),
       y=paste("Unconstrained PCoA 2 (", format(100 * root_quant_vt_prop[2], digits=4), "%)", sep="")) +
  ggtitle(paste("PCoA for AM fungi community in root"))+
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



##################################################################
##################################################################

#############Rhizosphere_genotype
metadata_rhizosphere <- subset(metadata, Niche == "Rhizosphere")
metadata_rhizosphere$Genotype <- factor(metadata_rhizosphere$Genotype,levels=c("A17","lyk3","nfp","ipd3","dmi2","dmi3","pt4"))

rhizosphere_quant_vt <- quant_vt[row.names(quant_vt) %in% row.names(metadata_rhizosphere),]
rhizosphere_quant_vt_metadata <- merge.data.frame(metadata_rhizosphere[,1:5],rhizosphere_quant_vt[, colSums(rhizosphere_quant_vt) > 0], by="row.names")
names(rhizosphere_quant_vt_metadata)

rhizosphere_quant_vt_metadata$AMF <- rowSums(rhizosphere_quant_vt_metadata[,7:22])
###########根内只检测到了13个VT

windows(6,4) 
ggplot(rhizosphere_quant_vt_metadata, aes(Genotype,AMF)) +
  geom_boxplot(aes(colour=Genotype),size=1) +
  geom_jitter(aes(colour=Genotype), size=3, position = position_dodge(width=0.75)) +
  xlab("") + ylab("Quantified AMF 18S abundance (g-1)") + theme_bw() +
  scale_color_manual(values=col_Genotype)  +
  theme(legend.position="right") + 
  theme(legend.title = element_text(size=12,color="black", face = "bold"),
        legend.text= element_text(size=12,color="black"),
        axis.text= element_text(size=12,color="black"),
        axis.title= element_text(size=14,color="black", face= "bold"))


a <- kruskal(rhizosphere_quant_vt_metadata$AMF, rhizosphere_quant_vt_metadata$Genotype, group=TRUE, p.adj="fdr")

####根际土中VT没有趋势
#



