#!/usr/bin/env python3
import sys
import pandas as pd

if __name__ == "__main__":
    wormcat_db = sys.argv[1]
    category = sys.argv[2]

    # Load the Wormbase Annotation List
    wormcat_df = pd.read_csv(f"{wormcat_db}") 
    wormcat_df = wormcat_df.rename(columns={'Sequence ID':'wc_sequence_id','Wormbase ID':'wormbase_id','Category 1':'category_1','Category 2':'category_2','Category 3':'category_3'})
    wormcat_df = wormcat_df.drop(columns=['Automated Description'])
    df = wormcat_df.query(f"category_1 == '{category}'")
    file_name = f"wc_{category.lower().replace(' ', '_')}.csv"
    df.to_csv(file_name, index=False)

    # category1 = wormcat_df['category_1'].unique()
    # for category in category1:
    #     df = wormcat_df.query(f"category_1 == '{category}'")
    #     file_name = f"wc_{category.lower().replace(' ', '_')}.csv"
    #     df.to_csv(file_name, index=False)


