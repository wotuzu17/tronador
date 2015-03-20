# this function returns a one-column xts object containing the
# average true range. It is used for presentation in the daily report

qATR <- function (TS, n=20) {
  retvar <- ATR(cbind(Hi(TS), Lo(TS), Cl(TS)), n=n)[,"atr"]
  colnames(retvar) <- paste0("ATR", n)
  return(retvar)
}