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

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python select_unique.py <input_csv_file> <unique_field>")
        sys.exit(1)

    input_csv_file = sys.argv[1]
    unique_field   = sys.argv[2]

    output_csv_file = os.path.basename(input_csv_file)
    output_csv_file = "unique_"+output_csv_file
    input_df = pd.read_csv(input_csv_file)
    unique_df = input_df.drop_duplicates(subset=[unique_field], keep='first')
    unique_df.to_csv(output_csv_file, index=False)



    
