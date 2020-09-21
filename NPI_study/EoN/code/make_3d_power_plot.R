library(plotly)

effects <- c(0.2, 0.4, 0.6)
betas <- c(0.02, 0.03, 0.04)
ncomms <- c(20, 40, 60, 80)
day <- 49

for (effect in effects) {
  for (beta in betas) {
    ncomm_res_ls <- list()
    ncomm_res_ls_dex <- 1
    for (ncomm in ncomms) {
      filename <- paste0("1_", ncomm, "_", beta, "_", effect, "_500_infect_res.csv")
      file_power <- read.csv(paste0("~/SW-CRT-outbreak/NPI_study/EoN/code_output/power_shiny_data/csvs/", filename), stringsAsFactors = F, header = F)
      file_power <- file_power[,1:(ncol(file_power) - 1)]
      sample_axis <- file_power[which(file_power$V1 == day),]
      sample_axis <- sample_axis[,2:ncol(sample_axis)]
      colnames(sample_axis) <- seq(1000, 40000, 1000)
      ncomm_res_ls[[ncomm_res_ls_dex]] <- sample_axis
      ncomm_res_ls_dex <- ncomm_res_ls_dex + 1
    }
    ncomm_res <- do.call(rbind, ncomm_res_ls)
    rownames(ncomm_res) <- ncomms
    ncomm_res <- sapply(ncomm_res, function (x) as.numeric(x))
    
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
    fig <- fig %>% layout(title = paste0("Days after treatment: ", day - 21, 
                                         "; effect: ", effect,
                                         "; beta: ", beta))
    
    orca(fig, file = paste0("~/Desktop/3d/", day, "_", effect, "_", beta, ".png"))
  }
}