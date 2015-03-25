# strategy compares performance of time series with market index
fv2_3 <- function(TS, MI=NULL) {
  if (is.null(MI)) {
    if (is.xts(GSPC)) {
      MI <- GSPC # assume that S&P500 is located in global environment     
    } else {
      stop("ERROR: No market index is provided.")
    }
  }
  # define global parameter
  TS.ROCn <- c(1,4,30)
  MI.ROCn <- c(1,4,30)
  steps <- c(.09, .2, .4, .6, .8, .91)
  CPos.n <- 200
  CPos.numberofsectors <- 4
  
  TS <- TS[,1:4] # only include OHLC columns
  for (i in 1:length(TS.ROCn)) {
    TS <- cbind(TS, qCurrentRetStatus(TS, ROCn=TS.ROCn[i], steps=steps))
  }
  ### add the channelPosition of stock
  TS <- cbind(TS, qChannelPosition(TS[,1:4], n=CPos.n, numberofsectors=CPos.numberofsectors))
  for (i in 1:length(MI.ROCn)) {
    TS <- cbind(TS, qCurrentRetStatus(MI, ROCn=MI.ROCn[i], steps=steps))
    colnames(TS)[ncol(TS)] <- sub("\\.1$", "", paste("MI", colnames(TS)[ncol(TS)], sep="."))
  }
  ### we also add channelPosition of market index
  TS <- cbind(TS, qChannelPosition(MI[,1:4], n=CPos.n, numberofsectors=CPos.numberofsectors))
  colnames(TS)[ncol(TS)] <- sub("\\.1$", "", paste("MI", colnames(TS)[ncol(TS)], sep="."))
  return(TS)
}
