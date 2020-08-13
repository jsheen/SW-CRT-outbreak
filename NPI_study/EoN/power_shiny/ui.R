library(shiny)
library(shinyWidgets)

shinyUI(
  pageWithSidebar(
    headerPanel("Power of a log ratio statistic to find differences between
                treated and control communities fairly early and for a short
                observation period (i.e. time from treatment to follow-up) during
                an epidemic, where communities are high risk (i.e. high contact) in
                a SEIR network model."),
    sidebarPanel(
      
      shinyWidgets::sliderTextInput(inputId = "numberOfCommunities",
                                    label = "Number of communities",
                                    choices = c(20, 40, 60, 80)),

      shinyWidgets::sliderTextInput(inputId = "numberRandomlySampled",
                                    label = "Number randomly sampled from study population",
                                    choices = seq(1000, 40000, 1000)),

      shinyWidgets::sliderTextInput(inputId = "effectSize",
                                    label = "Effect size (%)",
                                    choices = c(20, 40, 60)),
    
      shinyWidgets::sliderTextInput(inputId = "timeOfIntervention",
                                    label = "Time of intervention (day)",
                                    choices = c(21))),
    
    mainPanel(
      imageOutput("log_ratio_plot"),
      textOutput("text1")
    )
  )
)