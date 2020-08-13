library(shiny)
library(shinyWidgets)

shinyServer(
  function(input, output, session) {
    output$log_ratio_plot <- renderImage({
      
      plot_directory <- "~/SW-CRT-outbreak/NPI_study/EoN/code_output/power_shiny_data/plots/"
      
      n_comm <- input$numberOfCommunities
      number_randomly_sampled <- input$numberRandomlySampled
      effect_size <- input$effectSize / 100
      time_of_intervention <- input$timeOfIntevention
      
      filename <- paste0(plot_directory, "1_", n_comm, "_0.04_", effect_size, "_" , number_randomly_sampled, "_500_infection", ".png")
      if (file.exists(filename)) {
        list(src=filename,
             width = 600,
             height = 500)
      } else {
        list()
        print('Plot not available.')
      }
    } , deleteFile = FALSE
    )
  }
)