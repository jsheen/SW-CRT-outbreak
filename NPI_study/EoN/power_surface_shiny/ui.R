library(shiny)
library(shinyWidgets)
library(plotly)

shinyUI(
  pageWithSidebar(
    headerPanel("Surface visualization"),
    sidebarPanel(
      radioButtons("radio_graph", label = h4("Choice of visualization"),
                   choices = list("3D surface plot" = 1, 
                                  "2D heat map" = 2), 
                   selected = 1),
      
      radioButtons("radio", label = h4("Choice of log ratio statistic"),
                                  choices = list("log((I_treatment + 1) / (I_control + 1))" = 1, 
                                                 "log(((I + R)_treatment + 1) / ((I + R)_control + 1))" = 2), 
                                  selected = 1),
      
      shinyWidgets::sliderTextInput(inputId = "timeOfFollowUp",
                                    label = h4("Time of follow-up"),
                                    choices = seq(32, 250)),
    
      shinyWidgets::sliderTextInput(inputId = "effectSize",
                                    label = h4("Effect size of treatment (%)"),
                                    choices = c(20, 40, 60)),
      
      shinyWidgets::sliderTextInput(inputId = "beta",
                                    label = h4("Beta (transmission rate of the epidemic)"),
                                    choices = c(0.02, 0.03, 0.04))),

    mainPanel(
      plotlyOutput("log_ratio_plot")
    )
  )
)