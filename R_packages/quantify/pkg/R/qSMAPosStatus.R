# returns whether a Time Series is above or below a SMA line
qSMAPosStatus <- function (TS, n) {
  TS.SMA <- SMA(Cl(TS), n=n)
  retvar <- cbind(TS.SMA, Cl(TS) > TS.SMA[,1])
  colnames(retvar) <- c("SMA", paste0("CgtSMA", n))
  return(retvar[,2])
}