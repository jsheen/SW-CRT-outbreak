#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 10 11:29:06 2020

@author: Justin
"""

# Import libraries and set input and output folders ---------------------------
import pandas as pd
import numpy as np
import math
input_folder = "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/csvs_1_1/csvs/"
output_folder = "/Users/Justin/SW-CRT-outbreak/NPI_study/EoN/code_output/power_shiny_data/csvs/"

ncomms = [80, 60, 40, 20]
effects = [0.2, 0.4, 0.6]
sample_sizes = list(range(1000, 41000, 1000))

seed = 0

for ncomm in ncomms:
    for effect in effects:
        # Load "null" results -------------------------------------------------
        first_fifty_filename = input_folder + "1_" + str(ncomm) + "_0.04_" + str(0) + "_500_run1/batch_res.csv"
        first_fifty_df = pd.read_csv(first_fifty_filename, header=None, names=range(1000), sep=',')
        second_fifty_filename = input_folder + "1_" + str(ncomm) + "_0.04_" + str(0) + "_500_run2/batch_res.csv"
        second_fifty_df = pd.read_csv(second_fifty_filename, header=None, names=range(1000), sep=',')
        null_df = pd.concat([first_fifty_df, second_fifty_df], ignore_index=True)
        
        # Load "effect" results -----------------------------------------------
        first_fifty_filename = input_folder + "1_" + str(ncomm) + "_0.04_" + str(effect) + "_500_run1/batch_res.csv"
        first_fifty_df = pd.read_csv(first_fifty_filename, header=None, names=range(1000), sep=',')
        second_fifty_filename = input_folder + "1_" + str(ncomm) + "_0.04_" + str(effect) + "_500_run2/batch_res.csv"
        second_fifty_df = pd.read_csv(second_fifty_filename, header=None, names=range(1000), sep=',')
        effect_df = pd.concat([first_fifty_df, second_fifty_df], ignore_index=True)
        
        # Loop through time steps ---------------------------------------------
        time_step_infect_res = []
        time_step_infect_recover_res = []
        
        for time_step in range(500):
            print("Curr. time step: " + str(time_step))
            # If treatment was already applied --------------------------------
            if time_step >= 32:
                power_per_sample_size_log_ratio_infect = []
                power_per_sample_size_log_ratio_infect_recover = []
                for sample_size in sample_sizes:
                    cumul_null_log_ratio_infect = []
                    cumul_null_log_ratio_infect_recover = []
                    cumul_effect_log_ratio_infect = []
                    cumul_effect_log_ratio_infect_recover = []
                    
                    effect_states = []
                    null_states = []
                    
                    # Loop through each simulation ----------------------------
                    for sim_num in list(range(100)):
                        if not pd.isnull(null_df[time_step][sim_num]):
                            # Randomly sample from the null population --------
                            null_state = null_df[time_step][sim_num].split("_")
                            if (int(null_state[0]) + 1) != time_step:
                                print(null_state[0])
                                print(time_step)
                                raise NameError("Error in the time step name.")
                            null_states.append(int(null_state[6]))
                            
                            tot_study_pop = int(null_state[1]) + int(null_state[2]) + int(null_state[3]) + int(null_state[4]) + int(null_state[5]) + int(null_state[6]) + int(null_state[7]) + int(null_state[8])
                            if (sample_size / tot_study_pop) > 0.975:
                                infect_control = int(null_state[5])
                                infect_treatment = int(null_state[6])
                                infect_recover_control = int(null_state[5]) + int(null_state[7])
                                infect_recover_treatment = int(null_state[6]) + int(null_state[8])
                                
                                null_log_ratio_infect = np.log((infect_treatment + 1) / (infect_control + 1))
                                null_log_ratio_infect_recover = np.log((infect_recover_treatment + 1) / (infect_recover_control + 1))
                                
                                cumul_null_log_ratio_infect.append(null_log_ratio_infect)
                                cumul_null_log_ratio_infect_recover.append(null_log_ratio_infect_recover)
                            else:
                                gen = np.random.Generator(np.random.PCG64(seed))
                                null_pop_control = [int(null_state[1]), int(null_state[3]), int(null_state[5]), int(null_state[7])]
                                null_pop_treatment = [int(null_state[2]), int(null_state[4]), int(null_state[6]), int(null_state[8])]
                                sample_condition = math.floor(sample_size / 2)
                            
                                null_samples_control = gen.multivariate_hypergeometric(null_pop_control, nsample=sample_condition, size=500)
                                null_samples_treatment = gen.multivariate_hypergeometric(null_pop_treatment, nsample=sample_condition, size=500)
                                
                                control_n_infect_sampled = null_samples_control[:,2]
                                control_n_infect_recover_sampled = null_samples_control[:,2] + null_samples_control[:,3]
                                
                                treatment_n_infect_sampled = null_samples_treatment[:,2]
                                treatment_n_infect_recover_sampled = null_samples_treatment[:,2] + null_samples_treatment[:,3]
                                
                                null_log_ratio_infect = np.log((treatment_n_infect_sampled + 1) / (control_n_infect_sampled + 1))
                                null_log_ratio_infect_recover = np.log((treatment_n_infect_recover_sampled + 1) / (control_n_infect_recover_sampled + 1))
                                
                                cumul_null_log_ratio_infect = cumul_null_log_ratio_infect + null_log_ratio_infect.tolist()
                                cumul_null_log_ratio_infect_recover = cumul_null_log_ratio_infect_recover + null_log_ratio_infect_recover.tolist()
                            
                        if not pd.isnull(effect_df[time_step][sim_num]):
                            # Randomly sample from the effect population ------
                            effect_state = effect_df[time_step][sim_num].split("_")
                            if (int(effect_state[0]) + 1) != time_step:
                                print(effect_state[0])
                                print(time_step)
                                raise NameError("Error in the time step name.")
                            effect_states.append(int(effect_state[6]))
                                
                            tot_study_pop = int(effect_state[1]) + int(effect_state[2]) + int(effect_state[3]) + int(effect_state[4]) + int(effect_state[5]) + int(effect_state[6]) + int(effect_state[7]) + int(effect_state[8])
                            if (sample_size / tot_study_pop) > 0.975:
                                infect_control = int(effect_state[5])
                                infect_treatment = int(effect_state[6])
                                infect_recover_control = int(effect_state[5]) + int(effect_state[7])
                                infect_recover_treatment = int(effect_state[6]) + int(effect_state[8])
                                
                                effect_log_ratio_infect = np.log((infect_treatment + 1) / (infect_control + 1))
                                effect_log_ratio_infect_recover = np.log((infect_recover_treatment + 1) / (infect_recover_control + 1))
                                
                                cumul_effect_log_ratio_infect.append(effect_log_ratio_infect)
                                cumul_effect_log_ratio_infect_recover.append(effect_log_ratio_infect_recover)
                            else:
                                gen = np.random.Generator(np.random.PCG64(seed))
                                effect_pop_control = [int(effect_state[1]), int(effect_state[3]), int(effect_state[5]), int(effect_state[7])]
                                effect_pop_treatment = [int(effect_state[2]), int(effect_state[4]), int(effect_state[6]), int(effect_state[8])]
                                sample_condition = math.floor(sample_size / 2)
                                
                                effect_samples_control = gen.multivariate_hypergeometric(effect_pop_control, nsample=sample_condition, size=500)
                                effect_samples_treatment = gen.multivariate_hypergeometric(effect_pop_treatment, nsample=sample_condition, size=500)
                                
                                control_n_infect_sampled = effect_samples_control[:,2]
                                control_n_infect_recover_sampled = effect_samples_control[:,2] + effect_samples_control[:,3]
                                
                                treatment_n_infect_sampled = effect_samples_treatment[:,2]
                                treatment_n_infect_recover_sampled = effect_samples_treatment[:,2] + effect_samples_treatment[:,3]
                                
                                effect_log_ratio_infect = np.log((treatment_n_infect_sampled + 1) / (control_n_infect_sampled + 1))
                                effect_log_ratio_infect_recover = np.log((treatment_n_infect_recover_sampled + 1) / (control_n_infect_recover_sampled + 1))
                                
                                cumul_effect_log_ratio_infect = cumul_effect_log_ratio_infect + effect_log_ratio_infect.tolist()
                                cumul_effect_log_ratio_infect_recover = cumul_effect_log_ratio_infect_recover + effect_log_ratio_infect_recover.tolist()
                    
                    if len(cumul_null_log_ratio_infect) != 0 and len(cumul_effect_log_ratio_infect) != 0:
                        # Calculate power for infection log ratio for this sample size
                        cumul_null_log_ratio_infect = np.sort(cumul_null_log_ratio_infect)
                        cumul_effect_log_ratio_infect = np.sort(cumul_effect_log_ratio_infect)
                        p_val_val_dex = math.floor(0.05 * len(cumul_null_log_ratio_infect))
                        p_val_val = cumul_null_log_ratio_infect[p_val_val_dex]
                        test_num_under_p_val_val = np.where(cumul_effect_log_ratio_infect > p_val_val)[0]
                        if test_num_under_p_val_val.size == 0:
                            num_under_p_val_val = len(cumul_effect_log_ratio_infect)
                        else:
                            num_under_p_val_val = test_num_under_p_val_val[0]
                        log_ratio_infect_power = num_under_p_val_val / len(cumul_effect_log_ratio_infect)
                        power_per_sample_size_log_ratio_infect.append(log_ratio_infect_power)
                
                        # Calculate power for infection & recovery log ratio for this sample size
                        cumul_null_log_ratio_infect_recover = np.sort(cumul_null_log_ratio_infect_recover)
                        cumul_effect_log_ratio_infect_recover = np.sort(cumul_effect_log_ratio_infect_recover)
                        p_val_val_dex = math.floor(0.05 * len(cumul_null_log_ratio_infect_recover))
                        p_val_val = cumul_null_log_ratio_infect_recover[p_val_val_dex]
                        test_num_under_p_val_val = np.where(cumul_effect_log_ratio_infect_recover > p_val_val)[0]
                        if test_num_under_p_val_val.size == 0:
                            num_under_p_val_val = len(cumul_effect_log_ratio_infect_recover)
                        else:
                            num_under_p_val_val = test_num_under_p_val_val[0]
                        log_ratio_infect_recover_power = num_under_p_val_val / len(cumul_effect_log_ratio_infect_recover)
                        power_per_sample_size_log_ratio_infect_recover.append(log_ratio_infect_recover_power)
                
                # Put the power in a list of lists for each time step ---------
                power_per_sample_size_log_ratio_infect.insert(0, time_step)
                time_step_infect_res.append(power_per_sample_size_log_ratio_infect)
                print(power_per_sample_size_log_ratio_infect)
                power_per_sample_size_log_ratio_infect_recover.insert(0, time_step)
                time_step_infect_recover_res.append(power_per_sample_size_log_ratio_infect_recover)
                print(power_per_sample_size_log_ratio_infect_recover)
        
        # Save the power results ----------------------------------------------
        filename = output_folder + "1_" + str(ncomm) + "_0.04_" + str(effect) + "_500_infect_res.csv"
        with open(filename, 'w') as out_f:
            out_f.write("t,")
            for sample_size in sample_sizes:
                out_f.write(str(sample_size) + ",")
            out_f.write("\n")
            for l in range(len(time_step_infect_res)):
                if len(time_step_infect_res[l]) > 1:
                    for l2 in range(len(time_step_infect_res[l])):
                        out_f.write(str(time_step_infect_res[l][l2]) + ",")
                out_f.write("\n")
                
        filename = output_folder + "1_" + str(ncomm) + "_0.04_" + str(effect) + "_500_infect_recover_res.csv"
        with open(filename, 'w') as out_f:
            out_f.write("t,")
            for sample_size in sample_sizes:
                out_f.write(str(sample_size) + ",")
            out_f.write("\n")
            for l in range(len(time_step_infect_recover_res)):
                if len(time_step_infect_recover_res[l]) > 1:
                    for l2 in range(len(time_step_infect_recover_res[l])):
                        out_f.write(str(time_step_infect_recover_res[l][l2]) + ",")
                out_f.write("\n")
        
        # Save the trajectory of effect dist ----------------------------------
        cumul_I_control = []
        cumul_I_treatment = []
        cumul_R_control = []
        cumul_R_treatment = []
        for sim_num in list(range(100)):
            I_control = []
            I_treatment = []
            R_control = []
            R_treatment = []
            for time_step in range(500):
                if not pd.isnull(effect_df[time_step][sim_num]):
                    # Randomly sample from the effect population ----------
                    effect_state = effect_df[time_step][sim_num].split("_")
                    I_control.append(int(effect_state[5]))
                    I_treatment.append(int(effect_state[6]))
                    R_control.append(int(effect_state[7]))
                    R_treatment.append(int(effect_state[8]))
            cumul_I_control.append(I_control)
            cumul_I_treatment.append(I_treatment)
            cumul_R_control.append(R_control)
            cumul_R_treatment.append(R_treatment)

        
        filename = output_folder + "1_" + str(ncomm) + "_0.04_" + str(effect) + "_500_infect_recover_traj_I_control.csv"
        with open(filename, 'w') as out_f:
            for l in range(len(cumul_I_control)):
                for l2 in range(len(cumul_I_control[l])):
                    out_f.write(str(cumul_I_control[l][l2]) + ",")
                out_f.write("\n")
                
        filename = output_folder + "1_" + str(ncomm) + "_0.04_" + str(effect) + "_500_infect_recover_traj_I_treatment.csv"
        with open(filename, 'w') as out_f:
            for l in range(len(cumul_I_treatment)):
                for l2 in range(len(cumul_I_treatment[l])):
                    out_f.write(str(cumul_I_treatment[l][l2]) + ",")
                out_f.write("\n")
                
        filename = output_folder + "1_" + str(ncomm) + "_0.04_" + str(effect) + "_500_infect_recover_traj_R_control.csv"
        with open(filename, 'w') as out_f:
            for l in range(len(cumul_R_control)):
                for l2 in range(len(cumul_R_control[l])):
                    out_f.write(str(cumul_R_control[l][l2]) + ",")
                out_f.write("\n")
                
        filename = output_folder + "1_" + str(ncomm) + "_0.04_" + str(effect) + "_500_infect_recover_traj_R_treatment.csv"
        with open(filename, 'w') as out_f:
            for l in range(len(cumul_R_treatment)):
                for l2 in range(len(cumul_R_treatment[l])):
                    out_f.write(str(cumul_R_treatment[l][l2]) + ",")
                out_f.write("\n")
        
            
                
                
            
            
        
        