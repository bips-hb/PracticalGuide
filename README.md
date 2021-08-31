# A practical guide to causal discovery with cohort data

In this guide, we present how to perform constraint-based causal discovery using three popular software packages: `pcalg` (with add-ons `tpc` and `micd`), `bnlearn`, and TETRAD. We focus on how these packages can be used with observational data and in the presence of mixed data (i.e., data where some variables are continuous, while others are categorical), a known time ordering between variables, and missing data.

## How to ...
### ... download and read the guide
The pdf can be downloaded from arXiv: www.arxiv.org/abs/2108.13395.

### ... download the code
The file `RCode.R` contains all the code required to reproduce the analyses performed in the guide.

### ... download the source files
The guide was created using R Markdown. You can reproduce the pdf by following these steps:
1) Download all files in this repository into a single folder.
2) Make sure that the R packages rmarkdown, pcalg, bnlearn, mice, tpc and micd are installed. Note that in order to install tpc and micd, you need to have Rtools40 installed on your computer.
```R
install.packages("rmarkdown")
install.packages("pcalg")
install.packages("bnlearn")
install.packages("mice")
devtools::install_github("bips-hb/tpc")
devtools::install_github("bips-hb/micd")
```
3) Open Practical_guide_31Aug2021.Rmd in RStudio and click "Knit" near the top left corner of the window.
