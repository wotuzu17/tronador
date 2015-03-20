# strategy compares performance of time series with market index
fv2_2 <- function(TS, MI=NULL) {
  if (is.null(MI)) {
    if (is.xts(GSPC)) {
      MI <- GSPC # assume that S&P500 is located in global environment     
    } else {
      stop("ERROR: No market index is provided.")
    }
  }
  # define global parameter
  TS.ROCn <- c(1,5,20,50)
  MI.ROCn <- c(3,20)
  
  TS <- TS[,1:4] # only include OHLC columns
  for (i in 1:length(TS.ROCn)) {
    TS <- cbind(TS, qCurrentRetStatus(TS, TS.ROCn[i]))
  }
  for (i in 1:length(MI.ROCn)) {
    TS <- cbind(TS, qCurrentRetStatus(MI, MI.ROCn[i]))
    colnames(TS)[ncol(TS)] <- sub("\\.1$", "", paste("MI", colnames(TS)[ncol(TS)], sep="."))
  }
  return(TS)
}

