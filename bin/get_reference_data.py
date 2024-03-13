#!/usr/bin/env python3

from pub_worm.wormbase.wormbase_api import WormbaseAPI
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
# Function to iterate a list of Wormcat items
def get_reference_data(batch_file_nm):
    
    out_file_nm = batch_file_nm.replace(".csv", "_out.csv")
    wormbase_df = pd.read_csv(batch_file_nm)

    log_msg = f"Starting get_reference_data with {len(wormbase_df):,} entries"
    logger.debug(log_msg)

    wormbase_api = WormbaseAPI("field", "gene", "references")

    concatenated_df = pd.DataFrame()
    dfs = []
    index=0
    number_of_rows=len(wormbase_df)
    for df_index, row in wormbase_df.iterrows():
        wormbase_id = row['Wormbase_Id']
        index +=1
        #print(f"{index:<4} of {len(transmembrane_transport_df)} {row['wormbase_id']}")
        ret_data = wormbase_api.get_wormbase_data(wormbase_id)
        if 'references_list' in ret_data:
            if isinstance(ret_data['references_list'], dict):
                references_df = pd.DataFrame(ret_data['references_list'], index=[0])
            else:
                references_df = pd.DataFrame(ret_data['references_list'])
            if 'wbp_abstract' in references_df.columns:
                references_df = references_df.drop(columns=['wbp_abstract'])
            references_df['wormbase_id']=wormbase_id
            dfs.append(references_df)
        else:
            print("-", end='')
            #print(f"Return has no references_list!\n{ret_data}")

        # Concatenate every 100 DataFrames
        # If something crashes we may be able to recover without a full rerun
        if index % 100 == 0:
            log_msg = f"{index:>4} of {number_of_rows} {wormbase_id}"
            logger.debug(log_msg)
            concatenated_df = pd.concat([concatenated_df] + dfs, ignore_index=True)
            concatenated_df.to_csv(out_file_nm, index=False)
            dfs = []  # Reset the list for the next batch

    # Concatenate the remaining DataFrames
    if dfs:
        print("final")
        concatenated_df = pd.concat([concatenated_df] + dfs, ignore_index=True)
        concatenated_df.to_csv(out_file_nm, index=False)
    return concatenated_df


# Used for testing
def copy_file_with_prefix(src_file, prefix):
    # Get the directory of the source file
    src_dir = os.path.dirname(src_file)
    
    with open(src_file, 'rb') as src:
        # Get the filename from the source file path
        filename = os.path.basename(src_file)
        
        # Construct the new filename with the prefix
        new_filename = f"{prefix}{filename}"
        
        # Construct the full destination path
        dest_path = os.path.join(src_dir, new_filename)
        
        with open(dest_path, 'wb') as dest:
            # Copy the contents of the source file to the destination file
            dest.write(src.read())


if __name__ == "__main__":
    wb_data_file = sys.argv[1]
    file_name = wb_data_file.replace('\\','')
    get_reference_data(file_name)
    
