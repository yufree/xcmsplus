
#' plot GC/LC-MS data as scatter plot
#'
#' @param data imported data matrix of GC-MS
#' @param threshold the threshold of the response (log based 10)
#' @param ... parameters for `plot` function
#' @return scatter plot
#' @examples
#' \dontrun{
#' library(faahKO)
#' cdfpath <- system.file("cdf", package = "faahKO")
#' cdffiles <- list.files(cdfpath, recursive = TRUE, full.names = TRUE)
#' matrix <- getmd(cdffiles[1])
#' png('test.png')
#' plotmz(matrix)
#' dev.off()
#' }
#' @export
plotmz <- function(data, threshold = 5,...){
        mz <- as.numeric(rownames(data))
        rt <- as.numeric(colnames(data))
        z <- log10(data+1)
        z[z<threshold] <- NA
        corr <- which(!is.na(z), arr.ind = TRUE)
        mz0 <- mz[corr[,1]]
        rt0 <- rt[corr[,2]]
        int <- z[which(!is.na(z))]
        
        graphics::plot(mz0~rt0,
                       pch = 19,
                       cex = int - threshold + 1,
                       col = grDevices::rgb(0,0, 0, 0.1),
                       xlab = "retention time(s)",
                       ylab = "m/z",...)
}


plotdart <- function(data,cf){
        pf <- xcms::profMat(data)
        rownames(pf) <- mz <- xcms::profMz(data)
        colnames(pf) <- rt <- data@scantime
        enviGCMS::plotmz(pf,threshold = cf)
}
