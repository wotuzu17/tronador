#!/usr/bin/Rscript --vanilla
# this script compares the daily last-day-constellations with nuggetShapes
# it filters out the symbols that are in a constellation that proved to be 
# promising in historical research
# input: /home/voellenk/tronador/dailyReport/YYYY-MM-DD-LDC-vx_y.Rdata
# input (nugget shapes files) : /home/voellenk/tronador_workdir/tronador/nuggetShapes/vx_y_nuggetShapes.Rdata
# output: /home/voellenk/tronador/dailyNuggets/Nuggets-YYYY-MM-DD.Rdata

start.time <- Sys.time()
print (paste("script started:", start.time))

# global parameters follow
baseDir <- "/home/voellenk/tronador/dailyReport"
nSDir <- "/home/voellenk/tronador_workdir/tronador/nuggetShapes"

# load required packages
suppressPackageStartupMessages(library(optparse))

option_list <- list(
  make_option(c("-v", "--verbose"), action="store_true", default=FALSE,
              help="Print extra output [default]")
)

opt <- parse_args(OptionParser(option_list=option_list))
args <- commandArgs(trailingOnly=TRUE)

# load current day LastDaysConstellation file
currentDayString <- format(Sys.Date(), "%Y-%m-%d")
currentLDCFiles <- sort(list.files(baseDir, pattern=paste0("^", currentDayString,"-LDC-.*.Rdata$")))
if (length(currentLDCFiles) > 0) {
  all.filename <- paste0(currentDayString, "-LDC-all.Rdata")
  if (all.filename %in% currentLDCFiles) { # load LDC file with the plist of all versions
    if (opt$verbose == TRUE) {
      print(paste0("found file with complete plist: ", all.filename, ". Loading plist from this file."))
    }
    load(paste(baseDir, all.filename, sep="/"))
  } else {
    pplist <- list()
    for (file in currentLDCFiles) {
      load(paste(baseDir, file, sep="/"))
      if ("plist" %in% ls() && length(names(plist))==1) {
        if (opt$verbose == TRUE) {
          print (paste("successfully loaded plist from", file))
        }
        pplist[[names(plist)]] <- plist[[1]]
        assign (paste("plist", sub("^.*-LDC-", "", sub(".Rdata", "",file)), sep="."), plist)
      } else {
        print(paste("Warning: There is no plist in", file))
      }
    }
    plist <- pplist
  }
} else {
  stop(paste0("ERROR: There are no LDC files in ", baseDir, ". Cannot proceed without data."))
}

# load nuggetShapes and find matches in plist
matches <- list()
nSFiles <- list.files(nSDir, pattern="_nuggetShapes.Rdata$")
for (i in 1:length(nSFiles)) {
  load(paste(nSDir, nSFiles[i], sep="/"))            # loads the data.frame nS from file
  this.strategy <- sub("_nuggetShapes.Rdata", "", nSFiles[i])
  matches[[this.strategy]] <- data.frame()
  # determine metricCols and nonMetricCols out of nS data.frame
  pattern <- "period|signal|ID|^mean.(BS|SS|N)|^sd.(BS|SS|N)"
  nS.metricCols <- colnames(nS)[grep(pattern, colnames(nS), invert=TRUE)]
  nS.nonMetricCols <- colnames(nS)[grep(pattern, colnames(nS))]
  # this is the subseted data.frame with only metric columns
  nS.mC.df <- nS[,nS.metricCols]
  # now loop through each line (each nuggetShape)
  for (j in 1:nrow(nS.mC.df)) {
    # first filter out non relevant columns (that contain NA)
    lineDescColumns <- nS[j,nS.nonMetricCols]
    line <- nS.mC.df[j,]
    fline <- line[,!colSums(is.na(line))>0]
    # merge data.frames to find occurences (the magical moment)
    match <- merge(cbind(lineDescColumns, fline), plist[[this.strategy]])
    if (nrow(match) > 0) {
      matches[[this.strategy]] <- rbind(matches[[this.strategy]], match[,c("sym", "date", "Close", "ATR20", nS.nonMetricCols)])
    }
  }
}

if (opt$verbose == TRUE) {
  print ("these are the matches:")
  matches
}

# now save matches into /home/voellenk/tronador/dailyReport/Nuggets-YYYY-MM-DD.Rdata
nuggetFile <- paste0(baseDir, "/Nuggets-", currentDayString, ".Rdata")
print(paste("saving matches into", nuggetFile))
save(matches, file=nuggetFile)

# also save the tables into tab separated files
# for (i in 1:length(matches)) {
#   if (nrow(matches[[i]]) > 0) {
#     filename <- paste0(baseDir, "/", currentDayString, "_", names(matches[i]), ".csv")
#     print(paste("saving csv ouput into", filename))
#     write.csv(matches[[i]], file=filename)
#   }
# }

end.time <- Sys.time()
print (paste("script ended:", end.time))
print ("execution time:") 
end.time - start.time
