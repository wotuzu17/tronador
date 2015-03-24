#!/usr/bin/Rscript --vanilla
# This script downloads price data information and calculates current pattern classification for each
# symbol. Matches with promising patterns are stored and included in the daily report.
# a list of symbols that could not be retrieved are stored in a logfile

start.time <- Sys.time()
print (paste("script started:", start.time))

# global parameters follow
targetSymsFile <- "/home/voellenk/tronador_workdir/tronador/targetSyms/targetSyms.Rdata"
dailyQuoteDir <- "/home/voellenk/tronador/dailyQuotes"
plotDir <- "/home/voellenk/tronador/plots"
logDir <- "/home/voellenk/.tronadorlog"
historyYears <- 3
retryLimit <- 2

# load required packages
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(quantmod))
suppressPackageStartupMessages(library(quantify))
options("getSymbols.warning4.0"=FALSE)

option_list <- list(
  make_option(c("--testSampleN"), type="integer", default=0,
              help="number of random symbols to process (0 means process all symbols) [default %default]",
              metavar="number"),
  make_option(c("--seed"), type="integer", default=123,
              help="seed for random number generation [default %default]",
              metavar="number"),
  make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
             help="Print extra output [default]"),
  make_option(c("-p", "--plot"), action="store_true", default=FALSE,
              help="Print extra output [default]")
)

opt <- parse_args(OptionParser(option_list=option_list))
args <- commandArgs(trailingOnly=TRUE)

# create daily quotes file if not exists. Retrieved Quotes are stored there.
if (!file.exists(dailyQuoteDir)) {
  print (paste("creating directory", dailyQuoteDir))
  dir.create(dailyQuoteDir, recursive=TRUE)
}

# create log dir if not exists. Retrieved Quotes are stored there.
if (!file.exists(logDir)) {
  print (paste("creating directory", logDir))
  dir.create(logDir, recursive=TRUE)
}

# create plots dir if argument -p and dir doesn't exist
if (opt$plot == TRUE && !file.exists(plotDir)) {
  print (paste0("creating directory ", plotDir, ". Time Series plots of downloaded symbols get stored there."))
  dir.create(plotDir)
}

# read data frame "syms" for the list of symbols
set.seed(opt$seed)
load(targetSymsFile)

# determine symbols to download from yahoo
if (opt$testSampleN == 0) {
  symsToDownload <- syms$Symbol
  print (paste("Download all", length(syms$Symbol), "symbols."))
} else {
  symsToDownload <- sample(syms$Symbol, opt$testSampleN)
  print ("Download symbols:")
  print (symsToDownload)
}

# determine start date, according to setting historyYears
startYear <- as.numeric(format(Sys.Date(), "%Y")) - historyYears
startDate <- paste0(startYear,"-01-01")

# add market index symbol ^GSPC (Standard & Poors 500) to symsToDownload
symsToDownload <- c("^GSPC", symsToDownload)

# download and adjust price data from yahoo
TSDATA <- new.env()
symsDF <- data.frame(symsToDownload, 0, 0, stringsAsFactors = FALSE)
colnames(symsDF) <- c("sym", "count", "success")
finish <- FALSE
while (!finish) {
  remainingDF <- symsDF[symsDF$success==0 & symsDF$count<retryLimit,]
  remainingDF <- remainingDF[with(remainingDF, order(count, sym)), ]
  if (is.data.frame(remainingDF) & nrow(remainingDF) > 0) {
    this.sym <- remainingDF[1,"sym"]
    if (opt$verbose == TRUE) {
      print (paste("...retrieving", this.sym))
    }
    try(TS <- getSymbols(this.sym, from=startDate, auto.assign=FALSE, adjust=TRUE), silent=TRUE)
    # if retrieved time series is sane, keep on processing
    if (qCheckTSforValidity(TS, 240*historyYears)) {
      # store xts object in TS environment and mark download as success
      assign(this.sym, TS, envir=TSDATA)
      symsDF[symsDF$sym==this.sym, "success"] <- 1
      # print (paste("successfully downloaded ", this.sym))
      # store chart as png
      if (opt$plot==TRUE) {
        png(filename=paste0(plotDir, "/", this.sym, ".png"))
        plot(Cl(TS), main=this.sym, type="p", pch=20)
        dev.off()          
      }      
    } else {
      # download went wrong
      symsDF[symsDF$sym==this.sym, "count"] <- symsDF[symsDF$sym==this.sym, "count"] + 1
      print (paste("PROBLEM downloading symbol: ", this.sym))      
    }
  } else {
    finish <- TRUE
  }
}

# report symbols that could not be downloaded
if (nrow(symsDF[symsDF$success==0,]) > 0) {
  print ("list of not retrieved symbols")
  symsDF[symsDF$success==0,]
  # append troublesome symbol names to logfile
  cat(c(paste("troublesome symbols for", start.time), symsDF[symsDF$success==0, "sym"]), 
      file=paste(logDir, "troublesomeSymbols.log", sep="/"), 
      sep="\n", 
      append=TRUE)
} else {
  print ("all symbols downloaded successfully")
  if (nrow(symsDF[symsDF$count>0,]) > 0) {
    print("Symbols with more than one download attempt:")
    symsDF[symsDF$count>0,]
  }
}



# save collected symbols in environment TSDATA to file 
filename <- paste(dailyQuoteDir, paste0("Quotes-", format(Sys.Date(), "%Y-%m-%d"), ".Rdata"), sep="/")
print (paste0("saving quotes in environment TSDATA to ", filename))
save(TSDATA, file=filename)

end.time <- Sys.time()
print (paste("script ended:", end.time))
print ("execution time:") 
end.time - start.time
