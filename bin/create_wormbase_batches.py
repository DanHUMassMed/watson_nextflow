#!/usr/bin/env python3
import sys
import os
import pandas as pd

OUTPUT_DIR="./batches"

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python create_wormbase_batches.py <gene_ids_csv> <number_of_batches>")
        sys.exit(1)

    gene_ids_csv = sys.argv[1]
    number_of_batches = sys.argv[2]

    gene_ids_df = pd.read_csv(f"{gene_ids_csv}")
    gene_ids_df = gene_ids_df[gene_ids_df["Gene_Type"] != "piRNA_gene"]
    gene_ids_df.reset_index(drop=True, inplace=True)

    if not os.path.exists(OUTPUT_DIR):
        # Create the directory if it does not exist
        os.makedirs(OUTPUT_DIR)

    # Calculate the batch size
    batch_size = len(gene_ids_df) // int(number_of_batches)

    # Create a batch ID column
    gene_ids_df = gene_ids_df.copy()
    gene_ids_df["batch_id"] = (gene_ids_df.index // batch_size) + 1

    # Iterate over unique batch IDs
    for batch_id in gene_ids_df["batch_id"].unique():
        # Filter DataFrame for the current batch ID
        batch_df = gene_ids_df[gene_ids_df["batch_id"] == batch_id].copy()
        # Drop the batch_id column as it's no longer needed for individual batch files
        batch_df.drop("batch_id", axis=1, inplace=True)
        # Write the batch to a CSV file
        batch_df.to_csv(f"{OUTPUT_DIR}/wb_batch_{batch_id}.csv", index=False)