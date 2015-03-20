# function calculates quantile status of close to SMA ratio over
# a rollingwindow
# currently, only 3 levels are supported.
qC2SMAStatus <- function (TS, n, rollingwindow) {
  SMA <- SMA(Cl(TS), n=n)
  C_SMA <- (Cl(TS) -SMA[,1]) / Cl(TS)
  C_SMA_Q <- cbind(
    rollapply(C_SMA, rollingwindow, quantile, probs=.25, na.rm=TRUE),
    rollapply(C_SMA, rollingwindow, quantile, probs=.75, na.rm=TRUE)
  )
  C_SMA_S <- rollapply(C_SMA, 1, function(x) {
    as.numeric(x > C_SMA_Q[,1]) + 
    as.numeric(x > C_SMA_Q[,2])})
  colnames(C_SMA_S) <- c(paste0("C2SMA", n))
  return(C_SMA_S)
}