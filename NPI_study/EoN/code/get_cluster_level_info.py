#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul 16 17:50:16 2020

@author: Justin

@description: a script to get cluster level information of NPI trial. This is
              preferable in order to match on cluster size and perform a
              Wilcoxon-signed rank test rather than the test statistic derived
              from the discrete SIR model.

@input: .csvs of final statuses of epidemic simulations in the csvs folder. The
        naming convention of each result cell is:
            (node)_(comm_dex)_(treated)_(enrolled)_(final_status)
            
@output: information described in @description above, in a .csv format. The
         naming convention of each result cell is:
            (cluster_num)_(treated)_(size)_(num_enrolled)_(num_infected)
"""

# Import libraries and set input and output folders ---------------------------
import pandas as pd
input_folder = "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/csvs_1_1/csvs/"
output_folder = "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/cluster_info/"

# Input effects cluster info wanted for ---------------------------------------
# Input log ratios wanted -----------------------------------------------------
effects = [[1, 20, 0.04, 0, 500],
           [1, 20, 0.04, 0.6, 500]]

# Loop through each effect ----------------------------------------------------
for effect in effects:
    if len(effect) == 6:
        cluster_coverage = effect[0]
        num_comm = effect[1]
        beta = effect[2]
        direct_NPIE = effect[3]
        comm_size = effect[4]
        background_effect = effect[5]
    
        # Input .csv file of final statuses ---------------------------------------
        filename = input_folder + str(cluster_coverage) + "_" + str(num_comm) + "_" + str(beta) + "_" + str(direct_NPIE) + "_" + str(comm_size) + "_" + str(background_effect) + "/batch_res.csv"
    else:
        cluster_coverage = effect[0]
        num_comm = effect[1]
        beta = effect[2]
        direct_NPIE = effect[3]
        comm_size = effect[4]
    
        # Input .csv file of final statuses ---------------------------------------
        filename = input_folder + str(cluster_coverage) + "_" + str(num_comm) + "_" + str(beta) + "_" + str(direct_NPIE) + "_" + str(comm_size) + "/batch_res.csv"
    
    df = pd.read_csv(filename, header=None, names=range(15000), sep=',')
    
    # Loop through simulations ------------------------------------------------
    cumul_size_ls = []
    cumul_num_enrolled_ls = []
    cumul_num_infected_ls = []
    cumul_treated_ls = []
    for row_num in range(500):
        print("Sim. number: " + str(row_num))        
        size_ls = [0] * int(num_comm)
        num_enrolled_ls = [0] * int(num_comm)
        num_infected_ls = [0] * int(num_comm)
        treated_ls = [-1] * int(num_comm)
        for col_num in range(2, 15000):
            if not pd.isnull(df[col_num][row_num]):
                res = df[col_num][row_num].split("_")
                # Get cluster number ------------------------------------------
                cluster_num = int(res[1])
                
                # Add to cluster size -----------------------------------------
                size_ls[cluster_num] = size_ls[cluster_num]  + 1
                
                # Get whether enrolled in trial -------------------------------
                enrolled = res[3]
                if enrolled == "1":
                    num_enrolled_ls[cluster_num] = num_enrolled_ls[cluster_num] + 1
                    
                    # Get whether this individual is in a treated cluster -----
                    treated = res[2]
                    if treated == "1":
                        treated_ls[cluster_num] = 1
                    else:
                        treated_ls[cluster_num] = 0
                    
                    # Get whether infected or not -----------------------------
                    status = res[4]
                    if status == "I":
                        num_infected_ls[cluster_num] = num_infected_ls[cluster_num] + 1
                        
        cumul_size_ls.append(size_ls)
        cumul_num_enrolled_ls.append(num_enrolled_ls)
        cumul_num_infected_ls.append(num_infected_ls)
        cumul_treated_ls.append(treated_ls)

    # Check for errors --------------------------------------------------------
    if (len(size_ls) != len(num_enrolled_ls) or
       len(num_enrolled_ls) != len(num_infected_ls) or
       len(num_infected_ls) != len(treated_ls)):
           raise NameError("Lists are not the same size.")
    
    # Write output ------------------------------------------------------------
    if len(effect) == 6:
        filename = output_folder + str(cluster_coverage) + "_" + str(num_comm) + "_" + str(beta) + "_" + str(direct_NPIE) + "_" + str(comm_size) + "_" + str(background_effect) + ".csv"
    else:
        filename = output_folder + str(cluster_coverage) + "_" + str(num_comm) + "_" + str(beta) + "_" + str(direct_NPIE) + "_" + str(comm_size) + "_1_1" + ".csv"
    
    with open(filename, 'w') as out_f:
        # For each simulation -------------------------------------------------
        for l in range(len(cumul_size_ls)):
            # For each cluster of the simulation ------------------------------
            for l_2 in range(len(cumul_treated_ls[l])):
                cluster_num = str(l_2) + "_"
                treatment = str(cumul_treated_ls[l][l_2]) + "_"
                size = str(cumul_size_ls[l][l_2]) + "_"
                num_enrolled = str(cumul_num_enrolled_ls[l][l_2]) + "_"
                num_infected = str(cumul_num_infected_ls[l][l_2])
                unicode = cluster_num + treatment + size + num_enrolled + num_infected
                out_f.write(unicode + ",")
            out_f.write("\n")
