


# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
        # Application title
        titlePanel("Visualization based on xcms"),
        
        # Sidebar with a slider input for rsd and ins
        sidebarLayout(
                sidebarPanel(
                        h4('Uploading Files'),
                        fileInput('file',
                                  label = 'R Dataset with xcmsSet object in it',
                                  accept = c('.RData')),
                        # h4('Uploading csv Files'),
                        # fileInput('file2',
                        #           label = 'R Dataset in csv format',
                        #           accept = c('.csv')),
                        # 
                        sliderInput(
                                "rsd",
                                "RSD(%)",
                                min = 1,
                                max = 100,
                                value = 30
                        ),
                        sliderInput(
                                "ins",
                                "Intensity",
                                min = 1,
                                max = 10,
                                value = 5
                        )
                ),
                
                # Show a plot of the generated distribution
                mainPanel(
                        tabsetPanel(type = "tabs",
                                    tabPanel('Description',p("This app is developed for xcmsSet object data visualization."),
                                             h4("Usage"),
                                             br(),
                                             p("You need to process data locally with xcms and upload the xcmsSet object to this app. The following code would help:"),
                                             br(),
                                             code("library(xcms)",br(),
                                                     "library(enviGCMS)",br(),
                                                     "path <- './data'",br(),
                                                     "xset <- getdata(path)",br(),
                                                     "save(xset,file = 'xset.RData')",br()
                                             ),
                                             br(),
                                             p("Then just upload your 'xset.RData' to this app."),
                                             br(),
                                             p("You could download demo data", a("here",href = "https://github.com/yufree/xcmsplus/blob/master/test.RData?raw=true")),
                                             "Contact me by click",
                                             a("here", href = "mailto:yufreecas@gmail.com"),
                                             'or just add an issue on',
                                             a("Github",href = "https://github.com/yufree/xcmsplus")
                                    ),
                        tabPanel("Peaks",            
                        plotOutput("plot1"),
                        plotOutput("plot2")),
                        tabPanel("RSD",
                        plotOutput("plot3")),
                        tabPanel("PCA",
                        plotOutput("plot4"))
                )
        ))
))
