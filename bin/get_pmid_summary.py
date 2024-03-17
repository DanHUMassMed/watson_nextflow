#!/usr/bin/env python3

import json
import os 
import sys
import logging
import logging.config
import pandas as pd
from pub_worm.impact_factor.impact_factor_lookup import get_impact_factor
from pub_worm.ncbi.entreze_post import entreze_epost, entreze_pmid_summaries
try:
    logging.config.fileConfig('logging.config')
except Exception:
    file_path = os.path.abspath(__file__)
    file_name = os.path.basename(file_path)
    logging.basicConfig(filename=f"pub_worm_{file_name}.log", level=logging.DEBUG)

logger = logging.getLogger(__name__)

def check_issn_essn(json_data):
    if json_data.get("issn", None) not in ["", None]:
        return json_data["issn"]
    elif json_data.get("essn", None) not in ["", None]:
        return json_data["essn"]
    else:
        return None

def pmid_summary_to_dataframe(list_of_json):
    rows = []
    row = []
    df = pd.DataFrame()

    for pmid_summary in list_of_json:
        if isinstance(pmid_summary, dict):
            row.append(pmid_summary['uid'])
            row.append(pmid_summary['issn'])
            row.append(pmid_summary['essn'])
            row.append(pmid_summary['last_author'])
            row.append(pmid_summary['pmc_id'])
            issn_essn = check_issn_essn(pmid_summary)
            imapact_factor = None
            if issn_essn:
                imapact_factor = get_impact_factor(issn_essn)
            pmid_summary['impact_factor']=imapact_factor
            row.append(pmid_summary['impact_factor'])
            rows.append(row)
            row = []

    logger.debug(f"pmid_summary_to_dataframe has {len(rows)} rows")
    if rows:
        df = pd.DataFrame(rows)
        df.columns=["pm_id", "pm_issn", "pm_essn", "pm_last_author", "pm_pmc_id", "impact_factor"]

    logger.debug(f"df has type {type(df)}")
    return df


def get_pmid_summary(batch_file_nm):
    out_file_nm = batch_file_nm.replace(".csv", "_out.csv")
    pmid_df = pd.read_csv(batch_file_nm)
    uids = list(pmid_df['pm_id'])
    uids = [str(uid) for uid in  uids] 

    list_of_json = []
    logger.debug(f"We are sending a list of {len(uids)} pm_ids")
    ret_data =entreze_epost({}, uids)
    if 'WebEnv' in ret_data:
        list_of_json = entreze_pmid_summaries(ret_data)
        df = pmid_summary_to_dataframe(list_of_json)
        if not df.empty:
            df.to_csv(out_file_nm, index=False)
        else:
            logger.error("get_pmid_summary - No dataframe to write")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python get_pmid_summary.py <pmid>")
        sys.exit(1)

    wb_data_file = sys.argv[1]
    file_name = wb_data_file.replace('\\','')
    get_pmid_summary(file_name)


