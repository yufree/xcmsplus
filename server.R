

# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
source('script.R')

LoadToEnvironment <- function(RData, env = new.env()) {
        load(RData, env)
        return(env)
}

shinyServer(function(input, output, session) {
        dataInput <- reactive({
                sessionEnvir <- sys.frame()
                if (!is.null(input$file))
                        load(input$file$datapath, sessionEnvir)
        })
        
        dataInput2 <- reactive({
                if (!is.null(input$file2)) {
                        read.csv(input$file2)
                }
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
        
})
