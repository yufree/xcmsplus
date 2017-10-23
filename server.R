# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(shiny)
library(xcms)

source('plot.R')
source('doe.R')
source('sva.R')
source('dart.R')
source('mzrtsim.R')

LoadToEnvironment <- function(RData, env = new.env()) {
        load(RData, env)
        return(env)
}

csvmr <- function(data,inscf,...) {
        n <- dim(data)[2] - 2
        col <- grDevices::rainbow(n, alpha = 0.318)
        par(mar=c(5, 4.2, 6.1, 2.1), xpd=TRUE)
        graphics::plot(
                data$mz ~ data$time,
                xlab = "Retention Time(s)",
                ylab = "m/z",
                type = 'n',
                pch = 19,
                ...
        )
        data2 <- data[, -c(1, 2)]
        index <- apply(data2,1,function(x) any(log10(x+1)>inscf))
        data3 <- data2[index,]
        name <- colnames(data3)
        for (i in 1:n) {
                value <- log10(as.numeric(t(data3)[i, ])+1)
                cex = as.numeric(cut((value-inscf), breaks=c(0,1,2,3,4,Inf)/2))/2
                cexlab = c(paste0(inscf,'-',inscf+0.5),paste0(inscf+0.5,'-',inscf+1),paste0(inscf+1,'-',inscf+1.5),paste0(inscf+1.5,'-',inscf+2),paste0('>',inscf+2))
                graphics::points(
                        y = data$mz[index],
                        x = data$time[index],
                        cex = cex[index],
                        col = col[i],
                        pch = 19
                )
        }
        graphics::legend(
                'topright',
                legend = name,
                col = col,
                pch = 19,
                horiz = T,
                bty = 'n',
                inset = c(0,-0.25)
        )
        graphics::legend(
                'topleft',
                legend = cexlab,
                title = 'Intensity in Log scale',
                pt.cex = c(1,2,3,4,5)/2,
                pch = 19,
                bty = 'n',
                horiz = T,
                cex = 0.7,
                col = grDevices::rgb(0,0,0,0.318),inset = c(0,-0.25)
        )
}


csvmr2 <- function(data,inscf,ms,rt) {
        n <- dim(data)[2] - 2
        col <- grDevices::rainbow(n, alpha = 0.318)
        par(mar=c(5, 4.2, 6.1, 2.1), xpd=TRUE)
        graphics::plot(
                data$mz ~ data$time,
                xlab = "Retention Time(s)",
                ylab = "m/z",
                type = 'n',
                pch = 19,
                xlim = rt,
                ylim = ms
        )
        data2 <- data[, -c(1, 2)]
        index1 <- apply(data2,1,function(x) any(log10(x+1)>inscf))
        index2 <- data$time>rt[1]&data$time<rt[2]&data$mz>ms[1]&data$mz<ms[2]
        index <- index1&index2
        data3 <- data2[index,]
        name <- colnames(data3)
        for (i in 1:n) {
                value <- log10(as.numeric(t(data3)[i, ])+1)
                cex = as.numeric(cut((value-inscf), breaks=c(0,1,2,3,4,Inf)/2))/2
                cexlab = c(paste0(inscf,'-',inscf+0.5),paste0(inscf+0.5,'-',inscf+1),paste0(inscf+1,'-',inscf+1.5),paste0(inscf+1.5,'-',inscf+2),paste0('>',inscf+2))
                graphics::points(
                        y = data$mz[index],
                        x = data$time[index],
                        cex = cex,
                        col = col[i],
                        pch = 19
                )
        }
        graphics::legend(
                'topright',
                legend = name,
                col = col,
                pch = 19,
                horiz = T,
                bty = 'n',
                inset = c(0,-0.25)
        )
        graphics::legend(
                'topleft',
                legend = cexlab,
                title = 'Intensity in Log scale',
                pt.cex = c(1,2,3,4,5)/2,
                pch = 19,
                bty = 'n',
                horiz = T,
                cex = 0.7,
                col = grDevices::rgb(0,0,0,0.318),inset = c(0,-0.25)
        )
}

csvpca <- function(data,
                    center = T,
                    scale = T) {
        
                pch = colnames(data[,-c(1,2)])
                
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
                cex = 2
        )
}

xy_str <- function(e) {
        if(is.null(e)) return("NULL\n")
        paste0("RT=", round(e$x, 1), "s m/z=", round(e$y, 4), "\n")
}
# csvbatchcor <- function(data){
#         mod <- stats::model.matrix(~lv)
#         mod0 <- as.matrix(c(rep(1, ncol(data))))
#         svafit <- sva::sva(data, mod)
# }

shinyServer(function(input, output, session) {
        # data input
        dataInput <- reactive({
                sessionEnvir <- sys.frame()
                if (!is.null(input$file))
                        load(input$file$datapath, sessionEnvir)
        })
        # peaklist
        output$datacsv <- renderDataTable({
                if (is.null(input$file2$datapath))
                        return()
                else
                        read.csv(input$file2$datapath)
                })
        output$dataxset <- renderDataTable({
                if (is.null(dataInput()))
                        return()
                else
                        getbiorep(xset)
        })
        # plotmr
        ranges <- reactiveValues(x = NULL, y = NULL)
        output$plotmr <- renderPlot({
                if (is.null(dataInput()))
                        return()
                else
                        plotmr(xset,
                               rsdcf = input$rsd,
                               inscf = input$ins)
        })
        output$plotmrs <- renderPlot({
                if (is.null(dataInput()))
                        return()
                else
                        plotmr2(xset,
                               rsdcf = input$rsd,
                               inscf = input$ins,
                               ms = ranges$y,
                               rt = ranges$x)
        })
        
        observe({
                brush <- input$plotmrs_brush
                if (!is.null(brush)) {
                        ranges$x <- c(brush$xmin, brush$xmax)
                        ranges$y <- c(brush$ymin, brush$ymax)
                        
                } else {
                        ranges$x <- NULL
                        ranges$y <- NULL
                }
        })
        output$info <- renderText({
                paste0(
                        "click: ", xy_str(input$plot_click),
                        "hover: ", xy_str(input$plot_hover)
                )
        })
        output$info2 <- renderText({
                paste0(
                        "click: ", xy_str(input$plot_click2),
                        "hover: ", xy_str(input$plot_hover2)
                )
        })
        
        output$brush_info <- renderDataTable({
                if (is.null(dataInput()))
                        return()
                else
                        data <- getbiorep(xset, rsdcf = input$rsd, inscf = input$ins)
                brushedPoints(data, input$plotmrs_brush, "rtmed","mzmed")
        })
        
        # output$plot2 <- renderPlot({
        #         if (is.null(dataInput()))
        #                 return()
        #         else
        #                 plotmrc(xset,
        #                         rsdcf = input$rsd,
        #                         inscf = input$ins,
        #                         ms = input$mz,
        #                         xlim = input$rt)
        # })
        # 
        # output$plot3 <- renderPlot({
        #         if (is.null(dataInput()))
        #                 return()
        #         else
        #                 plotrsd(xset,
        #                         rsdcf = input$rsd,
        #                         inscf = input$ins,
        #                         ms = input$mz,
        #                         xlim = input$rt)
        # })
        
        # plotpca
        output$plotpca <- renderPlot({
                if (is.null(dataInput()))
                        return()
                # else if (!is.null(input$file2$datapath)){
                #         data <- read.csv(input$file2$datapath)
                #         csvpca(data)
                # }
                else
                        plotpca(xset)
        })
        
        # plotcsv
        output$plotcsv <- renderPlot({
                if (is.null(input$file2$datapath))
                        return()
                else
                        data <- read.csv(input$file2$datapath)
                csvmr(data, inscf = input$ins)
        })
        output$plotcsvs <- renderPlot({
                if (is.null(input$file2$datapath))
                        return()
                else
                        data <- read.csv(input$file2$datapath)
                        csvmr2(data,
                                inscf = input$ins,
                                ms = ranges$y,
                                rt = ranges$x)
        })
        
        observe({
                brush <- input$plotcsvs_brush
                if (!is.null(brush)) {
                        ranges$x <- c(brush$xmin, brush$xmax)
                        ranges$y <- c(brush$ymin, brush$ymax)
                        
                } else {
                        ranges$x <- NULL
                        ranges$y <- NULL
                }
        })
        output$infocsv <- renderText({
                paste0(
                        "click: ", xy_str(input$plotcsv_click),
                        "hover: ", xy_str(input$plotcsv_hover)
                )
        })
        output$info2csv <- renderText({
                paste0(
                        "click: ", xy_str(input$plotcsv_click2),
                        "hover: ", xy_str(input$plotcsv_hover2)
                )
        })
        
        output$brush_info_csv <- renderDataTable({
                if (is.null(input$file2$datapath))
                        return()
                else
                        data <- read.csv(input$file2$datapath)
                brushedPoints(data, input$plotcsvs_brush, "time","mz")
        })

        output$datacorp <- renderPlot({
                if (is.null(dataInput()))
                        return()
                else
                        li <- svacor(xset)
                        lv <- xset@phenoData[, 1]
                        svaplot(list = li,lv = lv)
        })
        output$datacorpca <- renderPlot({
                if (is.null(dataInput()))
                        return()
                else
                        li <- svacor(xset)
                        svapca(list = li)
        })
        
        output$dart <- renderPlot({
                if (is.null(input$file2$datapath))
                        return()
                else
                        data <- xcms::xcmsRaw(input$file2$datapath)
                plotdart(data, cf = input$ins)
        })
        
        output$darttic <- renderPlot({
                if (is.null(input$file2$datapath))
                        return()
                else
                        data <- xcms::xcmsRaw(input$file2$datapath)
                xcms::plotTIC(data)
        })
        
        output$dartms <- renderPlot({
                if (is.null(input$file2$datapath))
                        return()
                else
                        data <- xcms::xcmsRaw(input$file2$datapath)
                plotdartms(data)
        })
        
        # simulation data
        output$sim <- renderPlot({
                sim <- mzrtsim(npeaks = 2000, ncomp = input$ncomp, ncpeaks = input$ncpeaks, nbpeaks = input$nbpeaks)
                simroc(sim)
        })
        output$sim1 <- renderPlot({
                sim <- mzrtsim(npeaks = 2000, ncomp = input$ncomp, ncpeaks = input$ncpeaks, nbpeaks = input$nbpeaks)
                ridgesplot(sim$data, as.factor(sim$con))
        })
        output$sim2 <- renderPlot({
                sim <- mzrtsim(npeaks = 2000, ncomp = input$ncomp, ncpeaks = input$ncpeaks, nbpeaks = input$nbpeaks)
                sim2 <- svacor2(log(sim$data), as.factor(sim$con))
                par(mfrow = c(1,2))
                hist(sim2$`p-valuesCorrected`,main = 'p value corrected')
                hist(sim2$`p-values`,main = 'p value')
        })
        output$sim3 <- renderPlot({
                sim <- mzrtsim(npeaks = 2000, ncomp = input$ncomp, ncpeaks = input$ncpeaks, nbpeaks = input$nbpeaks)
                sim2 <- isvacor(log(sim$data), as.factor(sim$con))
                par(mfrow = c(1,2))
                hist(sim2$`p-valuesCorrected`,main = 'p value corrected')
                hist(sim2$`p-values`,main = 'p value')
        })
        
        
})
