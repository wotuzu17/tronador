# this function is used by qCurrentRetStatus function
qCurrentRetPercentile <- function(TS, ROCn=1, runXn=200) {
  TS <- Cl(TS)
  cnames <- colnames(TS)
  TS <- cbind(TS, ROC(Cl(TS), n=ROCn))
  TS <- cbind(TS, runMean(TS[,2], n=runXn))
  TS <- cbind(TS, runSD(TS[,2], sample=TRUE, n=runXn))
  TS$quantile <- NA
  colnames(TS) <- c(cnames, "ret", "mean", "sd", "quantile")
  for (i in (runXn+1):nrow(TS)) {
    TS[i,"quantile"] <- pnorm(TS[i,"ret"], mean=TS[i,"mean"], sd=TS[i, "sd"])
  }
  return (TS)
}
