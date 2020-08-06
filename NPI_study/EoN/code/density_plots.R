effect <- read.csv("~/SW-CRT-outbreak/NPI_study/EoN/code_output/log_ratios/1_20_0.04_0.6_500_1_1.csv", stringsAsFactors = F)
null <- read.csv("~/SW-CRT-outbreak/NPI_study/EoN/code_output/permutation_test/1_20_0.04_0_500_1_1.csv", stringsAsFactors = F)

effect <- effect[order(effect$log_ratios_infect),]
null <- null[order(null$x),]
p_val <- null[250]

plot(density(effect$log_ratios_infect), ylim=c(0, 0.8), xlim=c(-4, 3), main="", xlab="log((# infections treatment + 1) / (# infections control + 1))")
lines(density(null), col = 4)
abline(v=p_val, col=6)


