#install.packages('heatmaply',dependencies = TRUE)
library(heatmaply)
library(RColorBrewer)
library(readxl)
library(dplyr)

cluster_data_import <- read.csv("C:\\Users\\smajda\\Documents\\Projekt_sonstiges\\results\\complexes_over_time\\0_splicing_summary.csv",sep=",")
rownames(cluster_data_import) <- cluster_data_import$splice_process
# rename columns
cluster_data_import <-cluster_data_import %>% select(2:7) %>% rename("1" = 1, "2.5" = 2,"5" =3,"15"= 4,"30"= 5,"60"= 6)
# scale                                                    
maxs <- apply(cluster_data_import, 1, max) 
mins <- apply(cluster_data_import, 1, min) 
abundance <-t(scale(t(cluster_data_import), center=(maxs+mins)/2, scale=(maxs-mins)/2)) # transpose for row wise scaling);center=(maxs+mins)/2

# remove infinite values (no standard deviation, all values in one row are the same)
abundance[which(!is.finite(abundance))] <-  NaN

# with heatmaply
heatmaply(cluster_data_import,
          #seriate = "none",
          heatmap_layers = theme(axis.text.x=element_text(colour="black"),axis.text.y=element_text(colour="black")),
          fontsize_row = 11,
          fontsize_col = 16,
          column_text_angle = 0,
          row_text_angle = 0,
          #Rowv = NA,
          Colv = NA,
          xlab = "time(min)",
          #ylab = "Gene",
          colors = rev(colorRampPalette(brewer.pal(9, "Blues"))(40)), # reverse color order
)


