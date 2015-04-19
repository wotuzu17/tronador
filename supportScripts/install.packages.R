#!/usr/bin/Rscript --vanilla
# automatically install required packages for tronador

options(repos=structure(c(CRAN="http://cran.rstudio.com/")))

install.packages("xts")
install.packages("quantmod")
install.packages("knitr")
install.packages("optparse")
install.packages("plyr")
install.packages("ggplot2")
install.packages("reshape2")
