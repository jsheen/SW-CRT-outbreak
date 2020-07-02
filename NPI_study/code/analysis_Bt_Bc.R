# Script to analyze simulations for effect of NPI ------------------------------

# Load parameter combinations to compare ---------------------------------------
comparisons <- list(list(c(0.5, 40, 0.04, 0.6), c(0.5, 40, 0.04, 0)),
                    list(c(0.5, 40, 0.04, 0.95), c(0.5, 40, 0.04, 0)),
                    list(c(0.5, 40, 0.02, 0.6), c(0.5, 40, 0.04, 0)),
                    list(c(0.5, 100, 0.04, 0.95), c(0.5, 100, 0.04, 0)),
                    list(c(0.9, 40, 0.04, 0.6), c(0.9, 40, 0.04, 0)))

# Function to create a distribution of new infections every two weeks ----------
create_two_week_distribution <- function(param_vec) {
  propRecruit <- param_vec[1]
  ncomm <- param_vec[2]
  true_beta <- param_vec[3]
  true_effect_size <- param_vec[4]
  
  two_week_dist <- data.frame(matrix(NA, ncol=18, nrow=100))
  colnames(two_week_dist) <- c(seq(56, 294, by=14))
  begin_day <- 56
  end_day <- 56 + 13
  col_dex <- 1
  while (end_day < 308) {
    for (sim_num in 1:100) {
      # Read in simulation .csv ------------------------------------------------
      sim <- read.csv(paste0("~/SW-CRT-outbreak/NPI_study/code_output/csvs/",
                             propRecruit, "_", ncomm, "_", true_beta, "_", true_effect_size, 
                             "/", sim_num, ".csv"))
      sim <- data.frame(lapply(sim, as.character), stringsAsFactors=FALSE)
      sim$DayInfected <- as.numeric(sim$DayInfected)
      sim$TrialStatus <- as.numeric(sim$TrialStatus)
      
      # Calculate the log ratio of new infections in the treatment vs. control -
      I_t_plus_one_treatment <- length(which(sim$DayInfected <= end_day &
                                               sim$DayInfected >= begin_day &
                                               sim$TrialStatus == 1))
      I_t_plus_one_control <- length(which(sim$DayInfected <= end_day &
                                             sim$DayInfected >= begin_day &
                                             sim$TrialStatus == 0))
      log_ratio_result <- log((I_t_plus_one_treatment + 1) / (I_t_plus_one_control + 1))
      
      # Plug in result to the two_week_dist dataframe --------------------------
      two_week_dist[sim_num, col_dex] <- log_ratio_result
    }
    begin_day <- begin_day + 14
    end_day <- end_day + 14
    col_dex <- col_dex + 1
  }
  
  return(two_week_dist)
}

# Look at log(B_T / B_C) statistic ---------------------------------------------
for (compare_dex in 1:length(comparisons)) {
  print(paste0("Param set: ", comparisons[[compare_dex]][[1]]))
  effect_dist <- create_two_week_distribution(comparisons[[compare_dex]][[1]])
  null_dist <- create_two_week_distribution(comparisons[[compare_dex]][[2]])
  
  propRecruit <- comparisons[[compare_dex]][[1]][1]
  ncomm <- comparisons[[compare_dex]][[1]][2]
  true_beta <- comparisons[[compare_dex]][[1]][3]
  true_effect_size <- comparisons[[compare_dex]][[1]][4]
  
  # Create histograms of the two week time periods comparing the null dist. to
  # the effect distribution ----------------------------------------------------
  pdf(file=paste0("~/SW-CRT-outbreak/NPI_study/code_output/plots/two_weeks/",
                  propRecruit, "_", ncomm, "_", true_beta, "_", true_effect_size, ".pdf"),
      width=5, height=5)
  for (col_num in 1:ncol(null_dist)) {
    if (!all(is.na(null_dist[,col_num])) & !all(is.na(effect_dist[,col_num]))) {
      null_hist <- hist(null_dist[,col_num], plot=F, breaks=10)
      effect_hist <- hist(effect_dist[,col_num], plot=F, breaks=10)
      plot(effect_hist, col = rgb(173,216,230, max = 255, alpha = 80, names = "lt.blue"),
           main=paste0("begin_day: ", colnames(null_dist)[col_num], "; end_day: ", as.numeric(colnames(null_dist)[col_num]) + 13),
           xlim=c(-6, 6))
      plot(null_hist, col = rgb(255,192,203, max = 255, alpha = 80, names = "lt.pink"),
           add = TRUE)
    }
  }
  dev.off()
  
  # Create histograms of the entire epidemic -----------------------------------
  pdf(file=paste0("~/SW-CRT-outbreak/NPI_study/code_output/plots/full/",
                  propRecruit, "_", ncomm, "_", true_beta, "_", true_effect_size, ".pdf"),
      width=5, height=5)
  null_hist <- hist(unlist(null_dist), plot=F, breaks=10)
  effect_hist <- hist(unlist(effect_dist), plot=F, breaks=10)
  plot(effect_hist, col = rgb(173,216,230, max = 255, alpha = 80, names = "lt.blue"),
       main="", xlab="ln((I_(t+1, Treatment) + 1) / (I_(t+1, Control) + 1))",
       xlim=c(-6, 6))
  plot(null_hist, col = rgb(255,192,203, max = 255, alpha = 80, names = "lt.pink"),
       add = TRUE)
  legend("topright", 
         c(paste0("Treat. eff.=", true_effect_size), "Treat. eff.=0.0"),
         lty=c(1, 1),
         col=c(rgb(173,216,230, max = 255, alpha = 80, names = "lt.blue"),
               rgb(255,192,203, max = 255, alpha = 80, names = "lt.pink")), 
         text.width=2,
         cex=0.4,
         pch=19)
  dev.off()
  
  # TODO: Power calculation ----------------------------------------------------
}

# Compare log final size ratio distributions -----------------------------------
create_log_ratio_final_size_distribution <- function(param_vec) {
  propRecruit <- param_vec[1]
  ncomm <- param_vec[2]
  true_beta <- param_vec[3]
  true_effect_size <- param_vec[4]
  
  ratio_final_size_distribution <- vector()
  for (sim_num in 1:100) {
    # Read in simulation .csv --------------------------------------------------
    sim <- read.csv(paste0("~/SW-CRT-outbreak/NPI_study/code_output/csvs/",
                           propRecruit, "_", ncomm, "_", true_beta, "_", true_effect_size, 
                           "/", sim_num, ".csv"))
    sim <- data.frame(lapply(sim, as.character), stringsAsFactors=FALSE)
    sim$TrialStatus <- as.numeric(sim$TrialStatus)
    
    # Calculate the log ratio of new infections in the treatment vs. control ---
    final_size_treatment <- length(which(sim$TrialStatus == 1))
    final_size_control <- length(which(sim$TrialStatus == 0))
    log_ratio_result <- log(final_size_treatment / final_size_control)
    ratio_final_size_distribution <- c(ratio_final_size_distribution, log_ratio_result)
  }
  
  return(ratio_final_size_distribution)
}

# Loop to compare final sizes --------------------------------------------------
for (compare_dex in 1:length(comparisons)) {
  print(paste0("Effect: ", comparisons[[compare_dex]][[1]]))
  effect_dist <- create_log_ratio_final_size_distribution (comparisons[[compare_dex]][[1]])
  null_dist <- create_log_ratio_final_size_distribution (comparisons[[compare_dex]][[2]])
  
  propRecruit <- comparisons[[compare_dex]][[1]][1]
  ncomm <- comparisons[[compare_dex]][[1]][2]
  true_beta <- comparisons[[compare_dex]][[1]][3]
  true_effect_size <- comparisons[[compare_dex]][[1]][4]
  
  pdf(file=paste0("~/SW-CRT-outbreak/NPI_study/code_output/plots/final_size/",
                  propRecruit, "_", ncomm, "_", true_beta, "_", true_effect_size, ".pdf"),
      width=5, height=5)
  null_hist <- hist(null_dist, plot=F)
  effect_hist <- hist(effect_dist, plot=F)
  plot(effect_hist, col = rgb(173,216,230, max = 255, alpha = 80, names = "lt.blue"),
       main="", xlab="ln(final_size_treatment / final_size_control)", 
       xlim=c(min(c(null_dist, effect_dist)), max(c(null_dist, effect_dist))))
  plot(null_hist, col = rgb(255,192,203, max = 255, alpha = 80, names = "lt.pink"),
       add = TRUE)
  legend("topright", 
         c(paste0("Treat. eff.=", true_effect_size), "Treat. eff.=0.0"),
         lty=c(1, 1),
         col=c(rgb(173,216,230, max = 255, alpha = 80, names = "lt.blue"),
               rgb(255,192,203, max = 255, alpha = 80, names = "lt.pink")), 
         text.width=2,
         cex=0.4,
         pch=19)
  dev.off()
}

