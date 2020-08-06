"
Created on Thu Jul 22 12:33:00 2020

@author: Justin

@description: a script to conduct a permutation test on a null distribution.

@input: .csvs of cluster level information. The naming convention of each result 
        cell is:
            (cluster_num)_(treated)_(size)_(num_enrolled)_(num_infected)

@output: permutation test results in a plot, pdf format
"

# Import libraries and set input and output folders ----------------------------
library(gtools)

input_folder <- "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/cluster_info/"
output_folder <- "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/permutation_test/"

# Input effects cluster info wanted for ----------------------------------------
effects <- list(c(1, 20, 0.04, 0, 500),
                c(1, 20, 0.04, 0.6, 500))

# Loop through each effect -----------------------------------------------------
for (effect in effects) {
  
  if (length(effect) == 6) {
    cluster_coverage <- effect[1]
    num_comm <- effect[2]
    beta <- effect[3]
    direct_NPIE <- effect[4]
    comm_size <- effect[5]
    background_effect <- effect[6]
    
    # Input .csv file of final statuses ------------------------------------------
    filename <- paste0(input_folder, cluster_coverage, "_", num_comm, "_", beta, "_", direct_NPIE, "_", comm_size, "_", background_effect, ".csv")
    df <- read.csv(filename, header=F, stringsAsFactors=FALSE)
  } else {
    cluster_coverage <- effect[1]
    num_comm <- effect[2]
    beta <- effect[3]
    direct_NPIE <- effect[4]
    comm_size <- effect[5]
    
    # Input .csv file of final statuses ------------------------------------------
    filename <- paste0(input_folder, cluster_coverage, "_", num_comm, "_", beta, "_", direct_NPIE, "_", comm_size, "_1_1", ".csv")
    df <- read.csv(filename, header=F, stringsAsFactors=FALSE)
  }
  
  true_log_ratio_statistics <- vector()
  log_ratio_statistics <- vector()
  # For each simulation --------------------------------------------------------
  for (sim in 1:nrow(df)) {
    # Create dataframe of treatment, size, outcome -----------------------------
    cluster_ls <- list()
    for (cluster_num in 1:(ncol(df) - 1)) {
      split_vec <- strsplit(df[sim, cluster_num], "_")[[1]]
      to_add <- data.frame(matrix(NA, ncol=3, nrow=1))
      to_add[1,1] <- as.numeric(split_vec[2])
      to_add[1,2] <- as.numeric(split_vec[3])
      to_add[1,3] <- as.numeric(split_vec[5])
      cluster_ls[[cluster_num]] <- to_add
    }
    cluster_df <- do.call(rbind, cluster_ls)
    colnames(cluster_df) <- c("treated", "size", "infected")
    
    # Calculate *true* log ratio statistic -------------------------------------
    true_num_infect_treatment <- sum(cluster_df$infected[which(cluster_df$treated == 1)])
    true_num_infect_control <- sum(cluster_df$infected[which(cluster_df$treated == 0)])
    
    true_log_ratio_statistic <- log((true_num_infect_treatment + 1) / (true_num_infect_control + 1))
    true_log_ratio_statistics <- c(true_log_ratio_statistics, true_log_ratio_statistic)
    
    # Mix up the cluster labels ten times --------------------------------------
    for (permutation_dex in 1:10) {
      # Randomly permute -------------------------------------------------------
      assignment_init <- c(rep(1, num_comm / 2), rep(0, num_comm / 2))
      cluster_df$treated <- permute(assignment_init)
      
      # Calculate log ratio statistic ------------------------------------------
      num_infect_treatment <- sum(cluster_df$infected[which(cluster_df$treated == 1)])
      num_infect_control <- sum(cluster_df$infected[which(cluster_df$treated == 0)])
      
      log_ratio_statistic <- log((num_infect_treatment + 1) / (num_infect_control + 1))
      log_ratio_statistics <- c(log_ratio_statistics, log_ratio_statistic)
    }
  }
  
  if (length(effect) == 6) {
    # Plot results ---------------------------------------------------------------
    pdf(file=paste0(output_folder, cluster_coverage, "_", num_comm, "_", beta, "_", direct_NPIE, "_", comm_size, "_", background_effect, ".pdf"),width=10, height=5)
    par(mfrow=c(1,2))
    hist(true_log_ratio_statistics)
    hist(log_ratio_statistics)
    dev.off()
    
    # Write .csvs of the data ----------------------------------------------------
    filename <- file.path(paste0(output_folder, cluster_coverage, "_", num_comm, "_", beta, "_", direct_NPIE, "_", comm_size, "_", background_effect, ".csv"))
    write.table(log_ratio_statistics, filename, row.names = F)
  } else {
    # Plot results ---------------------------------------------------------------
    pdf(file=paste0(output_folder, cluster_coverage, "_", num_comm, "_", beta, "_", direct_NPIE, "_", comm_size, "_1_1", ".pdf"),width=10, height=5)
    par(mfrow=c(1,2))
    hist(true_log_ratio_statistics)
    hist(log_ratio_statistics)
    dev.off()
    
    # Write .csvs of the data ----------------------------------------------------
    filename <- file.path(paste0(output_folder, cluster_coverage, "_", num_comm, "_", beta, "_", direct_NPIE, "_", comm_size, "_1_1", ".csv"))
    write.table(log_ratio_statistics, filename, row.names = F)
  }

}


