library(shiny)
library(shinyWidgets)

shinyUI(
  pageWithSidebar(
    headerPanel("Power of two log ratio statistics to observe differences between
                SEIR epidemic dynamics of treated and control communities, 
                where communities are high risk (high contact) environments."),
    sidebarPanel(
      radioButtons("radio", label = h4("Choice of log ratio statistic"),
                                  choices = list("log((I_treatment + 1) / (I_control + 1))" = 1, 
                                                 "log(((I + R)_treatment + 1) / ((I + R)_control + 1))" = 2), 
                                  selected = 1),
      
      shinyWidgets::sliderTextInput(inputId = "numberOfCommunities",
                                    label = h4("Number of communities (approx. 500 indivs within each community)"),
                                    choices = c(20, 40, 60, 80)),

      shinyWidgets::sliderTextInput(inputId = "numberRandomlySampled",
                                    label = h4("Number indivs randomly sampled from study population (if greater than study population, all indivs of study population sampled)"),
                                    choices = seq(5000, 40000, 1000)),

      shinyWidgets::sliderTextInput(inputId = "effectSize",
                                    label = h4("Effect size of treatment (%)"),
                                    choices = c(20, 40, 60)),
    
      shinyWidgets::sliderTextInput(inputId = "timeOfIntervention",
                                    label = h4("Time of intervention (day of intervention)"),
                                    choices = c(21)),
    
      shinyWidgets::sliderTextInput(inputId = "beta",
                                    label = h4("Beta (transmission rate of the epidemic)"),
                                    choices = c(0.04))),
    
    mainPanel(
      h4("Legend:"),
      h6("- Vertical solid purple line: day of treatment (transmission rate lowered among treatment communities)", style="color:purple"),
      h6("- Vertical dashed purple line: first day of possible follow-up (approx. 1 generation after treatment)", style="color:purple"),
      h6("- Orange lines: 100 simulations of prevalence among treated communities -- corresponds to LEFT y-axis", style="color:orange"),
      h6("- Grey lines: 100 simulations of prevalence among control communities -- corresponds to LEFT y-axis", style="color:grey"),
      h6("- Horizontal dashed blue line: 80% power threshold for the chosen log ratio statistic", style="color:blue"),
      h6("- Blue line: statistical power -- corresponds to RIGHT y-axis -- variance in (1) simulation (2) random sampling", style="color:blue"),

      imageOutput("log_ratio_plot")
    )
  )
)