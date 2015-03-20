# calculate return of close to close@n periods in future
qCalcReturn <- function(TS, n, type="continuous") {
  CRet <- lag(ROC(Cl(TS), n=n, type=type, na.pad=TRUE), k=n*(-1))
  colnames(CRet) <- "return"
  return(CRet)
}