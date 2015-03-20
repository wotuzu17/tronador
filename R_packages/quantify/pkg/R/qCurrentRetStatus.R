qCurrentRetStatus <- function(TS, ROCn=1, runXn=200, steps=c(.1,.25,.75,.9)) {
  retvar <- cbind(Cl(TS), findInterval(qCurrentRetPercentile(TS, ROCn=ROCn, runXn=runXn)[,"quantile"], steps))
  colnames (retvar) <- c("Close", paste0("RetS", ROCn))
  return(retvar[,2])
}