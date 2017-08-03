



# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
        tags$head(includeScript("ga.js")),
        # Application title
        titlePanel("Visualization based on xcms"),
        
        # Sidebar with a slider input for rsd and ins
        sidebarLayout(
                sidebarPanel(
                        h4('Uploading Files'),
                        fileInput('file',
                                  label = 'R Dataset with xcmsSet object in it',
                                  accept = c('.RData')),
                        h4('Uploading csv Files'),
                        fileInput('file2',
                                  label = 'csv format',
                                  accept = c('.csv')),
                        
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
                        ),
                        "This app is created by ",
                        a("Miao Yu", href = "mailto:yufreecas@gmail.com")
                        
                ),
                
                # Show a plot of the generated distribution
                mainPanel(
                        tabsetPanel(
                                type = "tabs",
                                tabPanel(
                                        'Description',
                                        h5(
                                                "This app is developed for xcmsSet object and related csv file data visualization."
                                        ),
                                        br(),
                                        p(
                                                "You need to process data locally with ",
                                                a("xcms package", href = "https://bioconductor.org/packages/release/bioc/html/xcms.html"),
                                                "and",
                                                a("enviGCMS package", href = "https://cran.r-project.org/web/packages/enviGCMS/index.html"),
                                                "in",
                                                a("R", href = "https://www.r-project.org/"),
                                                " and upload the xcmsSet object or csv file to this app. The following code would help:"
                                        ),
                                        br(),
                                        code(
                                                "BiocInstaller::biocLite('xcms')",
                                                br(),
                                                "install.package('enviGCMS')",
                                                br(),
                                                "library(xcms)",
                                                br(),
                                                "library(enviGCMS)",
                                                br(),
                                                "path <- './data'",
                                                br(),
                                                "xset <- getdata(path)",
                                                br(),
                                                "save(xset,file = 'xset.RData')",
                                                br()
                                        ),
                                        br(),
                                        p("Then just upload your 'xset.RData' to this app."),
                                        p(
                                                "You could download demo data",
                                                a("here", href = "https://github.com/yufree/xcmsplus/blob/master/test.RData?raw=true")
                                        ),
                                        p(
                                                "Or you could upload csv file from the following code in R to get the plot. The first column should be mz and the second column should be time. The following columns could be the mean intensity in multiple groups. You could either export data from xcms online, mzMine or directly get from R script. The code is"
                                        ),
                                        br(),
                                        code(
                                                "library(xcms)",
                                                br(),
                                                "library(enviGCMS)",
                                                br(),
                                                "path <- './data'",
                                                br(),
                                                "xset <- getdata(path)",
                                                br(),
                                                "gettechrep(xset,file = 'test')",
                                                br()
                                        ),
                                        p(
                                                "You could find the csv file to be uploaded in your working folder and you could also download a demo cse file",
                                                a("here", href = "https://github.com/yufree/xcmsplus/blob/master/test.csv?raw=true")
                                        ),
                                        br(),
                                        p(
                                                "After uploading, you could see the result by hitting different tabs"
                                        ),
                                        "Contact me by click",
                                        a("here", href = "mailto:yufreecas@gmail.com"),
                                        'or just add an issue on',
                                        a("Github", href = "https://github.com/yufree/xcmsplus"),
                                        "if you have questions."
                                ),
                                tabPanel("Peaks",
                                         plotOutput("plot1"),
                                         plotOutput("plot2")),
                                tabPanel("RSD",
                                         plotOutput("plot3")),
                                tabPanel("PCA",
                                         plotOutput("plot4")),
                                tabPanel("csv",
                                         plotOutput("plot5")),
                                tabPanel(
                                        "References",
                                        p(
                                                "If you use this application for publication, please cite this application as webpages and related papers:"
                                        ),
                                        h6(
                                                "Miao Yu, Xingwang Hou, Qian Liu, Yawei
                                                Wang, Jiyan Liu, Guibin Jiang: 2017
                                                Evaluation and reduction of the
                                                analytical uncertainties in GC-MS
                                                analysis using a boundary regression
                                                model Talanta, 164, 141–147."
                                        ),
                                        h6(
                                                "Smith, C.A. and Want, E.J. and
                                                O'Maille, G. and Abagyan,R. and
                                                Siuzdak, G.: XCMS: Processing mass
                                                spectrometry data for metabolite
                                                profiling using nonlinear peak
                                                alignment, matching and identification,
                                                Analytical Chemistry, 78:779-787 (2006)
                                                
                                                "
                                        ),
                                        h6(
                                                "Ralf Tautenhahn, Christoph Boettcher,
                                                Steffen Neumann: Highly sensitive
                                                feature detection for high resolution
                                                LC/MS BMC Bioinformatics, 9:504 (2008)
                                                
                                                "
                                        ),
                                        h6(
                                                "H. Paul Benton, Elizabeth J. Want and
                                                Timothy M. D. Ebbels Correction of mass
                                                calibration gaps in liquid
                                                chromatography-mass spectrometry
                                                metabolomics data Bioinformatics,
                                                26:2488 (2010)
                                                "
                                        )
                                        )
                                        )
                                        )
                                        )
                                        ))
