# this function checks validity of time series after download
# from finance.yahoo.com

qCheckTSforValidity <- function(TS, minRows) {
  # is TS of class xts?
  if (!"xts" %in% class(TS)) {
    print ("ERROR: TS is not of class xts!")
    return (FALSE)
  }
  # are there sufficient rows?
  if (nrow(TS) < minRows) {
    print (paste("ERROR: TS contains only", nrow(TS), "rows. This is less than the required", minRows, "rows."))
    return (FALSE)
  }
  # are there any prices below zero?
  if (min(TS)<0) {
    print ("ERROR: TS contains negative values for price or volume.")
    return (FALSE)
  }
  # are price not similar?
  if (min(Cl(TS)) == max(Cl(TS))) {
    print ("ERROR: TS Close price does not vary.")
    return(FALSE)
  }
  # is the most recent date not older than 3 days?
  if (Sys.Date() - as.Date(index(TS[nrow(TS)])) > 3) {
    print (paste("ERROR: TS ends at date", index(TS[nrow(TS)])))
    return (FALSE)
  } 
  return (TRUE)
}