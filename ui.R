
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Visualization based on xcms"),

  h4('Uploading Files'),
  fileInput('file',
            label = 'R Dataset with xcmsSet object in it',
            accept = c('.RData')),
  
  # Sidebar with a slider input for rsd
  sidebarLayout(
    sidebarPanel(
      sliderInput("rsd",
                  "RSD(%)",
                  min = 1,
                  max = 100,
                  value = 30)
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("plot")
    )
  )
))
