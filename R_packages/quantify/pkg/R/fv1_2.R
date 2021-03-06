# this function implements filter rules for the strategy "v1_2"
# it is used by quantify_scripts.R and nightlyRun.R

fv1_2 <- function(TS) {
  # define global parameters
  ADX.n <- 14
  ADX.threshold <- c(15,25)
  ADX.maType <- "EMA"
  CPos.n <- 100
  CPos.numberofsectors <- 3
  DSMA.n <- 100
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