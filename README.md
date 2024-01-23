---
title: "Analysis_transcriptomics"
author: "Stephan Majda"
date: "`r Sys.Date()`"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## R 

First of all, you don't have to programme everything yourself. There are already a number of packages with functions that are useful for our work.

```{r cars}
library(tximport)
library(GenomicFeatures)
library(DESeq2)
```

## Pipline

The term pipline is used when several tools or scripts are executed in sequential order. The advantage is that you do not have to manually forward the intermediate results for the next step between the programme steps.
Here we use a pipline based on http://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html and 
```
Love MI, Soneson C and Patro R. Swimming downstream: statistical analysis of differential transcript usage following Salmon quantification [version 3; peer review: 3 approved]. F1000Research 2018, 7:952 (https://doi.org/10.12688/f1000research.15398.3)
```
This workflow has the following steps:

```{r pressure, echo=FALSE}
quantification with kallisto (already done)
filtering
normalisation
comparison with p-value calculation
calculation false discovery rate
annotation
```

## quantification, normalisation and annotation
In the first step the abundance of each transcript or gene is counted. This is done by mapping the reads to the genome (or transcriptome).
The result is a list of relative gene frequencies. 
These lists must be loaded into the computer programme. As we have several files and do not want to set the path each time, we save it in a variable.(Alternative: setwd())
```
sample_path = "C:\\Users\\YOUR_USER_NAME\\Downloads\\PROJEKT_123\\data\\"
```
At the same time, we want to add meta-information to our gene list, which allows us to link cryptic ensemble ids to trivial gene names. Link to gtf file: https://ftp.ensembl.org/pub/release-111/gtf/mus_musculus/
```
gtf <- (paste(c(sample_path, Mus_musculus.GRCm39.110.chr.gtf.gz), sep = "",collapse="")
```
The paste function joins the path with the file. Then we load the file as an object. This object can be transformed to a data base.
```
txdb3 <- makeTxDbFromGFF(gtf,
                         format="gtf",
                         dataSource="Ensembl",
                         organism="Mus musculus",
                         taxonomyId=NA,
                         circ_seqs=NULL)
```
Now we combine ids with gene names:
```
txdf <- select(txdb3, keys(txdb3, "GENEID"), "TXNAME", "GENEID")
tab <- table(txdf$GENEID) # count number of transcripts
txdf$ntx <- tab[match(txdf$GENEID, names(tab))] # add number of transcripts
txdf2 <- as.data.frame(txdf)
```
The programme needs to know how our experimental setup looks like. Therefore, we load a file with two columns: sample name and condition.
```
samps <- read.csv(paste(c(sample_path, "samples.csv"), sep = "",collapse=""),sep=",",header = TRUE)
samps$condition <- factor(samps$condition)
head(samps) 
```
Now we can combine our annotation data with our quantification files.
```
# load abundance files
files <- file.path(sample_path,samps$sample_id, "abundance.tsv", fsep="\\")
names(files) <- samps$sample_id
head(files)   
txi <- tximport(files, type="kallisto", txOut=FALSE,tx2gene=txdf[,2:1],ignoreTxVersion=TRUE,
                countsFromAbundance="scaledTPM")
```
In the variable "countsFromAbundance" we can specify which normalisation we want to use. 
 
## filtering and statistics
The next step is the creation of a DESeq2 object. DESeq2 is a tool for finding differential gene expression.
```
dds <- DESeqDataSetFromTximport(txi,
                                   colData = samps,
                                   design = ~condition)
```
The design formula represents the variable of interest e.g. treated vs no treatment.
If you look at the list you will find genes with only 1-2 counts, these are probably random hits. In any case, the values are so low that it is difficult to make a meaningful statement about them.
```
# minimal filter
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]
```
For each gene should be 10 hits in our example.
```
dds$condition <- relevel(dds$condition, ref = "ND") # which level represents the control group e.g. WT

# Differential expression analysis
dds <- DESeq(dds)
res <- results(dds)
resOrdered <- res[order(res$pvalue),]
summary(res)
sum(res$padj < 0.05, na.rm=TRUE)
```
The DESeq function does all the calculations for us. We only sort the results and filter with the significant threshold of 0.05.
Finally, we can output our results to a csv file:
```
write.csv(df,paste(c(sample_path,res,"_DESeq2_analysis_genes_only.csv"), sep = "",collapse=""), row.names = FALSE)
```
