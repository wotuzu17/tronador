# function calculates quantile status of first derivative of SMA of
# a rollingwindow
# currently, only 3 levels are supported.
qDSMAStatus <- function (TS, n, rollingwindow) {
  SMA <- SMA(Cl(TS), n=n)
  FD_SMA <- diff(SMA)
  FD_SMA_Q <- cbind(
    rollapply(FD_SMA, rollingwindow, quantile, probs=.25, na.rm=TRUE),
    rollapply(FD_SMA, rollingwindow, quantile, probs=.75, na.rm=TRUE)
  )
  FD_SMA_S <- rollapply(FD_SMA, 1, function(x) {
    as.numeric(x > FD_SMA_Q[,1]) + 
    as.numeric(x > FD_SMA_Q[,2])})
  colnames(FD_SMA_S) <- c(paste0("FSMA", n))
  return(FD_SMA_S)
}