#!/bin/bash
FROM_DATA="./results/ontologies/wb_gene_ontology_data.csv"
TO_DB_DIR="/media/data1/Code/Notebooks/UMass_Med/unknown_genes/input_data/wormbase_db/"
cp ${FROM_DATA} ${TO_DB_DIR}