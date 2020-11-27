library(DT)
library(shiny)
library(shinyWidgets)
library(plotly)

shinyServer(
  function(input, output, session) {
    
    output$mytable = DT::renderDataTable({
      
      #plot_directory <- "~/SW-CRT-outbreak/NPI_study/EoN/calculator_shiny/csvs/"
      plot_directory <- "csvs/"
      cost_comm <- input$cost_comm
      cost_sample <- input$cost_sample
      effect <- input$effectSize / 100
      beta <- input$beta
      
      if (input$radio == 1) {
        statistic <- "infect"
      } else {
        statistic <- "infect_recover"
      }
      
      ncomms <- c(20, 40, 60, 80)
      ncomm_res_ls <- list()
      ncomm_res_ls_dex <- 1
      for (ncomm in ncomms) {
        filename <- paste0("1_", ncomm, "_", beta, "_", effect, "_500_", statistic, "_res.csv")
        file_power <- read.csv(paste0(plot_directory, filename), stringsAsFactors = F, header = F)
        file_power <- file_power[,1:(ncol(file_power) - 1)]
        
        # Cut off after day 250 + 31 -------------------------------------------
        file_power <- file_power[1:220,]
        
        for (sampled_dex in 2:ncol(file_power)) {
          sampled <- file_power[,sampled_dex]
          to_return_db_inner <- data.frame(matrix(ncol=6, nrow=1))
          colnames(to_return_db_inner) <- c("ncomm", "nsample", "nsample_each_comm", "window_begin", "window_end", "length_window")
          to_return_db_inner$ncomm[1] <- ncomm
          to_return_db_inner$nsample[1] <- sampled[1]
          to_return_db_inner$nsample_each_comm <- round(to_return_db_inner$nsample / to_return_db_inner$ncomm)
          
          sampled_subset <- sampled[2:length(sampled)]
          first <- which(sampled_subset >= 0.8)[1]
          if (!is.na(first)) {
            to_return_db_inner$window_begin <- first
            last <- which(sampled_subset >= 0.8)[length(which(sampled_subset >= 0.8))]
            to_return_db_inner$window_end <- last
            to_return_db_inner$length_window <- last - first + 1
          }
          
          ncomm_res_ls[[ncomm_res_ls_dex]] <- to_return_db_inner
          ncomm_res_ls_dex <- ncomm_res_ls_dex + 1
        }
      }
      ncomm_res <- do.call(rbind, ncomm_res_ls)
      
      # Get rid of duplicate rows ----------------------------------------------
      ncomm_res$temp <- ncomm_res$ncomm * 500
      ncomm_res <- ncomm_res[-which(ncomm_res$nsample > ncomm_res$temp),]
      ncomm_res$temp <- NULL
      
      # Put a "cost" column ----------------------------------------------------
      ncomm_res$cost <- (ncomm_res$ncomm * cost_comm * 500) + (ncomm_res$nsample * cost_sample)
      
      # Rank based on user input -----------------------------------------------
      if (input$rank == 1) {
        ncomm_res <- ncomm_res[order(ncomm_res$cost),]
      } else if (input$rank == 2) {
        ncomm_res <- ncomm_res[order(ncomm_res$window_begin),]
      } else {
        ncomm_res <- ncomm_res[order(-ncomm_res$length_window),]
      }
      
      # Put all NA at bottom ---------------------------------------------------
      which_na <- which(is.na(ncomm_res$window_begin))
      ncomm_res <- ncomm_res[-which_na,]
      
      # Get rid of those that are above maximum --------------------------------
      ncomm_res <- ncomm_res[which(ncomm_res$ncomm <= input$max_ncomm),]
      ncomm_res <- ncomm_res[which(ncomm_res$nsample_each_comm <= input$max_nsample_each_comm),]
      
      colnames(ncomm_res) <- c("# communities (500 indivs each)", 
                               "# indivs sampled for entire trial",
                               "# indivs sampled from each community (500 indivs each)",
                               "1st day after treatment with 80% power",
                               "Last day after treatment with 80% power",
                               "# days with 80% power (i.e. window)",
                               "Cost ($)"
                               )
      rownames(ncomm_res) <- NULL
      
      ncomm_res
    })
  }
)