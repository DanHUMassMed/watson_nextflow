#!/usr/bin/env python3

from pub_worm.wormbase.wormbase_api import WormbaseAPI
import os
import sys
import datetime
import pandas as pd

import logging
import logging.config

try:
    logging.config.fileConfig('logging.config')
except Exception:
    logging.basicConfig(filename='pub_worm_reference_data.log', level=logging.DEBUG)

logger = logging.getLogger(__name__)

def ontology_json_to_dataframe(json_obj, wormbase_id, file_name=None):
    rows = []
    row = []
    for category, cat_lst in json_obj.items():
        #print(f"{category=}")
        #print(f"{cat_lst=}")
        row = [wormbase_id]
        if isinstance(cat_lst, dict):
            row.append(cat_lst['go_id'])
            row.append(category)
            row.append(cat_lst['go_term'])
            rows.append(row)
            row = [wormbase_id]
        else:
            for cat_lst_item in cat_lst:
                #print(f"{cat_lst_item=}")
                row.append(cat_lst_item['go_id'])
                row.append(category)
                row.append(cat_lst_item['go_term'])
                rows.append(row)
                row = [wormbase_id]

    df = pd.DataFrame(rows)
    df.columns=["wormbase_id", "go_id", "go_category", "go_term"]
    if file_name:
        df.to_csv(file_name, index=False)
    return df

def get_ontology_data(batch_file_nm):
    out_file_nm = batch_file_nm.replace(".csv", "_out.csv")
    wormbase_df = pd.read_csv(batch_file_nm)

    log_msg = f"Starting get_ontology_data with {len(wormbase_df):,} entries"
    logger.debug(log_msg)
    
    wormbase_api = WormbaseAPI("field", "gene", "gene_ontology_summary")
    
    concatenated_df = pd.DataFrame()
    dfs = []
    index=0
    number_of_rows=len(wormbase_df)
    for df_index, row in wormbase_df.iterrows():
        wormbase_id = row['Wormbase_Id']
        index +=1
        #print(f"{index:<4} of {len(transmembrane_transport_df)} {row['wormbase_id']}")
        ret_data = wormbase_api.get_wormbase_data(wormbase_id)
        if 'gene_ontology_summary' in ret_data:
            df = ontology_json_to_dataframe(ret_data['gene_ontology_summary'], wormbase_id)
            dfs.append(df)

        # Concatenate every 100 DataFrames
        # If something crashes we may be able to recover without a full rerun
        if index % 100 == 0:
            log_msg = f"{index:>4} of {number_of_rows} {wormbase_id}"
            logger.debug(log_msg)
            concatenated_df = pd.concat([concatenated_df] + dfs, ignore_index=True)
            # concatenated_df.to_csv(out_file_nm, index=False)
            dfs = []  # Reset the list for the next batch

    # Concatenate the remaining DataFrames
    if dfs:
        concatenated_df = pd.concat([concatenated_df] + dfs, ignore_index=True)
        concatenated_df.to_csv(out_file_nm, index=False)
    return concatenated_df


if __name__ == "__main__":
    category_data_file = sys.argv[1]
    file_name = category_data_file.replace('\\','')
    get_ontology_data(file_name)
   
    
    
