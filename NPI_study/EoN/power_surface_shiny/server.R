library(shiny)
library(shinyWidgets)
library(plotly)

shinyServer(
  function(input, output, session) {
    output$log_ratio_plot <- renderPlotly({
      
      plot_directory <- "csvs/"
      
      effect <- input$effectSize / 100
      day <- input$timeOfFollowUp
      beta <- input$beta
      
      if (input$radio == 1) {
        statistic <- "infect"
      } else {
        statistic <- "infect_recover"
      }
      
      if (input$radio_graph == 1) {
        graph <- "surface"
      } else {
        graph <- "heat"
      }
      
      ncomms <- c(20, 40, 60, 80)
      ncomm_res_ls <- list()
      ncomm_res_ls_dex <- 1
      for (ncomm in ncomms) {
        filename <- paste0("1_", ncomm, "_", beta, "_", effect, "_500_", statistic, "_res.csv")
        file_power <- read.csv(paste0(plot_directory, filename), stringsAsFactors = F, header = F)
        file_power <- file_power[,1:(ncol(file_power) - 1)]
        sample_axis <- file_power[which(file_power$V1 == as.character(day)),]
        sample_axis <- sample_axis[,2:ncol(sample_axis)]
        colnames(sample_axis) <- seq(1000, 40000, 1000)
        ncomm_res_ls[[ncomm_res_ls_dex]] <- sample_axis
        ncomm_res_ls_dex <- ncomm_res_ls_dex + 1
      }
      ncomm_res <- do.call(rbind, ncomm_res_ls)
      rownames(ncomm_res) <- ncomms
      ncomm_res <- sapply(ncomm_res, function (x) as.numeric(x))
      
      if (graph == "surface") {
        axx <- list(
          nticks = 10,
          range = c(1000, 40000),
          title = "N sampled",
          autorange="reversed"
        )
        
        axy <- list(
          nticks = 4,
          range = c(20, 80),
          title = "N comms",
          autorange="reversed"
        )
        
        axz <- list(
          nticks = 10,
          range = c(0, 1),
          title = "Power"
        )
        fig <- plot_ly(x = ~seq(1000, 40000, 1000), y = ~ncomms, z = ~ncomm_res, zmin=0, zmax=1)
        fig <- fig %>% add_surface(colorbar=list(title='Power'))
        camera = list(eye = list(x=1.75, y=1.75, z = 1.75))
        fig <- fig %>% layout(scene = list(xaxis=axx, yaxis=axy, zaxis=axz, camera=camera))
        fig <- fig %>% layout(title = paste0("Days after treatment: ", day - 21))
      } else {
        axx <- list(
          title = "N sampled"
        )
        
        axy <- list(
          title = "N comms"
        )
        fig <- plot_ly(x = ~seq(1000, 40000, 1000), y = ~ncomms, z = ~ncomm_res, 
                       type="heatmap", colorbar = list(title = "Power"),
                       zmin=0, zmax=1)
        fig <- fig %>% layout(xaxis=axx, yaxis=axy)
        fig <- fig %>% layout(title = paste0("Days after treatment: ", day - 21))
      }

      fig
    }
    )
  }
)