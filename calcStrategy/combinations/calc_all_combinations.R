#!/usr/bin/Rscript --vanilla
# this script uses as input the list of data.frames as calculated by quantify_groups.R script.
# it calculates performance for each possible combination.
# as parameter you can give either the full path to the Rdata file, or provide seed, version, future periods
# to let the script filter for the right file in inputDir

suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(quantmod))
suppressPackageStartupMessages(library(cssupport))
suppressPackageStartupMessages(library(quantify))
suppressPackageStartupMessages(library(plyr))

inputDir <- "/home/voellenk/_Dropbox/constellation"

option_list <- list(
  make_option(c("--inputFile", default=""),
              help=".RData file to use as input"),
  make_option(c("--seed"), type="integer", default=0,
              help="seed for random number generation [default %default]",
              metavar="number"),
  make_option(c("--group"), type="integer", default=0,
              help="group to process from 1 to 25. 0 means all groups [default %default]",
              metavar="number"),
  make_option(c("--future_periods"), type="integer", default=5,
              help="number of periods to calculate future performance [default %default]",
              metavar="number"),
  make_option(c("--version"), default="",
              help="pattern filtering version according to fXY function in quantify [default %default]")
)

opt <- parse_args(OptionParser(option_list=option_list))
args <- commandArgs(trailingOnly=TRUE)

print (paste("start at", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))

# the options are accessible in the script as
# opt$group
# for debug: 
# opt <- list("inputFile"="/home/voellenk/Dropbox/constellation/v1_1_group=all_number=2_seed=123_future_periods=5_method=o1_help=FALSE.Rdata")
# opt <- list("inputFile"="/home/voellenk/Dropbox/constellation/v1_2_group=all_number=20_seed=123_future_periods=5_method=o1_help=FALSE.Rdata")

determineOutputFile <- function(path, inpFilename) {
  outFilename <- sub(".Rdata", paste0("_group=", opt$group, "_C.Rdata"), inpFilename, fixed=TRUE)
  outputFile <- paste(path, outFilename, sep="/")
  return(outputFile)
}

if (is.null(opt$inputFile)) {
  files <- list.files(inputDir)
  ix <- grep(paste0("^", opt$version, "_.*", "seed=", opt$seed, "_.*", 
                    "future_periods=", opt$future_periods, ".*FALSE.Rdata$"), files)
  if (length(ix) == 1) {
    outputFile <- determineOutputFile(inputDir, files[ix])
    print(paste ("loading", paste(inputDir, files[ix], sep="/")))
    load(paste(inputDir, files[ix], sep="/"))
  } else {
    stop(paste("inputFile", opt$inputFile, "does not exist. Quitting now."))    
  }
} else if (file.exists(opt$inputFile)) {
  splitPath <- unlist(strsplit(opt$inputFile, "/"))
  outputFile <- determineOutputFile(paste(splitPath[1:length(splitPath)-1], collapse="/"), splitPath[length(splitPath)] )
  load(opt$inputFile)
}

# helper function
allcomb<-function(x, addnone=T) {
  x<-do.call(c, lapply(length(v):1, function(n) combn(v,n,simplify=F)))
  if(addnone) x<-c(x,0)
  x
}

# determine number columns to aggregate over
# output it as information for a estimation of the processing time
# subtract the 6 columns from the qfindOpportunity
nkeycols <- ncol(DF.list[[1]][[1]])-6
print (paste("aggregating over", nkeycols, "columns"))
print (paste("start at", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))


groups <- names(DF.list)
if (opt$group>0) {
  groups <- groups[opt$group]
}
COMB.list <- list()
# loop through every list items (groups) when opt$group=0, otherwise take group opt$group
for (i in 1:length(groups)) {
  this.group <- groups[i]
  print(paste("... doing group", this.group))
  this.DF <- do.call("rbind", DF.list[[this.group]])
  
  v <- names(this.DF)[1:nkeycols]
  vv <- allcomb(v)
  
  # aggregate over buyS and sellS
  dd <- lapply(vv, function(cols)
    aggregate(cbind(this.DF$buyS, this.DF$sellS), 
              this.DF[, cols, drop=F], 
              FUN=function(S) c(med=median(S), n=length(S))))
  dd <- do.call(rbind.fill, dd)
  
  # alter colnames from V1 to buyS
  colnames(dd)[ncol(dd)-1] <- "buyS"
  colnames(dd)[ncol(dd)] <- "sellS"  
  
  COMB.list[[this.group]] <- dd
  #head(dd[with(dd, order(-V1[,"med"])),], 30)
}

# store calculated combinations 
print (paste("saving to", outputFile))
save(COMB.list, file=outputFile)

print (paste("end at", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))