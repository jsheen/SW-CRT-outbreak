library(shiny)
library(shinyWidgets)

shinyUI(
  pageWithSidebar(
    headerPanel("Statistical power for a non-pharmaceutical intervention (NPI) cluster-randomized trial"),
    sidebarPanel(
      
      shinyWidgets::sliderTextInput(inputId = "numberOfCommunities",
                                    label = "Number of communities",
                                    choices = c(40, 70)),

      shinyWidgets::sliderTextInput(inputId = "numberWithinEachCommunity",
                                    label = "Number within each community",
                                    choices = c(100)),

      shinyWidgets::sliderTextInput(inputId = "clusterCoverage",
                                    label = "Cluster coverage",
                                    choices = c(50, 70, 90)),

      shinyWidgets::sliderTextInput(inputId = "effectSize",
                                    label = "Effect size",
                                    choices = c(80)),
    
      shinyWidgets::sliderTextInput(inputId = "activeBackgroundInfections",
                                    label = "Active background infections",
                                    choices = c(100, 500))),
      
      # To be implemented in the future ----------------------------------------
      # shinyWidgets::sliderTextInput(inputId = "Observation sample size", 
      #                               label = "Observation sample size", 
      #                               choices = c(4000, 7000, 10000)),
    
    mainPanel(
      imageOutput("log_ratio_plot")
    )
  )
)