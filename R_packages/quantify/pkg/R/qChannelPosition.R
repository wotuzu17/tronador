# function calcualtes position of close price in the channel of
# the previous n periods
qChannelPosition <- function (TS, n, numberofsectors=3) {
  DC <- DonchianChannel(cbind(Hi(TS), Lo(TS)), n=n)
  posInDC <- (Cl(TS)-DC[,"low"])/(DC[,"high"]-DC[,"low"])
  retvar <- cbind(posInDC, cut(posInDC, numberofsectors, labels=FALSE))
  colnames(retvar) <- c("posInDC", "ChPos")
  return(retvar[,2])
}