#!/bin/bash
# Pull down data from Wormbase and unzip
wb_version=$1
echo "Starting Wormbase Download with version $wb_version"

INPUT_DATA="./wormbase"

get_wormbase_data() {
    local WORMBASE_VERSION="$1"
    local FILE_ROOT="$2"
    local DIR_ROOT="./wormbase"
    local BASE_FTP="ftp://ftp.wormbase.org/pub/wormbase/releases"
    local SPECIES_DIR="species/c_elegans/PRJNA13758/annotation"
    local FILE_PREFIX="c_elegans.PRJNA13758"
    mkdir -p ${DIR_ROOT}
    wget -q -P ${INPUT_DATA} ${BASE_FTP}/${WORMBASE_VERSION}/${SPECIES_DIR}/${FILE_PREFIX}.${WORMBASE_VERSION}.${FILE_ROOT}
    gunzip -f ${INPUT_DATA}/${FILE_PREFIX}.${WORMBASE_VERSION}.${FILE_ROOT}
}

# Pull down geneIDs.txt
get_geneids() {
    local WORMBASE_VERSION="$1"
    get_wormbase_data $WORMBASE_VERSION "geneIDs.txt.gz"
}

# Pull down functional_descriptions.txt
get_functional_descriptions() {
    local WORMBASE_VERSION="$1"
    get_wormbase_data $WORMBASE_VERSION "functional_descriptions.txt.gz"
}

create_geneids_csv() {
    local WORMBASE_VERSION="$1"
    local FILE_PREFIX="c_elegans.PRJNA13758"
    local FILE_ROOT="geneIDs.txt"
    gene_ids_txt="${INPUT_DATA}/${FILE_PREFIX}.${WORMBASE_VERSION}.${FILE_ROOT}"
    # Create GeneIDs.csv
    gene_ids_csv=$(echo "$gene_ids_txt" | sed 's/.\{4\}$//') # remove .txt
    gene_ids_csv="${gene_ids_csv}.csv"                       # add .csv

    # Drop the first column and Only include Live genes
    awk -F',' '$5=="Live" {print $2","$3","$4","$6}' "$gene_ids_txt" > "$gene_ids_csv"
    # Add Header line  
    sed -i '1iWormbase_Id,Gene_name,Sequence_id,Gene_Type' "$gene_ids_csv"
    echo created $gene_ids_csv    
}

# Get GeneId data from wormbase
mkdir -p $INPUT_DATA
get_geneids $wb_version
create_geneids_csv $wb_version
