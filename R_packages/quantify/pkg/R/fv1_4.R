# this function implements filter rules for the strategy "v1_3"
# it is used by quantify_scripts.R and nightlyRun.R

fv1_4 <- function(TS) {
  # define global parameters
  ADX.n <- 14
  ADX.threshold <- c(16,28)
  ADX.maType <- "EMA"
  CPos.n <- 200
  CPos.numberofsectors <- 3
  DSMA.n <- 20
  DSMA.rollingwindow <- 200
  
  TS <- TS[,1:4]  # only include OHLC columns. we are starting with 4 columns
  ### we add an ADX status
  TS <- cbind(TS, qADXStatus(TS[,1:4], n=ADX.n, threshold=ADX.threshold, maType=ADX.maType))
  ### we also add the channelPosition
  TS <- cbind(TS, qChannelPosition(TS[,1:4], n=CPos.n, numberofsectors=CPos.numberofsectors))
  ### we also add the derivative of SMA
  TS <- cbind(TS, qDSMAStatus(TS[,1:4], n=DSMA.n, rollingwindow=DSMA.rollingwindow))
  
  return(TS)
}