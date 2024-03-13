#!/usr/bin/env python3
import os
import pandas as pd

def aggregate_reference_data(dir_to_search):
    # Initialize an empty DataFrame to collect the data
    concatenated_df = pd.DataFrame()
    
    # Search for files matching the pattern
    for filename in os.listdir(dir_to_search):
        if filename.startswith('wb_') and filename.endswith('_out.csv'):
            file_path = os.path.join(dir_to_search, filename)
            # Read the CSV file into a DataFrame
            df = pd.read_csv(file_path)
            
            # Concatenate the DataFrame to the collector DataFrame
            concatenated_df = pd.concat([concatenated_df, df], ignore_index=True)
    
    # Write the concatenated DataFrame to a new CSV file
    out_file_nm = 'wb_reference_papers.csv'
    concatenated_df.to_csv(out_file_nm, index=False)

# Call the function to aggregate the data
dir_to_search="./"
aggregate_reference_data(dir_to_search)