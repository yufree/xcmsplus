library(shiny)

shinyUI(fluidPage(
        tags$head(includeScript("ga.js")),
        # Application title
        titlePanel(
                "Data Visualization of GC/LC-MS profile based on xcms and enviGCMS packages"
        ),
        
        # Sidebar with a slider input for rsd and ins
        sidebarLayout(
                sidebarPanel(
                        h4('Uploading Files'),
                        fileInput('file',
                                  label = 'R Dataset with xcmsSet object in it',
                                  accept = c('.RData')),
                        h4('Uploading csv file or mzXML file'),
                        fileInput(
                                'file2',
                                label = 'csv file or mzXML file',
                                accept = c('.csv', '.mzXML')
                        ),
                        h4('Data filter'),
                        sliderInput(
                                "rsd",
                                "RSD(%)",
                                min = 1,
                                max = 100,
                                value = 30
                        ),
                        sliderInput(
                                "ins",
                                "Intensity in Log scale",
                                min = 1,
                                max = 10,
                                value = 5
                        ),
                        h5('Data Simulation'),
                        sliderInput(
                                "ncomp",
                                "Percentage of the compounds",
                                min = 0,
                                max = 1,
                                value = 0.8
                        ),
                        sliderInput(
                                "ncpeaks",
                                "Percentage of the peaks influnced by condition",
                                min = 0,
                                max = 1,
                                value = 0.1
                        ),
                        sliderInput(
                                "nbpeaks",
                                "Percentage of the peaks influnced by batch",
                                min = 0,
                                max = 1,
                                value = 0.3
                        ),
                        # sliderInput("mz", "mass Range",
                        #             min = 50, max = 1000, value = c(200,800)),
                        # sliderInput("rt", "RT Range",
                        #             min = 0, max = 5000, value = c(3000,4000)),
                        "This app is created by ",
                        a("Miao Yu", href = "mailto:yufreecas@gmail.com")
                        
                ),
                
                # Show a plot of the generated distribution
                mainPanel(
                        tabsetPanel(
                                type = "tabs",
                                id = 'dataset',
                                tabPanel(
                                        'Get started',
                                        p(
                                                "This online application could perform the following data analysis/visualization:"
                                        ),
                                        h6("xcmsSet object data visualization: Tab m/z-rt profile"),
                                        
                                        h6("csv file data visulization: Tab csv m/z-rt profile"),
                                        
                                        h6("Direct Analysis in Real Time (DART) data visualization:Tab DART"),
                                        
                                        h6("Principal Components Analysis:Tab pca"),
                                        
                                        h6("Batch Correction:Tab batch correction"),
                                        
                                        em('click the tab and have a try'),
                                        br(),
                                        "Contact me by click",
                                        a("here", href = "mailto:yufreecas@gmail.com"),
                                        'or just add an issue on',
                                        a("Github", href = "https://github.com/yufree/xcmsplus"),
                                        "if you have questions for this app."
                                ),
                                tabPanel(
                                        "m/z-rt profile",
                                        h3("Interactive scale visulization for m/z-rt profile"),
                                        h4("Prepaer the data"),
                                        p(
                                                "The following code would help:"
                                                ,
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
                                                h4("Use demo data"),
                                                p(
                                                        "You could download demo data",
                                                        a("here", href = "https://github.com/yufree/xcmsplus/blob/master/test.RData?raw=true")
                                                )
                                        ),
                                        h4("Usage"),
                                        p(
                                                "After uploading the data, you could change the RSD%, intensity(in Log scale) by the side slides to filter your data."
                                        ),
                                        p(
                                                "You could also brush an area in the left plot to see the enlarged results in right plot and the points listed in the table below the plots."
                                        ),
                                        column(
                                                6,
                                                plotOutput(
                                                        "plotmr",
                                                        click = "plot_click",
                                                        hover = "plot_hover",
                                                        brush = brushOpts(id = "plotmrs_brush",
                                                                          resetOnNew = TRUE)
                                                ),
                                                verbatimTextOutput("info")
                                        ),
                                        column(
                                                6,
                                                plotOutput('plotmrs', click = "plot_click2", hover = "plot_hover2"),
                                                verbatimTextOutput("info2")
                                        ),
                                        h4("Brushed points"),
                                        dataTableOutput("brush_info")
                                ),
                                tabPanel(
                                        "csv m/z-rt profile",
                                        h3("Interactive scale visulization for m/z-rt profile"),
                                        h4("Prepaer the data"),
                                        p(
                                                "The following code would help:"
                                                ,
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
                                                        "getbiorep(xset,file = 'test')",
                                                        br()
                                                )
                                        ),
                                        p(
                                                "You could find the csv file to be uploaded in your working folder with the name of 'test.csv'."
                                        ),
                                        p(
                                                "You could also export data from xcms online or mzMine. The first column should be m/z and the second column should be time in seconds. The following columns should be the mean intensities in multiple groups."
                                        ),
                                        h4("Use demo data"),
                                        
                                        p(
                                                "You could also download and upload a demo csv file",
                                                a("here", href = "https://github.com/yufree/xcmsplus/blob/master/test.csv?raw=true"),
                                                "."
                                        ),
                                        h4("Usage"),
                                        p(
                                                "After uploading the data, you could change intensity(in Log scale) by the side slides to filter your data. The RSD% filter is not working in this mode."
                                        ),
                                        p(
                                                "You could brush an area in the left plot to see the enlarged results in right plot and the points listed in the table below the plots."
                                        ),
                                        column(
                                                6,
                                                plotOutput(
                                                        "plotcsv",
                                                        click = "plotcsv_click",
                                                        hover = "plotcsv_hover",
                                                        brush = brushOpts(id = "plotcsvs_brush",
                                                                          resetOnNew = TRUE)
                                                ),
                                                verbatimTextOutput("infocsv")
                                        ),
                                        column(
                                                6,
                                                plotOutput('plotcsvs', click = "plotcsv_click2", hover = "plotcsv_hover2"),
                                                verbatimTextOutput("info2csv")
                                        ),
                                        h4("Brushed points"),
                                        dataTableOutput("brush_info_csv")
                                ),
                                tabPanel(
                                        "DART",
                                        h3("DART visulization"),
                                        h4("Prepaer the data"),
                                        p(
                                                "If you want to visulise the Direct Analysis in Real Time (DART) data, just upload the data (mzXML file) in the sidebar."
                                        ),
                                        h4("Use demo data"),
                                        p(
                                                "You could download demo",
                                                a('data', href = "https://github.com/yufree/xcmsplus/blob/master/test.mzXML?raw=true"),
                                                "here and have a try."
                                        ),
                                        h4("Usage"),
                                        p(
                                                "After uploading the data, you could change intensity(in Log scale) by the side slides to filter your data. The RSD% filter is not working in this mode."
                                        ),
                                        plotOutput("dart"),
                                        plotOutput("darttic"),
                                        plotOutput("dartms")
                                ),
                                
                                tabPanel("PCA",
                                         plotOutput("plotpca")),
                                tabPanel(
                                        "Batch Correction",
                                        h3("Surrogate Variable analysis(sva) correction"),
                                        plotOutput("datacorp"),
                                        plotOutput("datacorpca")
                                ),
                                tabPanel(
                                        "mzrt simulation",
                                        h3("Simulation of mzrt profile"),
                                        h4("Raw data"),
                                        plotOutput("sim"),
                                        h4("Raw data corrected"),
                                        plotOutput("sim2")
                                ),
                                # tabPanel("Background subtraction",
                                #          plotOutput("plot2",click = "plot_click")
                                #          ),
                                # tabPanel("RSD", plotOutput("plot3",click =
                                # "plot_click")),
                                # tabPanel("Corrected Peaklist"
                                #
                                # ),
                                # tabPanel("Peaklist",
                                #          dataTableOutput('datacsv'),
                                #          dataTableOutput('dataxset')
                                # ),
                                
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
