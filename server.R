# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(shiny)
library(xcms)

source('plot.R')
source('doe.R')

LoadToEnvironment <- function(RData, env = new.env()) {
        load(RData, env)
        return(env)
}

csvmr <- function(data,inscf,...) {
        n <- dim(data)[2] - 2
        col <- grDevices::rainbow(n, alpha = 0.318)
        
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
                        cex = cex,
                        col = col[i],
                        pch = 19
                )
        }
        legend(
                'bottom',
                legend = name,
                col = col,
                pch = 19,
                horiz = T,
                bty = 'n'
        )
        legend(
                'top',
                legend = cexlab,
                title = 'Intensity in Log scale',
                pt.cex = c(1,2,3,4,5)/2,
                pch = 19,
                bty = 'n',
                horiz = T,
                cex = 0.8,
                col = grDevices::rgb(0,0,0,0.318)
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

shinyServer(function(input, output, session) {
        dataInput <- reactive({
                sessionEnvir <- sys.frame()
                if (!is.null(input$file))
                        load(input$file$datapath, sessionEnvir)
        })
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
        output$plot1 <- renderPlot({
                if (is.null(dataInput()))
                        return()
                else
                        plotmr(xset,
                               rsdcf = input$rsd,
                               inscf = input$ins,
                               ms = input$mz,
                               xlim = input$rt)
        })
        
        output$plot2 <- renderPlot({
                if (is.null(dataInput()))
                        return()
                else
                        plotmrc(xset,
                                rsdcf = input$rsd,
                                inscf = input$ins,
                                ms = input$mz,
                                xlim = input$rt)
        })
        
        output$plot3 <- renderPlot({
                if (is.null(dataInput()))
                        return()
                else
                        plotrsd(xset,
                                rsdcf = input$rsd,
                                inscf = input$ins,
                                ms = input$mz,
                                xlim = input$rt)
        })
        
        output$plot4 <- renderPlot({
                if (is.null(dataInput())&is.null(input$file2$datapath))
                        return()
                else if (!is.null(input$file2$datapath)){
                        data <- read.csv(input$file2$datapath)
                        csvpca(data)
                }
                else
                        plotpca(xset)
        })
        
        output$plot5 <- renderPlot({
                if (is.null(input$file2$datapath))
                        return()
                else
                        data <- read.csv(input$file2$datapath)
                csvmr(data,ylim = input$mz,
                      xlim = input$rt, inscf = input$ins)
        })
        
})
