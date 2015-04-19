#!/usr/bin/Rscript
# this script creates knitr reports "bestPatterns" on combination files for given strategy

suppressPackageStartupMessages(library(knitr))
suppressPackageStartupMessages(library(optparse))

path <- "/home/voellenk/_Dropbox/constellation"
outp <- "/home/voellenk/Dropbox/constellation/report"
knitfile <- "/home/voellenk/stratlab_workdir/stratlab/pattern_report/bestPatterns.Rmd"

option_list <- list(
  make_option(c("--version"), default="vx_y",
              help="pattern filtering version according to fXY function in quantify [default %default]")
)

opt <- parse_args(OptionParser(option_list=option_list))
args <- commandArgs(trailingOnly=TRUE)

all.files <- list.files(path, rec=F)
comb_files <- all.files[grep('^v2_2.*_C.Rdata$', all.files)]

for (i in 1:length(comb_files)) {
  filename <- comb_files[i]
  print (paste("... doing", filename))
  knit2html(knitfile, paste(outp, filename, sep="/"))
}
