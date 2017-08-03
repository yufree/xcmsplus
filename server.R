


# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(shiny)
library(xcms)

#' Get the report for biological replicates.
#' @param xset the xcmsset object which for all of your technique replicates for bio replicated sample in single group
#' @param method parameter for groupval function
#' @param intensity parameter for groupval function
#' @param file file name for further annotation, default NULL
#' @param rsdcf rsd cutoff for peaks, default 30
#' @param inscf log intensity cutoff for peaks, default 5
#' @return dataframe with mean, standard deviation and RSD for those technique replicates & biological replicates combined with raw data
#' @export
getbiotechrep <-
        function(xset,
                 method = "medret",
                 intensity = "into",
                 file = NULL,
                 rsdcf = 30,
                 inscf = 5) {
                data0 <- xcms::groupval(xset, method, intensity)
                data0[is.na(data0)] = 0
                data <- t(data0)
                lv <- xset@phenoData[, 1]
                mean <- stats::aggregate(data, list(lv), mean)
                sd <- stats::aggregate(data, list(lv), sd)
                suppressWarnings(rsd <- sd / mean * 100)
                result <-
                        data.frame(cbind(t(mean[,-1]), t(sd[, -1]), t(rsd[,-1])))
                colnames(result) <-
                        c(paste0(t(mean[, 1]), "mean"),
                          paste0(t(sd[, 1]), "sd"),
                          paste0(t(mean[, 1]), "rsd%"))
                
                meanB <- apply(t(mean[,-1]), 1, mean)
                sdB <- apply(t(mean[, -1]), 1, sd)
                rsdB <- sdB / meanB * 100
                
                index <- rsdB < rsdcf & meanB > 10 ^ (inscf)
                
                datap <- xcms::groups(xset)
                report <- cbind.data.frame(datap, result, meanB, sdB, rsdB)
                report <- report[index, ]
                
                N <- sum(index)
                L <- length(index)
                
                message(
                        paste(
                                N,
                                'out of',
                                L,
                                'peaks found with rsd cutoff',
                                rsdcf,
                                'and Log intensity cutoff',
                                inscf
                        )
                )
                
                report <- report[index, ]
                
                if (!is.null(file)) {
                        anno <-
                                cbind.data.frame(xset@groups[, 1], xset@groups[, 4], t(mean[,-1]))
                        colnames(anno) <-
                                c("mz", "time", as.character(t(mean[, 1])))
                        utils::write.csv(anno,
                                         file = paste0(file, '.csv'),
                                         row.names = F)
                        anno <- anno[index, ]
                        return(anno)
                } else {
                        return(report)
                }
        }

#' Get the report for biological replicates without technique replicates.
#' @param xset the xcmsset object which for bio replicated sample in different groups
#' @param method parameter for groupval function
#' @param intensity parameter for groupval function
#' @param file file name for further annotation, default NULL
#' @param rsdcf rsd cutoff for peaks, default 30
#' @param inscf log intensity cutoff for peaks, default 5
#' @return dataframe with mean, standard deviation and RSD for biological replicates combined with raw data
#' @export
getbiorep <-
        function(xset,
                 method = "medret",
                 intensity = "into",
                 file = NULL,
                 rsdcf = 30,
                 inscf = 5) {
                data0 <- xcms::groupval(xset, method, intensity)
                data0[is.na(data0)] = 0
                data <- t(data0)
                lv <- xset@phenoData[, 1]
                mean <- stats::aggregate(data, list(lv), mean)
                sd <- stats::aggregate(data, list(lv), sd)
                suppressWarnings(rsd <- sd / mean * 100)
                result <-
                        data.frame(cbind(t(mean[,-1]), t(sd[, -1]), t(rsd[,-1])))
                colnames(result) <-
                        c(paste0(t(mean[, 1]), "mean"),
                          paste0(t(sd[, 1]), "sd"),
                          paste0(t(mean[, 1]), "rsd%"))
                
                indexrsd <-
                        apply(t(rsd[, -1]), 1, function(x)
                                any(x < rsdcf))
                indexmean <-
                        apply(t(mean[, -1]), 1, function(x)
                                any(x > 10 ^ (inscf)))
                
                index <- indexrsd & indexmean
                
                datap <- xcms::groups(xset)
                report <- cbind.data.frame(datap, result)
                report <- report[index, ]
                
                N <- sum(index)
                L <- length(index)
                
                if (N == 0) {
                        message(paste('No peaks found'))
                        return(NA)
                } else{
                        message(
                                paste(
                                        N,
                                        'out of',
                                        L,
                                        'peaks found with rsd cutoff',
                                        rsdcf,
                                        'and Log intensity cutoff',
                                        inscf
                                )
                        )
                        report <- report[index, ]
                        
                        if (!is.null(file)) {
                                anno <-
                                        cbind.data.frame(xset@groups[, 1], xset@groups[, 4], t(mean[,-1]))
                                colnames(anno) <-
                                        c("mz", "time", as.character(t(mean[, 1])))
                                utils::write.csv(anno,
                                                 file = paste0(file, '.csv'),
                                                 row.names = F)
                                anno <- anno[index, ]
                                return(anno)
                        } else {
                                return(report)
                        }
                }
        }

#' plot the scatter plot for xcmsset objects with threshold
#' @param xset the xcmsset object
#' @param ms the mass range to plot the data
#' @param inscf log intensity cutoff for peaks, default 5
#' @param rsdcf the rsd cutoff of all peaks
#' @param ... parameters for `plot` function
#' @return data fit the cutoff
#' @examples
#' \dontrun{
#' library(faahKO)
#' cdfpath <- system.file("cdf", package = "faahKO")
#' xset <- getdata(cdfpath, pmethod = ' ')
#' plotmr(xset)
#' }
#' @export
plotmr <- function(xset,
                   ms = c(100, 1000),
                   inscf = 5,
                   rsdcf = 30,
                   ...) {
        data <- getbiorep(xset, rsdcf = rsdcf, inscf = inscf)
        suppressWarnings(if (!is.na(data)) {
                datamean <- data[, grepl('*mean', colnames(data))]
                dataname <- unique(xcms::sampclass(xset))
                n <- dim(datamean)[2]
                col <- grDevices::rainbow(n, alpha = 0.318)
                
                graphics::plot(
                        data$mzmed ~ data$rtmed,
                        xlab = "Retention Time(s)",
                        ylab = "m/z",
                        ylim = ms,
                        type = 'n',
                        pch = 19,
                        ...
                )
                
                for (i in 1:n) {
                        graphics::points(
                                x = data$rtmed,
                                y = data$mzmed,
                                ylim = ms,
                                cex = log10(datamean[, i] + 1) - inscf + 1,
                                col = col[i],
                                pch = 19
                        )
                }
                legend(
                        'top',
                        legend = dataname,
                        col = col,
                        pch = 19,
                        horiz = T,
                        bty = 'n'
                )
        } else{
                graphics::plot(
                        1,
                        xlab = "Retention Time(s)",
                        ylab = "m/z",
                        main = "No peaks found",
                        ylim = ms,
                        type = 'n',
                        pch = 19,
                        ...
                )
        })
}

#' plot the diff scatter plot for one xcmsset objects with threshold and two groups
#' @param xset xcmsset object with two groups
#' @param ms the mass range to plot the data
#' @param inscf log intensity cutoff for peaks, default 5
#' @param rsdcf the rsd cutoff of all peaks
#' @param ... parameters for `plot` function
#' @return NULL
#' @examples
#' \dontrun{
#' library(faahKO)
#' cdfpath <- system.file("cdf", package = "faahKO")
#' xset <- getdata(cdfpath, pmethod = ' ')
#' plotmrc(xset)
#' }
#' @export
plotmrc <- function(xset,
                    ms = c(100, 1000),
                    inscf = 5,
                    rsdcf = 30,
                    ...)  {
        data <- getbiorep(xset, rsdcf = rsdcf, inscf = inscf)
        suppressWarnings(if (!is.na(data)) {
                datamean <- data[, grepl('*mean', colnames(data))]
                dataname <- unique(xcms::sampclass(xset))
                
                diff1 <- datamean[, 1] - datamean[, 2]
                diff2 <- datamean[, 2] - datamean[, 1]
                diff1[diff1 < 0] <- 0
                diff2[diff2 < 0] <- 0
                name1 <- paste0(dataname[1], "-", dataname[2])
                name2 <- paste0(dataname[2], "-", dataname[1])
                
                graphics::plot(
                        data$mzmed ~ data$rtmed,
                        xlab = "Retention Time(s)",
                        ylab = "m/z",
                        ylim = ms,
                        cex = log10(diff1 + 1) - inscf + 1,
                        col = grDevices::rgb(0, 0, 1, 0.618),
                        pch = 19,
                        ...
                )
                
                graphics::points(
                        data$mzmed ~ data$rtmed,
                        cex = log10(diff2 + 1) - inscf + 1,
                        col = grDevices::rgb(1, 0, 0, 0.618),
                        pch = 19
                )
                
                graphics::legend(
                        'top',
                        legend = c(name1, name2),
                        pch = 19,
                        col = c(
                                grDevices::rgb(0, 0, 1, 0.618),
                                grDevices::rgb(1, 0, 0, 0.618)
                        ),
                        bty = 'n',
                        horiz = T
                )
        } else{
                graphics::plot(
                        1,
                        xlab = "Retention Time(s)",
                        ylab = "m/z",
                        main = "No peaks found",
                        ylim = ms,
                        type = 'n',
                        pch = 19,
                        ...
                )
        })
        
}

#' plot the rsd influnces of data
#' @param xset xcmsset data
#' @param ... other parameters for `plot` function
#' @return NULL
#' @examples
#' \dontrun{
#' library(faahKO)
#' cdfpath <- system.file("cdf", package = "faahKO")
#' xset <- getdata(cdfpath, pmethod = ' ')
#' plotrsd(xset)
#' }
#' @export
plotrsd <- function(xset, ...) {
        df <- getbiotechrep(xset)
        mz <- df$mzmed
        rt <- df$rtmin
        cex <- df$rsd
        graphics::plot(
                mz ~ rt,
                cex = scale(cex),
                xlab = 'retention time',
                ylab = 'm/z',
                ...
        )
}

#' plot the PCA of xcmsset
#' @param xset xcmsset data
#' @param lv group information
#' @param center parameters for PCA
#' @param scale parameters for scale
#' @param ... other parameters for `plot` function
#' @return NULL
#' @examples
#' \dontrun{
#' library(faahKO)
#' cdfpath <- system.file("cdf", package = "faahKO")
#' xset <- getdata(cdfpath, pmethod = ' ')
#' plotpca(xset)
#' }
#' @export

plotpca <- function(xset,
                    lv = NULL,
                    center = T,
                    scale = T,
                    ...) {
        data <- xcms::groupval(xset, 'medret', 'into')
        data <- data[complete.cases(data),]
        if (is.null(lv)) {
                pch = colnames(data)
        } else {
                pch = lv
        }
        pcao <- stats::prcomp(t(data), center = center,
                              scale = scale)
        pcaoVars = signif(((pcao$sdev) ^ 2) / (sum((pcao$sdev) ^ 2)),
                          3) * 100
        graphics::plot(
                pcao$x[, 1],
                pcao$x[, 2],
                xlab = paste("PC1:",
                             pcaoVars[1], "% of Variance Explained"),
                ylab = paste("PC2:",
                             pcaoVars[2], "% of Variance Explained"),
                pch = pch,
                cex = 2,
                ...
        )
}

LoadToEnvironment <- function(RData, env = new.env()) {
        load(RData, env)
        return(env)
}

csvmr <- function(data) {
        n <- dim(data)[2] - 2
        col <- grDevices::rainbow(n, alpha = 0.318)
        
        graphics::plot(
                data$mz ~ data$time,
                xlab = "Retention Time(s)",
                ylab = "m/z",
                ylim = c(100, 1000),
                type = 'n',
                pch = 19
        )
        data2 <- data[, -c(1, 2)]
        name <- colnames(data2)
        for (i in 1:n) {
                value <- as.numeric(t(data2)[i, ])
                graphics::points(
                        y = data$mz,
                        x = data$time,
                        cex = log10(value + 1) - 4,
                        col = col[i],
                        pch = 19
                )
        }
        legend(
                'top',
                legend = name,
                col = col,
                pch = 19,
                horiz = T,
                bty = 'n'
        )
}

shinyServer(function(input, output, session) {
        dataInput <- reactive({
                sessionEnvir <- sys.frame()
                if (!is.null(input$file))
                        load(input$file$datapath, sessionEnvir)
        })
        
        output$plot1 <- renderPlot({
                if (is.null(dataInput()))
                        return()
                else
                        plotmr(xset,
                               rsdcf = input$rsd,
                               inscf = input$ins)
        })
        
        output$plot2 <- renderPlot({
                if (is.null(dataInput()))
                        return()
                else
                        plotmrc(xset,
                                rsdcf = input$rsd,
                                inscf = input$ins)
        })
        
        output$plot3 <- renderPlot({
                if (is.null(dataInput()))
                        return()
                else
                        plotrsd(xset)
        })
        
        output$plot4 <- renderPlot({
                if (is.null(dataInput()))
                        return()
                else
                        plotpca(xset)
        })
        
        output$plot5 <- renderPlot({
                if (is.null(input$file2$datapath))
                        return()
                else
                        data <- read.csv(input$file2$datapath)
                csvmr(data)
        })
        
})
