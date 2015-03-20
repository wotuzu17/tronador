#!/usr/bin/Rscript
# this script creates a list of quantified data.frames of all or one particular sd/median group.
# the script uses as raw data the cleanStockData RData file
# it outputs the calculated list of data.frame as RData file

suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(quantmod))
suppressPackageStartupMessages(library(cssupport))
suppressPackageStartupMessages(library(quantify))

# troublesome symbols to omit from analysis
omit.syms <- c("LOW", "DMRC")

# define paths
outputDir <- "/home/voellenk/_Dropbox/constellation"  # set output dir to non-Dropbox file to avoid capacity issues
cleanData <- "/home/voellenk/tronador_workdir/cleanData/cleanStockData_2000_2014_quantiles.RData"

if (!file.exists(outputDir)) {
  stop("outputDir does not exists. Create it first then run the script again.")
}

option_list <- list(
  make_option(c("--group"), default="all",
              help="id of group to process [default \"%default\"]\n
                    Example: --group=1_2 (sdG_medianG)"),
  make_option(c("--number"), type="integer", default=20,
              help="number of random symbols in one group to process [default %default]",
              metavar="number"),
  make_option(c("--seed"), type="integer", default=123,
              help="seed for random number generation [default %default]",
              metavar="number"),
  make_option(c("--future_periods"), type="integer", default=5,
              help="number of periods to calculate future performance [default %default]",
              metavar="number"),
  make_option(c("--method"), default="o1",
              help="price to take for position entry [default \"%default\"]"),
  make_option(c("--version"), default="v1_2",
              help="pattern filtering version according to fXY function in quantify [default %default]")
)

opt <- parse_args(OptionParser(option_list=option_list))
args <- commandArgs(trailingOnly=TRUE)
# the options are accessible in the script as
# opt$group
# for debug: 
# opt <- list("group"="1_2", "number"=4, "seed"=123, "future_periods"=5, "method"="o1")

# output list of arguments
print ("Startup arguments:")
print (paste("  group   : ", opt$group))
print (paste("  version : ", opt$version))
print (paste("  periods : ", opt$future_periods))
print (paste("  method  : ", opt$method))
print (paste("  seed    : ", opt$seed))
print (paste("  number  : ", opt$number))

# seed: special case for seed=1 to 4. set seed to one, take group of 20 (without repetitions)
if (opt$seed < 5) {
  if (opt$number == 20) {
    set.seed(1)    
  } else {
    stop("for seed <5 only number=20 is supported")
  }
} else {
  set.seed(opt$seed)
}

# determine version of pattern filtering
this.version <- opt$version

# define helper functions for this script
get2 <- function(var) {
  get(var, envir=TSDATA)
}

# load financial data 2000-2013 into own environment
TSDATA <- new.env()
load(cleanData, envir=TSDATA)
assign("syms", get("syms", envir=TSDATA)) # copy syms data.frame into global environment

# load standard&poors500 index into global environment. needet for fv2_x functions
assign("GSPC", get("GSPC", envir=TSDATA))

# create sample data.frame (random items of each group)
# sd.q median.q  x.1  x.2 x.3  x.4
# 1    2         ACGL DCI XRAY MHFI
if (opt$seed < 5) {
  sample <- aggregate(syms$Symbol, by=list(sd.q=syms$sd.q, median.q=syms$median.q), FUN=sample, size=80)
  sample[,3] <- sample[,3][,c((20*(opt$seed-1)+1):(opt$seed*20))]
} else {
  sample <- aggregate(syms$Symbol, by=list(sd.q=syms$sd.q, median.q=syms$median.q), FUN=sample, size=opt$number)   
}

if (opt$group != "all") {
  gID <- strsplit(opt$group, "_", fixed=TRUE)
  if (length(gID[[1]]) != 2) {
    stop("invalid group parameter given")
  } else {
    gID.sd <- as.numeric(gID[[1]][1])
    gID.median <- as.numeric(gID[[1]][2])
  }
  sample <- sample[sample$sd.q==gID.sd &sample$median.q==gID.median, ]
}

print("working with sample:")
sample

DF.list <- list()
# loop through every line of sample data.frame (every group)
for (i in 1:nrow(sample)) {
  this.group <- paste("G", sample[i,"sd.q"], sample[i,"median.q"], sep="_")
  DF.list[[this.group]] <- list()
  print(paste("... doing group", this.group))
  # loop through every symbol of a group
  for (j in 1:length(sample[i,3])) {
    this.sym <- sample[i,3][j]
    print(paste("... ... symbol:", this.sym))
    if (!this.sym %in% omit.syms) {
      # calculating quantifications of time series
      this.TS <- get2(this.sym)
      # automagically call the right fXY function
      this.TS <- do.call(paste0("f", this.version), list(this.TS))
      # adding performance columns
      this.TS <- cbind(this.TS, qFindOpportunity(this.TS[,1:4], n=opt$future_periods, method=opt$method))
      CC <- this.TS[complete.cases(this.TS),]
      if (nrow(CC) > 1000) {
        CCC <- CC[200:nrow(CC),c(5:ncol(CC))]   # omit first observations where quantile status is not swung in
        DF.list[[this.group]][[this.sym]] <- as.data.frame(CCC, row.names=NULL)      
      } else {
        print(paste0("... ... ... error with symbol ", this.sym, ". Less than 1000 complete cases."))
      }      
    } else {
      print("unable to process symbol name LOW")
    }
  }
}

# store collected data.frames in Rdata variable
optvec<-unlist(opt)
for(i in 1:length(optvec)) {
  optvec[i] <- paste(names(optvec[i]), optvec[i], sep="=")
}
filename <- sprintf("%s/%s.Rdata", outputDir, paste(this.version, paste(optvec, collapse="_"), sep="_"))

print(paste("saving file to", filename))
save(DF.list, file=filename)