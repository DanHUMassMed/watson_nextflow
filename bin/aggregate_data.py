#!/usr/bin/env python3
import os
import sys
import pandas as pd

import logging
import logging.config

try:
    logging.config.fileConfig('logging.config')
except Exception:
    logging.basicConfig(filename='pub_worm_reference_data.log', level=logging.DEBUG)

logger = logging.getLogger(__name__)

def aggregate_data(dir_to_search, aggregated_out_file_nm):
    # Initialize an empty DataFrame to collect the data
    concatenated_df = pd.DataFrame()
    
    # Search for files matching the pattern
    for filename in os.listdir(dir_to_search):
        if filename.startswith('wb_') and filename.endswith('_out.csv'):
            file_path = os.path.join(dir_to_search, filename)
            # Read the CSV file into a DataFrame
            try:
                df = pd.read_csv(file_path)
                # Concatenate the DataFrame to the collector DataFrame
                concatenated_df = pd.concat([concatenated_df, df], ignore_index=True)
            except Exception as ex:
                error_msg=f"Error while loading file {file_path} {str(ex)}"
                logger.error(error_msg)
                
    # Write the concatenated DataFrame to a CSV file
    concatenated_df.to_csv(aggregated_out_file_nm, index=False)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python aggregate_data.py <aggregated_out_file_nm>")
        sys.exit(1)

    aggregated_out_file_nm = gene_ids_csv = sys.argv[1]
    # Call the function to aggregate the data
    dir_to_search="./"
    aggregate_data(dir_to_search, aggregated_out_file_nm)