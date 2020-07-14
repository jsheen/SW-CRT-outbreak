#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul  9 18:41:28 2020

@author: Justin

@description: a script to get the logistic regressions of the effects

@input: .csvs of final statuses of epidemic simulations in the csvs folder. The
        naming convention of each result cell is:
            (node)_(comm_dex)_(treated)_(enrolled)_(final_status)
            
@output: information described in @description above, in a .csv format
"""

# Import libraries and set input and output folders ---------------------------
import pandas as pd
input_folder = "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/csvs/"
output_folder = "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/logistic_regressions_raw/"

# Input log ratios wanted -----------------------------------------------------
effects = [[0.9, 70, 0.04, 0.8, 100]]

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
    matrix_res = []
    for row_num in range(500):
        print("Sim. number: " + str(row_num))
        x = []
        y = []
        for col_num in range(2, 15000):
            if not pd.isnull(df[col_num][row_num]):
                res = df[col_num][row_num].split("_")
                # If enrolled -------------------------------------------------
                if res[3] == '1':
                    # If treated ----------------------------------------------
                    if res[2] == '1':
                        x.append(1)
                        # If infectious ---------------------------------------
                        if res[4] == "I":
                            y.append(1)
                        else:
                            y.append(0)
                    # If control ----------------------------------------------
                    else:
                        x.append(0)
                        # If infectious ---------------------------------------
                        if res[4] == "I":
                            y.append(1)
                        else:
                            y.append(0)
        
        count_one_one = 0
        count_one_zero = 0
        count_zero_one = 0
        count_zero_zero = 0
        for index in range(len(x)):
            if x[index] == 1 and y[index] == 1:
                count_one_one += 1
            elif x[index] == 1 and y[index] == 0:
                count_one_zero += 1
            elif x[index] == 0 and y[index] == 1:
                count_zero_one += 1
            elif x[index] == 0 and y[index] == 0:
                count_zero_zero += 1
        matrix_res.append([count_one_one, count_one_zero, count_zero_one, count_zero_zero])
    
    # Write output ------------------------------------------------------------
    filename = output_folder + str(cluster_coverage) + "_" + str(num_comm) + "_" + str(beta) + "_" + str(direct_NPIE) + "_" + str(comm_size) + ".csv"
    with open(filename, 'w') as out_f:
        out_f.write("treat_one" + ",")
        out_f.write("treat_zero" + ",")
        out_f.write("control_one" + ",")
        out_f.write("control_zero" + ",")
        out_f.write("\n")
        for l in range(len(matrix_res)):
            out_f.write(str(matrix_res[l][0]) + ",")
            out_f.write(str(matrix_res[l][1]) + ",")
            out_f.write(str(matrix_res[l][2]) + ",")
            out_f.write(str(matrix_res[l][3]) + ",")
            out_f.write("\n")
