#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul  8 11:09:12 2020

@author: Justin

@description: a script to conduct a power analysis on the log ratio information
              recorded in the log_ratios folder. Each effect is compared to a
              null distribution to calculate the power. A histogram is 
              generated with the information of the difference between
              distributions.

@input:
    effects: list of lists. Each list has parameter information of the effect
             to compare to the null distribution. The naming convention is:
                 (cluster_coverage)_(num_comm)_(beta)_(direct_NPIE)_(ave_comm_size)

@output:
    histogram_comparison: a histogram recording the power, and general 
                          differences between the null and effect distributions
"""

# Import libraries and set input and output folders ---------------------------
import numpy as np
import pandas as pd
import math
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
input_folder = "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/log_ratios/"
output_folder = "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/log_ratios_plot/"

# Prepare list of effects to compare to null distribution ---------------------
effects = [[0.9, 40, 0.04, 0.95, 200]]

for effect in effects:
    # Load effect parameters --------------------------------------------------
    cluster_coverage = effect[0]
    num_comm = effect[1]
    beta = effect[2]
    direct_NPIE = effect[3]
    comm_size = effect[4]
    
    # Load null distribution --------------------------------------------------
    null_filename = input_folder + str(cluster_coverage) + "_" + str(num_comm) + "_" + str(beta) + "_" + str(0) + "_" + str(comm_size) + ".csv"
    null = pd.read_csv(null_filename, sep=',')
    
    # Load effect distribution ------------------------------------------------
    effect_filename = input_folder + str(cluster_coverage) + "_" + str(num_comm) + "_" + str(beta) + "_" + str(direct_NPIE) + "_" + str(comm_size) + ".csv"
    effect = pd.read_csv(effect_filename, sep=',')
    
    # Get log ratio of number of infections information -----------------------
    log_ratio_null = null.log_ratios_infect
    log_ratio_null = [float(elem) for elem in log_ratio_null]
    log_ratio_effect = effect.log_ratios_infect
    log_ratio_effect = [float(elem) for elem in log_ratio_effect]
    
    # Calculate power ---------------------------------------------------------
    log_ratio_null = np.sort(log_ratio_null)
    p_val = log_ratio_null[math.ceil(0.05 * 500)]
    log_ratio_effect = np.sort(log_ratio_effect)
    num_below = min(np.where(log_ratio_effect > p_val)[0])
    power = (num_below / 500) * 100
    
    # Plot histogram comparison -----------------------------------------------
    plt.hist(log_ratio_null, bins=10, alpha=0.5, label="null", color="blue")
    plt.hist(log_ratio_effect, bins=10, alpha=0.5, label="effect", color="orange")
    plt.axvline(x = p_val, linestyle='--', color="red")
    plt.ylabel('Frequency')
    plt.xlabel('ln((num_infect_treatment + 1) / (num_infect_control + 1))')
    null_patch = mpatches.Patch(color='blue', label='null')
    effect_patch = mpatches.Patch(color='orange', label='effect')
    power_patch = mpatches.Patch(color='red', linestyle="--", label='power: ' + str(round(power, 2)))
    statistics_patch = mpatches.Patch(color='white', label="median null: " + str(round(np.median(log_ratio_null), 2)) + "\nmedian effect: " + str(round(np.median(log_ratio_effect), 2)))
    plt.legend(loc="upper right", handles=[null_patch, effect_patch, power_patch, statistics_patch], prop={'size': 6})
    plot_filename = output_folder + str(cluster_coverage) + "_" + str(num_comm) + "_" + str(beta) + "_" + str(direct_NPIE) + "_" + str(comm_size) + ".png"
    plt.savefig(plot_filename, dpi=1000)
    plt.clf()