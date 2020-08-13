library(shiny)
library(shinyWidgets)

shinyServer(
  function(input, output, session) {
    output$log_ratio_plot <- renderImage({
      
      plot_directory <- "/plots/"
      
      n_comm <- input$numberOfCommunities
      number_randomly_sampled <- input$numberRandomlySampled
      effect_size <- input$effectSize / 100
      time_of_intervention <- input$timeOfIntevention
      Beta <- input$beta
      
      if (input$radio == 1) {
        statistic <- "infection"
      } else {
        statistic <- "infection_recover"
      }
      
      filename <- paste0(plot_directory, "1_", n_comm, "_", Beta, "_", effect_size, "_" , number_randomly_sampled, "_500_", statistic, ".png")
      if (file.exists(filename)) {
        list(src=filename,
             width = 550,
             height = 500)
      } else {
        list()
        print('Plot not available.')
      }
    } , deleteFile = FALSE
    )
  }
)