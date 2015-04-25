#!/usr/bin/Rscript
# this script creates knitr reports "bestPatterns" on combination files for given strategy
# input: combination files (either combined or 25 separate group files)


suppressPackageStartupMessages(library(knitr))
suppressPackageStartupMessages(library(optparse))

input.dir <- "/home/voellenk/_Dropbox/constellation" # also used in knitrfile
output.dir <- "/home/voellenk/Dropbox/constellation/report"
knitfile <- "/home/voellenk/tronador_workdir/tronador/knitrfiles/bestPatterns.Rmd"

option_list <- list(
  make_option(c("--version"), default="vx_y",
              help="pattern filtering version according to fXY function in quantify [default %default]")
)

opt <- parse_args(OptionParser(option_list=option_list))
args <- commandArgs(trailingOnly=TRUE)

all.files <- list.files(input.dir, rec=F)
# filter combination files for given version
comb_files <- all.files[grep(paste0('^', opt$version, '.*_C.Rdata$'), all.files)]

# determine distinct seeds
distinct.seeds <- sort(as.numeric(unique(sub("_.*", "", sub("^v.*_seed=", "", comb_files)))))
# determine distinct periods
distinct.periods <- sort(as.numeric(unique(sub("_.*", "", sub("^v.*_future_periods=", "", comb_files)))))

for (seed in distinct.seeds) {
  for (period  in distinct.periods) {
    print(paste("... doing seed", seed, "| period", period))
    # filenames will contain either 1 or 25 filenames, depending whether groups are stored seperately or not
    filenames <- comb_files[grepl(paste0("^", opt$version, "_.*seed=", seed, "_.*future_periods=", period), comb_files)]
    # define output filename
    output.filename <- paste0(opt$version,"_seed=", seed, "_period=", period, ".Rdata")
    # now run knitr
    knit2html(knitfile, paste(output.dir, output.filename, sep="/"))
  }
}

