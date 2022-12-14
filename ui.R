

##### Load Packages  #####
#### Basic installation ####
  ## Check whether the installation of those packages is required from basic
  Package.set <- c("tidyverse","ggplot2","Seurat","SeuratData","patchwork","plyr","eoffice","DT","shiny","shinyFiles")
  for (i in 1:length(Package.set)) {
    if (!requireNamespace(Package.set[i], quietly = TRUE)){
      install.packages(Package.set[i])
    }
  }
  ## Load Packages
  lapply(Package.set, library, character.only = TRUE)
  rm(Package.set,i)


#### BiocManager installation ####
  ## Set the desired organism
  # organism = "org.Hs.eg.db" ## c("org.Hs.eg.db","org.Mm.eg.db")   ##  c("org.Dm.eg.db")

  ## Check whether the installation of those packages is required from BiocManager
  if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
  Package.set <- c("clusterProfiler","enrichplot","pathview") # c(organism,"fgsea","clusterProfiler","enrichplot","pathview")
  for (i in 1:length(Package.set)) {
    if (!requireNamespace(Package.set[i], quietly = TRUE)){
      BiocManager::install(Package.set[i])
    }
  }
  ## Load Packages
  lapply(Package.set, library, character.only = TRUE)
  rm(Package.set,i)

  # options(stringsAsFactors = FALSE)


# Sys.setlocale(category = "LC_ALL", locale = "UTF-8")


##### Function setting #####
  ## Call function
  source("FUN_Beautify_ggplot.R")
  source("FUN_Find_Markers.R")
  source("FUN_VolcanoPlot.R")
  source("FUN_GSEA_LargeGeneSet.R")
  source("FUN_GSEA_ggplot.R")
  source("FUN_ggPlot_vline.R")

  source("FUN_DistrPlot.R")
  source("FUN_Group_GE.R")
  source("FUN_DEG_Analysis.R")
  source("FUN_GSEA_ANAL.R")
  source("FUN_GSEA_ForOFFL.R")

##### UI ########
  ui <- navbarPage(

                   # p(strong(code("GseaGoUI", style='background-color:#a7c1d9; color:#0c3d6b; font-family: Arial Black'))),
                   p(strong(img(src = "GSEAGOUI.png",
                                height = "90px", width = "85px",
                                align = "center"))),

                      # h1("GseaGoUI",
                      # style='background-color:#a7c1d9; color:#0c3d6b; font-family: Arial Black' ),
###############################################################################################################################################
      navbarMenu("Enrichment Analysis",
                 # img(src = "GSEAGOUI.png",
                 #     height = "80px", width = "75px",
                 #     align = "center"),

#####*********** Basic Enrichment Analysis ***********#####
         tabPanel("Basic",
                  fluidPage(
                    # https://stackoverflow.com/questions/57037758/r-shiny-how-to-color-margin-of-title-panel
                    titlePanel(
                                h3(br(),"GseaGoUI"),
                                # h1("GseaGoUI",
                                #   style='background-color:#e6d5f2;
                                #          color:#474973;
                                #          font-weight: 500;
                                #          font-family: Arial Black;
                                #          line-height: 1.2;
                                #          padding-left: 15px'
                                #  )

                               ),

                    sidebarLayout(
                      sidebarPanel(
                        fileInput("File_GeneExp", "Choose GeneExp File", accept = ".tsv", multiple = T),
                        fileInput("File_Anno", "Choose Annotation File", accept = ".tsv", multiple = T),
                        fileInput("File_GeneSet", "Choose GeneSet Files", accept = ".txt", multiple = F),
                        hr(),
                        # https://stackoverflow.com/questions/39196743/interactive-directory-input-in-shiny-app-r
                        tags$div(h2("Choose the path to save the results",
                                    style= 'color:#474973;
                                            font-size: 1.7rem; line-height: 1.7rem;
                                            font-family: Arial Black;
                                            padding-left: 0px'),
                                   tags$label("Save Path", class="btn btn-primary",
                                   tags$input(id = "fileIn", webkitdirectory = TRUE, type = "file", style="display: none;", onchange="pressed()"))),
                      ),

                      # mainPanel(textOutput(outputId="BestSent")),
                      mainPanel(
                        tabsetPanel(
                          tabPanel("Data preprocessing",
                                   column(3,
                                   h3("Fliter by Phenotype"),
                                   textInput("FliterByPhenotype", label = "Phenotype section","sample_type"),
                                   textInput("FliterByPhenotype2", label = "Group section","Recurrent Tumor, Primary Tumor"),
                                   h3("Fliter by Gene expression"),
                                   textInput("FliterByGeneExp", label = "Gene name","TP53"),
                                   column(6,
                                   textInput("MaxGeneExp", label = "Max GeneExp",""),),
                                   column(6,
                                   textInput("MinGeneExp", label = "Min GeneExp",""),),
                                   br(),
                                   actionButton(inputId="FilterSet", label="Filter", icon=icon(name = "filter-circle-xmark")) # https://fontawesomeicons.com/
                                   ),

                          ),

                          navbarMenu("Group setting",

                                     tabPanel("Group by Pheno",
                                              column(6,
                                                     fluidPage(plotOutput("DistPlt2"))
                                              ),
                                              column(3,
                                                     h3("Group by Phenotype"),
                                                     hr(),
                                                     textInput("PhenoColSet", label = "Phenotype","sample_type"),
                                                     textInput("PhenoType1Set", label = "Group 1","Recurrent Tumor"),
                                                     textInput("PhenoType2Set", label = "Group 2","Primary Tumor"),
                                                     hr(),
                                                     actionButton(inputId="DistPlot2", label="See Dist", icon=icon(name = "photo")) # https://fontawesomeicons.com/

                                              )
                                     ),
                                     tabPanel("Group by GeneExp",
                                                column(6,
                                                       fluidPage(plotOutput("DistPlt"))
                                                ),
                                                column(4,
                                                       # br(),
                                                       h3("Group by Gene Expression"),
                                                       hr(),
                                                       textInput("GeneNameSet", label = "Gene name","TP53"),
                                                       selectizeInput("GroupByGeneStats", label = "Cutoff of GeneExp",
                                                                      choices = list("Mean" = "Mean", "Mean+1SD" = "Mean1SD", "Mean+2SD" = "Mean2SD", "Mean+3SD" = "Mean3SD",
                                                                                     "Median" = "Median" , "Quartiles" = "Quartiles",
                                                                                     "Customize Cutoff" = "CustomizeCutoff"),
                                                                      selected = "Mean1SD"),
                                                       column(6,
                                                       textInput("UpBoundGeneExp", label = "Upper Cutoff","1")),
                                                       column(6,
                                                       textInput("LowBoundGeneExp", label = "Lower Cutoff","1")),
                                                       column(12,hr()),
                                                       actionButton(inputId="DistPlot", label="See Dist", icon=icon(name = "photo")) # https://fontawesomeicons.com/
                                                )
                                              )
                          ),

                          tabPanel("DEG setting",
                                    h3("Filter"),
                                    hr(),
                                    textInput("LogFCSet", label = "LogFC Cutoff","1"),
                                    textInput("PvalueCSet", label = "P Value Cutoff","0.05"),
                                    hr(),
                                    actionButton(inputId="RunDEG", label="Run DEG", icon=icon(name = "gears")) # https://fontawesomeicons.com/
                                  ),

                          tabPanel("GSEA setting",
                                   column(6,
                                   h3("GSEA Analysis"),
                                   hr(),
                                   selectizeInput("GSEAGroupSet", label = "Group by",
                                                  choices = list("Phenotype" = "GSEAGroupbyPheno",
                                                                 "Gene Expression" = "GSEAGroupbyGeneExp"),
                                                  selected = "GroupbyPheno"),

                                   textInput("GSEASet_NumPermu", label = "Number of Permutations","1000"),
                                   selectizeInput("pAdjustMethod", label = "pAdjust Method",
                                                  choices = list("BH Method" = "BH",
                                                                 "BY Method" = "BY",
                                                                 "bonferroni Method" = "bonferroni",
                                                                 "FDR Method" = "fdr",
                                                                 "hommel Method" = "hommel",
                                                                 "holm Method" = "holm",
                                                                 "hochberg Method" = "hochberg",
                                                                 "None" = "none"),
                                                  selected = "GSEASet_GeneSet"),
                                   column(3,
                                   textInput("GSEASet_MinGSize", label = "Min geneset size","15"),),
                                   column(3,
                                   textInput("GSEASet_MaxGSize", label = "Max geneset size","500"),)
                                   ),
                                   column(6,
                                          h3("Visualization settings"),
                                          hr(),
                                          textInput("GSEASet_TopGS", label = "TOP Gene Sets","10"),
                                          textInput("GSEASet_BottomGS", label = "Bottom Gene Sets","10"),
                                          textInput("GSEASet_CustomizedGS", label = "Customized Gene Sets",""),
                                          br(),
                                          actionButton("RunOFL", "Official files", icon=icon(name = "file-download")),
                                          actionButton("RunGSEA", "Run GSEA", icon=icon(name = "gears")) # https://fontawesomeicons.com/
                                         )
                          ),

                          tabPanel("ORA setting",
                                   column(6,
                                   h3("ORA Enrichment Analysis"),
                                   hr(),
                                   selectizeInput("ORAGroupSet", label = "Group by",
                                                  choices = list("Phenotype" = "ORAGroupbyPheno",
                                                                 "Gene Expression" = "ORAGroupbyGeneExp"),
                                                  selected = "GroupbyPheno"),
                                   textInput("ORASet_MinOverlap", label = "Min Overlap","3"),
                                   textInput("ORASet_PValue", label = "P Value Cutoff","0.05"),
                                   textInput("ORASet_MinEnrich", label = "Min Enrichment","1.5"),
                                   ),
                                   column(6,
                                          h3("Visualization settings"),
                                          hr(),
                                          textInput("GOSet_TopGS", label = "TOP Gene Sets","10"),
                                          textInput("GOSet_BottomGS", label = "Bottom Gene Sets","10"),
                                          textInput("GOSet_CustomizedGS", label = "Customized Gene Sets",""),
                                          br(),
                                          actionButton("RunOFL", "Official file", icon=icon(name = "file-download")),
                                          actionButton("RunGO", "Run ORA", icon=icon(name = "gears")) # https://fontawesomeicons.com/

                                   )

                          )
                        )

                      ),


                      position = c("left")
                    ),

                    ##### Summary Page ##################################################################
                    tabsetPanel(
                      # tabPanel("Summary",
                      #          fluidPage(
                      #           # plotOutput("HisFig"),
                      #           # tableOutput("SumTable"))
                      #            fluidPage(fluidRow(dataTableOutput("SumTable"))))
                      #          ),

                      ##### Text search Page #####
                      navbarMenu("View Input",
                                 tabPanel("GeneExp",
                                          fluidPage(fluidRow(dataTableOutput("GeneExpOut")))
                                 ),
                                 tabPanel("Annotation",
                                          fluidPage(fluidRow(dataTableOutput("AnnoOut")))
                                 ),
                                 tabPanel("Gene sets",
                                          fluidPage(fluidRow(dataTableOutput("GenesetsOut")))
                                 )
                      ),

                      ##### Data preprocessing Result Page #####
                      navbarMenu("Cleaned data",
                                 tabPanel("GeneExp",
                                          fluidPage(fluidRow(dataTableOutput("GeneExpCleanOut")))
                                 ),
                                 tabPanel("Annotation",
                                          fluidPage(fluidRow(dataTableOutput("AnnoCleanOut")))
                                 )
                      ),

                      ##### Analysis Result Page: DEG Analysis #####
                      navbarMenu("DEG Analysis",
                                 tabPanel("DEG MTX",
                                          fluidPage(fluidRow(dataTableOutput("DEGMTX")))
                                 ),
                                 tabPanel("Volcano plot",
                                          fluidPage(fluidRow(plotOutput("VolcanoPlot")))
                                 )
                      ),

                      ##### Analysis Result Page: GSEA Analysis #####
                      navbarMenu("GSEA Analysis",
                                 tabPanel("Bar plot",
                                          fluidPage(plotOutput("GSEABarPlot",height = "800px", width = "1500px"))
                                 ),
                                 tabPanel("Dot plot",
                                          fluidPage(plotOutput("GSEADotPlot",height = "800px", width = "1000px"))
                                 ),
                                 tabPanel("UpSet Plot",
                                          fluidPage(plotOutput("UpSetPlot",height = "800px", width = "1500px"))
                                 ),
                                 tabPanel("Enrichment plot",
                                          fluidPage(plotOutput("GseaPlot",height = "1000px", width = "1500px"))
                                 ),
                                 tabPanel("Overlay Enrichment plot",
                                          fluidPage(plotOutput("OverlayGseaPlot",height = "600px", width = "800px"))
                                 ),
                                 # tabPanel("SentFreq Dimension Reduction",
                                 #          fluidPage(img(src = "Monocle3_UMAP.PNG",
                                 #                        height = "450px", width = "1700px", align = "center"), br())
                                 # )
                      ),
                      ##### Analysis Result Page: GO Analysis #####
                      navbarMenu("ORA Analysis",
                                 tabPanel("Bar plot",
                                          fluidPage(plotOutput("GOBarPlot",height = "800px", width = "1500px"))
                                 ),
                                 tabPanel("Dot plot",
                                          fluidPage(plotOutput("GODotPlot",height = "800px", width = "1000px"))
                                 ),
                                 tabPanel("Network plot",
                                          fluidPage(plotOutput("GONetworkPlot",height = "800px", width = "1000px"))
                                 ),
                                 tabPanel("Network plot2",
                                          fluidPage(plotOutput("GONetworkPlot2",height = "800px", width = "1000px"))
                                 ),
                                 tabPanel("UpSet Plot",
                                          fluidPage(plotOutput("GOUpSetPlot",height = "800px", width = "1500px"))
                                 )
                      )
                    )
                  ),
                  # style = "background-color: #DEEBF7",skin = "blue",
                  # tags$head(tags$style('.headerrow{height:8vh; background-color:#267dff}')),
                  tags$style(HTML("
                  .navbar-default .navbar-brand {color:white;}
                  .navbar-default .navbar-brand:hover {color:white;}
                  .navbar { background-color:#275682;}
                  .navbar-default .navbar-nav > li > a {color:white;}
                  .navbar-default .navbar-nav > .active > a,
                  .navbar-default .navbar-nav > .active > a:focus,
                  .navbar-default .navbar-nav > .active > a:hover {color:black;background-color:white;}
                  .navbar-default .navbar-nav > li > a:hover {color:white;background-color:#275682;text-decoration}
                  "))
         ),
#####*********** MultiGroup Enrichment Analysis ***********#####
         tabPanel("MultiGroup")
      ),
###############################################################################################################################################
         tabPanel("Custom Gene Sets"),
###############################################################################################################################################
         navbarMenu("Visualization",
                    tabPanel("From official GSEA results"),
                    tabPanel("From official Metascape results"),
                    tabPanel("From official GO results")
         ),
###############################################################################################################################################

         navbarMenu("About",
                    tabPanel("Summary"),
                    tabPanel("Tutorial"),
                    tabPanel("Citations"),
                    tabPanel("Release"),
                    tabPanel("Terms of Use"),
                    tabPanel("Contact")
                    )

###############################################################################################################################################

  )



