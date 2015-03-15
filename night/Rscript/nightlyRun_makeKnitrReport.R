#!/usr/bin/Rscript --vanilla
# this script creates a easy readable html file containing stock symbols buy/sell recommendation
# for each analyzed version
# input: matches list from /home/voellenk/tronador/dailyreport/Nuggets-YYYY-MM-DD.Rdata
# output: html file in Dropbox/constellation/dailyReport/Nuggets-YYYY-MM-DD.html

runtime <- Sys.time()

# load required packages
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(knitr))

# global parameters follow
inputDir <- "/home/voellenk/tronador/dailyReport"
outputDir <- "/home/voellenk/Dropbox/constellation/dailyReport"
knitrfileDir <- "/home/voellenk/tronador_workdir/tronador/knitrfiles"

option_list <- list(
  make_option(c("-v", "--verbose"), action="store_true", default=FALSE,
              help="Print extra output [default]")
)

opt <- parse_args(OptionParser(option_list=option_list))
args <- commandArgs(trailingOnly=TRUE)

setwd(knitrfileDir)

# load matches list from current nugget file
load(paste0(inputDir, "/Nuggets-", format(runtime, format="%Y-%m-%d"), ".Rdata"))

versions <- names(matches)

# create sorted table of best signals for each version
tbllist <- list()
for(i in 1:length(matches)) {
  this.version <- names(matches)[i]
  if (nrow(matches[[this.version]]) > 0) {
    this.match <- matches[[this.version]]
    this.match$sym <- as.character(this.match$sym) # transform factor to character
    this.match$ID <- as.character(this.match$ID)   # transform factor to character
    dun <- unique(this.match[,c("sym", "date", "Close", "ATR20", "signal", "ID")])
    dun <- cbind(dun, n3=NA, n5=NA, n10=NA, n20=NA)
    for (n in c(3,5,10,20)) {
      for(r in 1:nrow(dun)) {
        line <- this.match[this.match$sym == dun[r,"sym"] &
                           this.match$date == dun[r,"date"] &
                           this.match$signal == dun[r,"signal"] &
                           this.match$ID == dun[r,"ID"] &
                           this.match$period == n ,]
        if (nrow(line) == 1) {
          dun[r,c(paste0("n", n))] <- line[1,"mean.BS"] - line[1,"mean.SS"]
          #dun <- dun[with(dun, order(-n10, sym, date)), ] # order findings
        } else if (nrow(line) > 1) {
          stop ("Error: Filter condition lead to more than one line. This must not happen.")
        }
      }
    }
    tbllist[[this.version]] <- dun
  } else { # no obs found for this version
    tbllist[[this.version]] <- data.frame()
  }
}

if (opt$verbose == TRUE) {
  print ("The tbllist is:")
  tbllist  
}

clean.tbllist <- list()

# tbllist still may contain multiple IDs for distinct symbols. needs to get filtered out.
filtered.tbllist <- list()
for (i in 1:length(names(tbllist))) {
  dun <- tbllist[[names(tbllist)[i]]]
  if (nrow(dun) > 0) { # omitting versions with no observations
    filtered.tbllist[[names(tbllist)[i]]] <- 
      do.call(rbind,lapply(split(dun, dun$sym), function(chunk) chunk[which.max(chunk$n10),]))    
  }
}
  
if (opt$verbose == TRUE) {
  print ("The filtered.tbllist is:")
  filtered.tbllist    
}

if (length(filtered.tbllist) > 0) {
  # round numeric columns to 2 decimals  
  omit <- c("sym", "date", "signal", "ID")
  for (i in 1:length(names(filtered.tbllist))) {
    dun <- filtered.tbllist[[names(filtered.tbllist)[i]]]
    leave <- match(omit, names(dun))
    out <- dun
    out[-leave] <- round(dun[-leave], digits=3)
    out <- out[with(out, order(-n10, sym, date)), ] # order findings
    clean.tbllist[[names(filtered.tbllist)[i]]] <- out
  }
  if (opt$verbose == TRUE) {
    print ("The clean.tbllist is:")
    clean.tbllist  
  }
} else {
  print ("found no nuggets for today!")
}

knit2html("dailyReport.Rmd", output="temp.html")

# move finished html (filename=file to Dropbox folder
file.copy("temp.html", paste0(outputDir, "/Nuggets-", format(runtime, format="%Y-%m-%d"), ".html"), overwrite=TRUE)
file.remove("temp.html")

