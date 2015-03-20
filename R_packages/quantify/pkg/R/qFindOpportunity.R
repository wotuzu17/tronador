# calculates return of time series by taking the close/open price of the curren/following period
qFindOpportunity <- function(TS, n=5, method="c0") {
  if (!is.OHLC(TS)) {
    stop("Price series must contain Open, High, Low and Close.")
  }
  if (method == "c0") {  # include current high/low in max/min calculation
    max <- lag(runMax(Hi(TS),n=n), k=(n*(-1)+1))
    min <- lag(runMin(Lo(TS),n=n), k=(n*(-1)+1))
    gain <- (max/Cl(TS)-1)*100
    loss <- (min/Cl(TS)-1)*100
    ret <- lag(diff(log(Cl(TS)), n), k=n*(-1))
  } else if (method == "o1") {
    max <- lag(runMax(Hi(TS),n=n), k=(n*(-1)))
    min <- lag(runMin(Lo(TS),n=n), k=(n*(-1)))
    gain <- (max/as.xts(Next(Op(TS)))-1)*100
    loss <- (min/as.xts(Next(Op(TS)))-1)*100    
    ret <- 1
  } else if (method == "c1") {
    max <- lag(runMax(Hi(TS),n=n), k=(n*(-1)))
    min <- lag(runMin(Lo(TS),n=n), k=(n*(-1)))
    gain <- (max/as.xts(Next(Cl(TS)))-1)*100
    loss <- (min/as.xts(Next(Cl(TS)))-1)*100    
    ret <- 1
  }
  GLR <- (gain-(loss*(-1)))/(gain+(loss*(-1)))
  GLR[is.nan(GLR)] <- 0  # replace NaN values with zero
  buyS <- gompertz(GLR)* onlypos(gain)
  buyS <- round(log(1+ buyS), digits=5)
  sellS <- gompertz(GLR*(-1))* onlypos(loss*(-1))
  sellS <- round(log(1+ sellS), digits=5)
  result <- cbind(gain,loss,GLR,buyS,sellS,ret)
  colnames(result) <- c("gain","loss","GLR","buyS","sellS","return")
  return(result)
}