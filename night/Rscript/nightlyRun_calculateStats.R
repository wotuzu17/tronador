#!/usr/bin/Rscript --vanilla
# This script applies the filter rules to all previously downloaded stock symbols (nigthlyRun_getQuotes.R)
# it creates data.frames with last day status of all symbols for each strategy and stores it into
# /home/voellenk/dailyReport

start.time <- Sys.time()
print (paste("script started:", start.time))

# global parameters follow
dailyQuoteDir <- "/home/voellenk/tronador/dailyQuotes"
outputBaseDir <- "/home/voellenk/tronador/dailyReport"
availableStrategies <- c("v1_2", "v1_3", "v1_4", "v2_1", "v2_2")

# load required packages
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(quantmod))
suppressPackageStartupMessages(library(cssupport))
suppressPackageStartupMessages(library(quantify))

option_list <- list(
  make_option(c("--version"), default="all",
              help="pattern filtering version according to fx_y function in quantify [default %default]"),
  make_option(c("-v", "--verbose"), action="store_true", default=FALSE,
              help="Print extra output [default]")
)

opt <- parse_args(OptionParser(option_list=option_list))
args <- commandArgs(trailingOnly=TRUE)

# determine which version fx_y to process (or all available ones)
if (opt$version=="all") {
  strategyToProcess <- availableStrategies
} else {
  strategyToProcess <- opt$version
}

# create general output directory if not exists. Reports are stored there
if (!file.exists(outputBaseDir)) {
  dir.create(outputBaseDir)  
}

# load current file or, if not found, most recent file
currentFilename <- paste0("Quotes-", format(Sys.Date(), "%Y-%m-%d"),".Rdata")
if (currentFilename %in% list.files(dailyQuoteDir)) {
  load(paste(dailyQuoteDir, currentFilename, sep="/"))
  symbols <- ls(envir=TSDATA)
} else {
  files <- sort(list.files(dailyQuoteDir, pattern="^Quotes-.*.Rdata$"), decreasing=TRUE)
  if (length(files) > 0) {
    print("Warning: No current file of the day found. Taking the most recent one instead")
    print(paste("taking data from", files[1]))
    load(paste(dailyQuoteDir, files[1], sep="/"))
    symbols <- ls(envir=TSDATA)
  } else {
    stop(paste("The directory", dailyQuoteDir, "does not contain any quotes files"))
  }
}

# there is a problem with symbol LOW, remove it
symbols <- symbols[symbols!="LOW"]

# copy symbol GSPC into global environment
assign("GSPC", get("^GSPC", envir=TSDATA))

# calculate pattern of last day for all symbols
plist <- list()
for (strategy in strategyToProcess) {
  plist[[strategy]] <- data.frame()
  for (sym in symbols) {
    if (opt$verbose==TRUE) {
      print (paste("...calculating", strategy, "for", sym))
    }
    this.TS <- do.call(paste0("f", strategy), list(get(sym, envir=TSDATA))) # apply calculation function from quantify package
    this.TS <- cbind(qATR(get(sym, envir=TSDATA)), this.TS)
    lastLine <- last(this.TS)[, c(1, 6:ncol(this.TS))]
    date <- index(lastLine)
    Close <- as.vector(last(Cl(this.TS)))
    line <- cbind(sym, date, Close, as.data.frame(lastLine))
    rownames(line) <- 1
    plist[[strategy]] <- rbind(plist[[strategy]], line)
  }
}

# now store plist in the daily report dir
filename <- paste(outputBaseDir, paste0(format(Sys.Date(), "%Y-%m-%d"), "-LDC-", opt$version ,".Rdata"), sep="/")
print (paste0("saving list of data.frames with constellation for each strategy into", filename))
save(plist, file=filename)

end.time <- Sys.time()
print (paste("script ended:", end.time))
print ("execution time:") 
end.time - start.time

