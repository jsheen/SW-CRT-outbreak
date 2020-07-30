library(shiny)
library(shinyWidgets)

shinyServer(
  function(input, output, session) {
    output$log_ratio_plot <- renderImage({
      
      plot_directory <- "~/SW-CRT-outbreak/NPI_study/EoN/code_output/log_ratios_plot/"
      
      n_comm <- input$numberOfCommunities
      n_win_comm <- input$numberWithinEachCommunity
      cluster_coverage <- input$clusterCoverage / 100
      effect_size <- input$effectSize / 100
      background_infections <- input$activeBackgroundInfections
      
      filename <- paste0(plot_directory, cluster_coverage, "_", n_comm, "_", 0.04, "_", effect_size, "_", n_win_comm, "_", background_infections, ".png")
      if (file.exists(filename)) {
        list(src=filename,
             width = 500,
             height = 400)
      } else {
        list()
        print('Plot not available.')
      }
    } , deleteFile = FALSE
    )
  }
)