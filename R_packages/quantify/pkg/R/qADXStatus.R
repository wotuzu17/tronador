# function returns ADX Status
# state 0: ADX 0-15, 1: ADX 15-25, 2: ADX > 25
qADXStatus <- function (TS, n=14, threshold=c(15,25), maType="EMA"){
  ADX <- ADX(cbind(Hi(TS), Lo(TS), Cl(TS)), n=n, maType=maType)
  LAGADX <- LagMultiColumnXTS(ADX)
  ADX_S <- rollapply(ADX[,"ADX"], 1, function(x) {
      as.numeric(x > threshold[1]) + 
      as.numeric(x > threshold[2])})
  ADXDirection <- ADX[,"ADX"] > LAGADX[,"ADX"]
  colnames(ADXDirection) <- c("ADXdir")
  DI_S <- ADX[, "DIp"] > ADX[, "DIn"]
  colnames(DI_S) <- c("DI_S")
  ADXTrendCross <- cbind(!Lag(DI_S[,1]) & DI_S[,1],
                         Lag(DI_S[,1]) & !DI_S[,1])
  colnames(ADXTrendCross) <- c("DIpcu", "DIpcd")
  ADXDirChange <- cbind(!Lag(ADXDirection[,1]) & ADXDirection[,1], 
                        Lag(ADXDirection[,1]) & !ADXDirection[,1])
  colnames(ADXDirChange) <- c("ADXrise", "ADXfall")
  
  # bind all columns together 
  result <- cbind(ADX_S, ADXDirection, DI_S, ADXTrendCross, ADXDirChange)
  return(result)
}