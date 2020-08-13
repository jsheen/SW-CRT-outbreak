"
Created on Wed Aug 12 12:00:00 2020

@author: Justin

@description: a script to create .pngs for the shiny app

@input: .csvs of prevalence information.

@output: .pngs of the prevalence information
"

# Import libraries and set input and output folders ---------------------------
input_folder <- "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/power_shiny_data/csvs/"
output_folder <- "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/power_shiny_data/plots/"

ncomms <- c(20, 40, 60, 80)
effects <- c(0.2, 0.4, 0.6)

for (ncomm in ncomms) {
  for (effect in effects) {
    print(paste0("ncomm: ", ncomm))
    print(paste0("effect: ", effect))
    
    filename_infect_res <- paste0(input_folder, "1_", ncomm, "_0.04_", effect, "_500_infect_res.csv")
    filename_infect_recover_res <- paste0(input_folder, "1_", ncomm, "_0.04_", effect, "_500_infect_recover_res.csv")
    filename_I_control_traj <- paste0(input_folder, "1_", ncomm, "_0.04_", effect, "_500_infect_recover_traj_I_control.csv")
    filename_I_treatment_traj <- paste0(input_folder, "1_", ncomm, "_0.04_", effect, "_500_infect_recover_traj_I_treatment.csv")
    filename_R_control_traj <- paste0(input_folder, "1_", ncomm, "_0.04_", effect, "_500_infect_recover_traj_R_control.csv")
    filename_R_treatment_traj <- paste0(input_folder, "1_", ncomm, "_0.04_", effect, "_500_infect_recover_traj_R_treatment.csv")
    
    infect_res <- read.csv(filename_infect_res, header=T, stringsAsFactors=FALSE)
    infect_recover_res <- read.csv(filename_infect_recover_res, header=T, stringsAsFactors=FALSE)
    I_control_traj <- read.csv(filename_I_control_traj, header=F, stringsAsFactors=FALSE)
    I_treatment_traj <- read.csv(filename_I_treatment_traj, header=F, stringsAsFactors=FALSE)
    R_control_traj <- read.csv(filename_R_control_traj, header=F, stringsAsFactors=FALSE)
    R_treatment_traj <- read.csv(filename_R_treatment_traj, header=F, stringsAsFactors=FALSE)
    
    sample_sizes <- seq(1000, 41000, 1000)
    for (sample_size_dex in 1:40) {
      print(paste0("sample_size: ", sample_sizes[sample_size_dex]))
      
      # Save the .png of the infection log ratio statistic ---------------------
      png(paste0(output_folder, "1_", ncomm, "_0.04_", effect, "_", sample_sizes[sample_size_dex], "_500_infection.png"), width=700, height=600)
      par(mar=c(5, 4, 4, 6) + 0.1)
      
      # First do preprocessing to get rid of rows that are continuations of previous rows
      I_control_traj <- I_control_traj[which(!is.na(I_control_traj[,80]) & I_control_traj[,80] > 10),]
      I_treatment_traj <- I_treatment_traj[which(!is.na(I_treatment_traj[,80])  & I_treatment_traj[,80] > 10),]
      
      for (sim_num in 1:nrow(I_control_traj)) {
        if (sim_num == 1) {
          plot(1:ncol(I_control_traj), I_control_traj[sim_num,] / ((ncomm * 500) / 2), type="l", xlab="t (days)", ylim=c(0, max(I_control_traj / ((ncomm * 500) / 2), na.rm=T)), ylab="approx % infectious per community pop.", col="black", xlim=c(0, 250))
        } else {
          lines(1:ncol(I_control_traj), I_control_traj[sim_num,] / ((ncomm * 500) / 2), type="l", col="black", lwd=0.3)
        }
      }
      for (sim_num in 1:nrow(I_treatment_traj)) {
        if (sim_num == 1) {
          lines(1:ncol(I_treatment_traj), I_treatment_traj[sim_num,] / ((ncomm * 500) / 2), col="orange")
        }
        lines(1:ncol(I_treatment_traj), I_treatment_traj[sim_num,] / ((ncomm * 500) / 2), col="orange", lwd=0.3)
      }
      
      par(new=T)
      plot(infect_res$t[1:219], (infect_res[1:219,(sample_size_dex + 1)]), col="blue", lwd=2, axes=F, xlab=NA, ylab=NA, xlim=c(0, 250), type="l", ylim=c(0, 1))
      mtext("power",side=4,col="blue",line=4)
      axis(4, ylim=c(0, 1), col="blue",col.axis="blue",las=1)
      
      abline(v=21, col="purple", lwd=2)
      abline(v=32, col="purple", lwd=2, lty="dashed")
      abline(h=0.8, lty="longdash", col="blue", lwd=2)
      
      dev.off()
      
      # # Save the .png of the infection_recover log ratio statistic ---------------------
      # png(paste0(output_folder, "1_", ncomm, "_0.04_", effect, "_", sample_sizes[sample_size_dex], "_500_infection_recover.png"), width=1000, height=600)
      # par(mar=c(5, 4, 4, 6) + 0.1)
      # 
      # # First do preprocessing to get rid of rows that are continuations of previous rows
      # R_control_traj <- R_control_traj[which(!is.na(R_control_traj[,80])),]
      # R_treatment_traj <- R_treatment_traj[which(!is.na(R_treatment_traj[,80])),]
      # 
      # # Create new I_R traj ----------------------------------------------------
      # I_R_control_traj <- I_control_traj + R_control_traj
      # I_R_treatment_traj <- I_treatment_traj + R_treatment_traj
      # 
      # for (sim_num in 1:nrow(I_R_control_traj)) {
      #   if (sim_num == 1) {
      #     plot(1:ncol(I_R_control_traj), I_R_control_traj[sim_num,], type="l", xlab="t (days)", ylim=c(0, max(I_R_control_traj, na.rm=T)), ylab="approx % infectious per community pop.", col="black", xlim=c(0, 250))
      #   } else {
      #     lines(1:ncol(I_R_control_traj), I_R_control_traj[sim_num,] , type="l")
      #   }
      # }
      # for (sim_num in 1:nrow(I_R_treatment_traj)) {
      #   lines(1:ncol(I_R_treatment_traj), I_R_treatment_traj[sim_num,], col="orange")
      # }
      # 
      # par(new=T)
      # plot(infect_recover_res$t[1:219], (infect_recover_res[1:219,(sample_size_dex + 1)]), col="blue", lwd=2, axes=F, xlab=NA, ylab=NA, xlim=c(0, 250), type="l", ylim=c(0, 1))
      # mtext("power",side=4,col="blue",line=4)
      # axis(4, ylim=c(0, 1), col="blue",col.axis="blue",las=1)
      # 
      # abline(v=21, col="purple", lwd=2)
      # abline(v=32, col="purple", lwd=2, lty="dashed")
      # abline(h=0.8, lty="longdash", col="blue", lwd=2)
      # 
      # dev.off()
    }
  }
}

