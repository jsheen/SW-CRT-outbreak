#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul  8 09:16:24 2020

@author: Justin

@description: a script to get the number of infected in treatment clusters, the
              number of infected in control clusters, the number of recovered 
              in treatment clusters, the number of recovered in control 
              clusters, and the log ratios of infected in treatment vs. control
              and log ratios of recovered in treatment vs. control, according
              to the final_statuses of the epidemic simulations run.

@input: .csvs of final statuses of epidemic simulations in the csvs folder. The
        naming convention of each result cell is:
            (node)_(comm_dex)_(treated)_(enrolled)_(final_status)
            
@output: information described in @description above, in a .csv format
"""

# Import libraries and set input and output folders ---------------------------
import pandas as pd
import numpy as np
input_folder = "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/csvs/"
output_folder = "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/log_ratios/"

# Input log ratios wanted -----------------------------------------------------
effects = [[0.5, 70, 0.04, 0, 100],
           [0.5, 70, 0.04, 0.8, 100]]

# Loop through each effect ----------------------------------------------------
for effect in effects:
    cluster_coverage = effect[0]
    num_comm = effect[1]
    beta = effect[2]
    direct_NPIE = effect[3]
    comm_size = effect[4]
    
    # Input .csv file of final statuses ---------------------------------------
    filename = input_folder + str(cluster_coverage) + "_" + str(num_comm) + "_" + str(beta) + "_" + str(direct_NPIE) + "_" + str(comm_size) + "/batch_res.csv"
    df = pd.read_csv(filename, header=None, names=range(15000), sep=',')
    
    # Loop through simulations ------------------------------------------------
    infected_treatment = []
    infected_control = []
    recovered_treatment = []
    recovered_control = []
    for row_num in range(500):
        print("Sim. number: " + str(row_num))
        sim_infect_treatment = 0
        sim_infect_control = 0
        sim_recover_treatment = 0
        sim_recover_control = 0
        for col_num in range(2, 15000):
            if not pd.isnull(df[col_num][row_num]):
                res = df[col_num][row_num].split("_")
                # If enrolled, and infected -----------------------------------
                if res[3] == '1' and res[4] == 'I': 
                    # If treated ----------------------------------------------
                    if res[2] == '1':
                        sim_infect_treatment += 1
                    else:
                    # If control ----------------------------------------------
                        sim_infect_control += 1
                # If enrolled, and recovered ----------------------------------
                elif res[3] == '1' and res[4] == 'R':
                    # If treated ----------------------------------------------
                    if res[2] == '1':
                        sim_recover_treatment += 1
                    # If control ----------------------------------------------
                    else:
                        sim_recover_control += 1
        infected_treatment.append(sim_infect_treatment)
        infected_control.append(sim_infect_control)
        recovered_treatment.append(sim_recover_treatment)
        recovered_control.append(sim_recover_control)
    log_ratios_infect = [np.log((i_t + 1) / (i_c + 1)) for i_t,i_c in zip(infected_treatment, infected_control)]
    log_ratios_recover = [np.log((r_t + 1) / (r_c + 1)) for r_t,r_c in zip(recovered_treatment, recovered_control)]
    
    # Check for errors --------------------------------------------------------
    if (len(infected_treatment) != len(infected_control) or
       len(infected_control) != len(recovered_treatment) or
       len(recovered_treatment) != len(recovered_control) or
       len(recovered_control) != len(log_ratios_infect) or
       len(log_ratios_infect) != len(log_ratios_recover)):
           raise NameError("Lists are not the same size.")
    
    # Write output ------------------------------------------------------------
    filename = output_folder + str(cluster_coverage) + "_" + str(num_comm) + "_" + str(beta) + "_" + str(direct_NPIE) + "_" + str(comm_size) + ".csv"
    with open(filename, 'w') as out_f:
        out_f.write("I_t" + ",")
        out_f.write("I_c" + ",")
        out_f.write("R_t" + ",")
        out_f.write("R_c" + ",")
        out_f.write("log_ratios_infect" + ",")
        out_f.write("log_ratios_recover" + ",")
        out_f.write("\n")
        for l in range(len(infected_treatment)):
            out_f.write(str(infected_treatment[l]) + ",")
            out_f.write(str(infected_control[l]) + ",")
            out_f.write(str(recovered_treatment[l]) + ",")
            out_f.write(str(recovered_control[l]) + ",")
            out_f.write(str(log_ratios_infect[l]) + ",")
            out_f.write(str(log_ratios_recover[l]) + ",")
            out_f.write("\n")
