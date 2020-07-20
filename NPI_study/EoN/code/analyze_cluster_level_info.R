"
Created on Thu Jul 16 17:50:16 2020

@author: Justin

@description: a script to analyze cluster level information of NPI trial.

@input: .csvs of cluster level information. The naming convention of each result 
        cell is:
            (cluster_num)_(treated)_(size)_(num_enrolled)_(num_infected)

@output: results of Wilcoxon-signed rank test on paired difference of pairs of
         clusters matched based on cluster size. Rosenbaum sensitivity bounds
         also reported.
"

# Import libraries and set input and output folders ----------------------------
library(optmatch)
library(rbounds)

input_folder <- "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/cluster_info/"
output_folder <- "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/cluster_info_analysis/"

# Input effects cluster info wanted for ----------------------------------------
effects <- list(c(0.5, 70, 0.04, 0.6, 100, 500))

# Loop through each effect -----------------------------------------------------
for (effect in effects) {
  cluster_coverage <- effect[1]
  num_comm <- effect[2]
  beta <- effect[3]
  direct_NPIE <- effect[4]
  comm_size <- effect[5]
  background_effect <- effect[6]
  
  # Input .csv file of final statuses ------------------------------------------
  filename <- paste0(input_folder, cluster_coverage, "_", num_comm, "_", beta, "_", direct_NPIE, "_", comm_size, "_", background_effect, ".csv")
  df <- read.csv(filename, header=F, stringsAsFactors=FALSE)
  
  # For each simulation --------------------------------------------------------
  success <- 0
  gammas <- vector()
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
    
    # Optimally match ----------------------------------------------------------
    matched_ls <- list()
    matched_ls_dex <- 1
    paired_dexs <- pairmatch(treated ~ size, data = cluster_df)
    for (pair_dist in paired_dexs) {
      pair <- names(paired_dexs[which(paired_dexs == pair_dist)])
      partner_1 <- as.numeric(pair[1])
      partner_2 <- as.numeric(pair[2])
      
      to_add <- data.frame(matrix(NA, ncol=2, nrow=1))
      colnames(to_add) <- c("treatment", "control")
      if (cluster_df$treated[partner_1] == 1) {
        to_add$treatment[1] <- cluster_df$infected[partner_1]
        to_add$control[1] <- cluster_df$infected[partner_2]
      } else {
        to_add$treatment[1] <- cluster_df$infected[partner_2]
        to_add$control[1] <- cluster_df$infected[partner_1]
      }
      matched_ls[[matched_ls_dex]] <- to_add
      matched_ls_dex <- matched_ls_dex + 1
    }
    matched_df <- do.call(rbind, matched_ls)
    
    # Perform Wilcoxon-signed rank test and sensitivity analysis ---------------
    psens_res <- psens(y=matched_df$treatment, x=matched_df$control, Gamma=4, GammaInc=0.1)
    
    # Check if statistically significant ---------------------------------------
    if (!is.na(psens_res$bounds$`Lower bound`[1]) & psens_res$bounds$`Lower bound`[1] < 0.05) {
      success <- success + 1
      
      # Find gamma value -------------------------------------------------------
      gamma_not_found <- T
      counter <- 1
      while (gamma_not_found & !is.na(psens_res$bounds$`Gamma`[counter])) {
        if (psens_res$bounds$`Upper bound`[counter] > 0.05) {
          gamma_not_found <- F
        }
        counter <- counter + 1
      }
      gamma <- ifelse(is.na(psens_res$bounds$`Gamma`[counter]), 4, psens_res$bounds$`Gamma`[counter])
      gammas <- c(gammas, gamma)
    }
  }
  
  # Write results --------------------------------------------------------------
  o1 <- "Effect: (cluster_coverage)_(num_comm)_(beta)_(direct_NPIE)_(comm_size)_(background_effect)"
  o2 <- effect
  o3 <- "Success: number of statistically significant results out of 500 simulations."
  o4 <- success / 500
  o5 <- "Mean gamma value of the Rosenbaum sensitivity analysis: "
  o6 <- mean(gammas)
  outputResult<-list(o1, o2, o3, o4, o5, o6)
  filename <- file.path(paste0(output_folder, cluster_coverage, "_", num_comm, "_", beta, "_", direct_NPIE, "_", comm_size, "_", background_effect, ".txt"))
  capture.output(outputResult, file = filename)
}


