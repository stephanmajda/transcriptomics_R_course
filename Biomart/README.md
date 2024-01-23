## Biomart 

With this script we want to automatically connect further information to a gene list.
```
library(biomaRt)
library(tidyverse)
```
We use useMart with the ensemble data base and the mouse data set. To see what information we can get there use:
```
listAttributes(ensembl)
```
we load our previous result:
```
data_import <- read.csv(paste(c(folder,"_DESeq2_analysis_genes_only.csv"), sep = "",collapse=""),sep=",",header = TRUE)
data_import[,1] <- sub('\\.[0-9]*$', '',data_import[,1])
```
The sub command replaces the version from the id, which can make problems if we further work with ids without versions.
```
filtered_data <- data_import %>% filter(padj <= 0.05, na.rm = TRUE)
```
If you use to many attributes it could take a long time or break the process. We filter the data and look only at the interessting genes.
Finally, we save again our result:
```
write.csv(data_merged,"_annotation.csv", row.names = FALSE)
```
