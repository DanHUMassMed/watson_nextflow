#!/usr/bin/env python3

from pub_worm.wormbase.wormbase_api import WormbaseAPI
import os
import sys
import datetime
import time
import pandas as pd

def ontology_json_to_dataframe(json_obj, wormbase_id, file_name=None):
    rows = []
    row = []
    for category, cat_lst in json_obj.items():
        #print(f"{category=}")
        #print(f"{cat_lst=}")
        row = [wormbase_id]
        if isinstance(cat_lst, dict):
            row.append(cat_lst['id'])
            row.append(category)
            row.append(cat_lst['name'])
            rows.append(row)
            row = [wormbase_id]
        else:
            for cat_lst_item in cat_lst:
                #print(f"{cat_lst_item=}")
                row.append(cat_lst_item['id'])
                row.append(category)
                row.append(cat_lst_item['name'])
                rows.append(row)
                row = [wormbase_id]

    df = pd.DataFrame(rows)
    df.columns=["Wormbase_Id","Go_Id","Category","Name"]
    if file_name:
        df.to_csv(file_name, index=False)
    return df

def get_ontology_data(wormcat_df, category_nm):
    formatted_date = datetime.date.today().strftime('%Y_%m_%d')
    file_name = f"{category_nm.lower().replace(' ', '_')}_references_{formatted_date}.csv"
    
    wormbase_api = WormbaseAPI("field", "gene", "gene_ontology_summary")
    
    concatenated_df = pd.DataFrame()
    dfs = []
    index=0
    number_of_rows=len(wormcat_df)
    for df_index, row in wormcat_df.iterrows():
        print(".", end='')
        index +=1
        #print(f"{index:<4} of {len(transmembrane_transport_df)} {row['wormbase_id']}")
        ret_data = wormbase_api.get_wormbase_data(row['wormbase_id'])
        if 'gene_ontology_summary' in ret_data:
            df = ontology_json_to_dataframe(ret_data['gene_ontology_summary'], row['wormbase_id'])
            dfs.append(df)

        # Concatenate every 100 DataFrames
        # If something crashes we may be able to recover without a full rerun
        if index % 100 == 0:
            print(f"{index:>4} of {number_of_rows} {row['wormbase_id']}")
            concatenated_df = pd.concat([concatenated_df] + dfs, ignore_index=True)
            concatenated_df.to_csv(file_name, index=False)
            dfs = []  # Reset the list for the next batch

    # Concatenate the remaining DataFrames
    if dfs:
        concatenated_df = pd.concat([concatenated_df] + dfs, ignore_index=True)
        concatenated_df.to_csv(file_name, index=False)
    return concatenated_df




if __name__ == "__main__":
    category_data_file = sys.argv[1]
    file_name = category_data_file.replace('\\','')
    df = pd.read_csv(file_name) 
    ontology_df = get_ontology_data(df, df['category_1'].iloc[0])
    ontology_df.to_csv(f"{file_name[:-4]}_out.csv",index=False)
    
    
