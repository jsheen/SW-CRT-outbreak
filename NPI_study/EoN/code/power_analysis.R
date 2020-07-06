# Import libraries  ------------------------------------------------------------

# Load all combinations of effect sizes to find power --------------------------
effects <- list(list(0.5, 100, 0.04, 0.95),
                list(0.9, 40, 0.04, 0.95))

# Algorithm for each effect:
# 1. For each effect:
#     1a. Create null distribution
#     1b. Create effect distribution
#     1c. Find 5% p-value point of null distribution
#     1d. Find power of effect less than point found in 1c.
#     1e. Plot two overlapping distributions with power value
# 2. Output all power calculations in csv -------------------------------------
for (effect in effects) {
  cluster_coverage <- effect[[1]]
  num_comm <- effect[[2]]
  beta <- effect[[3]]
  direct_NPIE <- effect[[4]]
  
  # Read in 500 simulations of null distribution -------------------------------
  filename <- paste0("~/SW-CRT-outbreak/NPI_study/EoN/code_output/csvs/",
                     cluster_coverage, "_", num_comm, "_", beta, "_", 0, "/batch_res.csv")
  null_dist <- read.csv(filename, fill = TRUE, header = FALSE, stringsAsFactors = F)
  
  # Find log ratio per simulation ----------------------------------------------
  log_ratio_null <- vector()
  last_null_numerator <- 0
  last_null_denominator <- 0
  for (sim_num in 1:nrow(null_dist)) {
    print(sim_num)
    if (!grepl("_", null_dist[sim_num,1])) {
      last_null_numerator <- 0
      last_null_denominator <- 0
      for (node_num in 2:ncol(null_dist)) {
        if (null_dist[sim_num,node_num] != "") {
          node_res <- strsplit(null_dist[sim_num,node_num], "_")[[1]]
          if (node_res[4] == "1" & (node_res[5] == "E" | node_res[5] == "I")) {
            if (node_res[3] == "1") {
              last_null_numerator <- last_null_numerator + 1
            } else {
              last_null_denominator <- last_null_denominator + 1
            }
          }
        }
      }
      # Add log ratio ----------------------------------------------------------
      log_ratio <- log((last_null_numerator + 1) / (last_null_denominator + 1))
      log_ratio_null <- c(log_ratio_null, log_ratio)
    } else {
      extra_node_dex <- 1
      extra_node <- null_dist[sim_num, extra_node_dex]
      while (extra_node != "") {
        node_res <- strsplit(null_dist[sim_num, extra_node_dex], "_")[[1]]
        if (node_res[4] == "1" & (node_res[5] == "E" | node_res[5] == "I")) {
          if (node_res[3] == "1") {
            last_null_numerator <- last_null_numerator + 1
          } else {
            last_null_denominator <- last_null_denominator + 1
          }
        }
        extra_node_dex <- extra_node_dex + 1
        extra_node <- null_dist[sim_num, extra_node_dex]
      }
      
      # Update last element of vector ------------------------------------------
      log_ratio_null <- head(log_ratio_null, -1)
      new_log_ratio <- log((last_null_numerator + 1) / (last_null_denominator + 1))
      log_ratio_null <- c(log_ratio_null, new_log_ratio)
    }
  }
  write.csv(log_ratio_null, paste0("~/SW-CRT-outbreak/NPI_study/EoN/code_output/log_ratios/",
                                    cluster_coverage, "_", num_comm, "_", beta, "_", 0, ".csv"))
  
  # Read in 500 simulations of effect distribution -----------------------------
  filename <- paste0("~/SW-CRT-outbreak/NPI_study/EoN/code_output/csvs/",
                     cluster_coverage, "_", num_comm, "_", beta, "_", direct_NPIE, "/batch_res.csv")
  effect_dist <- read.csv(filename, fill = TRUE, header = FALSE, stringsAsFactors = F)
  
  # Find log ratio per simulation ----------------------------------------------
  log_ratio_effect <- vector()
  last_effect_numerator <- 0
  last_effect_denominator <- 0
  for (sim_num in 1:nrow(effect_dist)) {
    print(sim_num)
    if (!grepl("_", effect_dist[sim_num,1])) {
      last_effect_numerator <- 0
      last_effect_denominator <- 0
      for (node_num in 2:ncol(effect_dist)) {
        if (null_dist[sim_num,node_num] != "") {
          node_res <- strsplit(effect_dist[sim_num,node_num], "_")[[1]]
          if (node_res[4] == "1" & (node_res[5] == "E" | node_res[5] == "I")) {
            if (node_res[3] == "1") {
              last_effect_numerator <- last_effect_numerator + 1
            } else {
              last_effect_denominator <- last_effect_denominator + 1
            }
          }
        }
      }
      # Add log ratio ----------------------------------------------------------
      log_ratio <- log((last_effect_numerator + 1) / (last_effect_denominator + 1))
      log_ratio_effect <- c(log_ratio_effect, log_ratio)
    } else {
      extra_node_dex <- 1
      extra_node <- effect_dist[sim_num, extra_node_dex]
      while (extra_node != "") {
        node_res <- strsplit(effect_dist[sim_num, extra_node_dex], "_")[[1]]
        if (node_res[4] == "1" & (node_res[5] == "E" | node_res[5] == "I")) {
          if (node_res[3] == "1") {
            last_effect_numerator <- last_effect_numerator + 1
          } else {
            last_effect_denominator <- last_effect_denominator + 1
          }
        }
        extra_node_dex <- extra_node_dex + 1
        extra_node <- effect_dist[sim_num, extra_node_dex]
      }
      
      # Update last element of vector ------------------------------------------
      log_ratio_effect <- head(log_ratio_effect, -1)
      new_log_ratio <- log((last_effect_numerator + 1) / (last_effect_denominator + 1))
      log_ratio_effect <- c(log_ratio_effect, new_log_ratio)
    }
  }
  
  write.csv(log_ratio_effect, paste0("~/SW-CRT-outbreak/NPI_study/EoN/code_output/log_ratios/",
                                     cluster_coverage, "_", num_comm, "_", beta, "_", direct_NPIE, ".csv"))
  
  # Find power -----------------------------------------------------------------
  log_ratio_null <- sort(log_ratio_null)
  p_val <- log_ratio_null[ceiling(0.05 * 500)]
  log_ratio_effect <- sort(log_ratio_effect)
  num_below <- min(which(log_ratio_effect > p_val))
  power = (num_below / 500) * 100
  print(power)
  
  # Plot -----------------------------------------------------------------------
  null_hist <- hist(log_ratio_null, plot=F, breaks=20)
  effect_hist <- hist(log_ratio_effect, plot=F, breaks=10)
  plot(effect_hist, col = rgb(173,216,230, max = 255, alpha = 80, names = "lt.blue"),
       main="", xlab="ln((infections_two_weeks_treatment + 1) / (infections_two_weels_control + 1))",
       xlim=c(min(c(log_ratio_null, log_ratio_effect)), max(c(log_ratio_null, log_ratio_effect))))
  plot(null_hist, col = rgb(255,192,203, max = 255, alpha = 80, names = "lt.pink"),
       add = TRUE)
}

