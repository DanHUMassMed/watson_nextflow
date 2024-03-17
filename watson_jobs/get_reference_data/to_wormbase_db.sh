#!/bin/bash
FROM_DATA="./results/references/wb_reference_papers.csv"
FROM_DATA="./results/pmid_summary/wb_wbp_id_summary.csv"
TO_DB_DIR="/media/data1/Code/Notebooks/UMass_Med/unknown_genes/input_data/wormbase_db/"
#diff ${FROM_DATA} ${TO_DB_DIR}
#grep -o 'WBGene[0-9]*' file.txt | sort -u
cp ${FROM_DATA} ${TO_DB_DIR}