plotdart <- function(data,cf){
        pf <- xcms::profMat(data)
        rownames(pf) <- mz <- xcms::profMz(data)
        colnames(pf) <- rt <- data@scantime
        plotmz(pf,threshold = cf)
}
