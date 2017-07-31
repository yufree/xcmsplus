
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(enviGCMS)

LoadToEnvironment <- function(RData, env=new.env()) {
        load(RData, env)
        return(env)
}

shinyServer(function(input, output,session) {
        dataInput <- reactive({
                sessionEnvir <- sys.frame()
                if (!is.null(input$file)) load(input$file$datapath, sessionEnvir)
        })
        
        output$plot <- renderPlot({
                if (is.null(dataInput()))  return()  else plotmr(xset3)
        })

})
