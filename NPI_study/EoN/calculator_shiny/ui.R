library(DT)
library(shiny)
library(shinyWidgets)
library(plotly)

shinyUI(
  pageWithSidebar(
    headerPanel("NPI trial power calculator"),
    sidebarPanel(
      radioButtons("radio", label = h4("Choice of log ratio statistic"),
                                  choices = list("log((I_treatment + 1) / (I_control + 1))" = 1, 
                                                 "log(((I + R)_treatment + 1) / ((I + R)_control + 1))" = 2), 
                                  selected = 1),
      
      radioButtons("rank", label = h4("Rank best options based on:"),
                   choices = list("Cheapest" = 1, 
                                  "Earliest time to possibly sample" = 2,
                                  "Longest window" = 3), 
                   selected = 1),
      
      numericInput("cost_comm", "$ per individual of each enrolled community:", 1,
                   min = 1),
      
      numericInput("cost_sample", "$ per sampled individual of each enrolled community:", 1,
                   min = 1),
      
      numericInput("max_ncomm", "Maximum number of communities that can be enrolled", 80,
                   min = 1, max=80),
      
      numericInput("max_nsample_each_comm", "Maximum number of indivs sampled from each community", 40000,
                   min = 1, max=40000),
    
      shinyWidgets::sliderTextInput(inputId = "effectSize",
                                    label = h4("Effect size of treatment (%)"),
                                    choices = c(20, 40, 60)),
      
      shinyWidgets::sliderTextInput(inputId = "beta",
                                    label = h4("Beta (transmission rate of the epidemic)"),
                                    choices = c(0.02, 0.03, 0.04))),

    mainPanel(
      DT::dataTableOutput("mytable")
    )
  )
)