#!/usr/bin/env python3

import json
import os 
import sys
import logging
import logging.config
import pandas as pd

try:
    logging.config.fileConfig('logging.config')
except Exception:
    file_path = os.path.abspath(__file__)
    file_name = os.path.basename(file_path)
    logging.basicConfig(filename=f"pub_worm_{file_name}.log", level=logging.DEBUG)

logger = logging.getLogger(__name__)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python get_pmid_join.py <pmid_summary_csv> <pubmed_ids_csv>")
        sys.exit(1)

    wb_pmid_summary_csv = sys.argv[1]
    wb_pubmed_ids_csv  = sys.argv[2]
    wb_pmid_summary_df = pd.read_csv(wb_pmid_summary_csv)
    wb_pubmed_ids_df = pd.read_csv(wb_pubmed_ids_csv)

    merged_df = pd.merge(wb_pubmed_ids_df, wb_pmid_summary_df, on='pm_id', how='left')
    merged_df.to_csv("wb_wbp_id_summary.csv", index=False)




