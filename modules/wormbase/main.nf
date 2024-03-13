process GET_WORMBASE_DATA {
    publishDir "${params.data_dir}", mode:'copy'
    conda "dan-dev-sc"

    input:
    val wormbase_version

    output:
    path "wormbase/c_elegans.PRJNA13758.${wormbase_version}.geneIDs.csv", emit: gene_ids_csv

    """
    wormbase_download.sh "$wormbase_version"
    """
}

process GET_WORMBASE_BATCHES {
    publishDir "${params.data_dir}/batches", mode:'copy'
    conda "dan-dev-sc"

    input:
    path gene_ids_csv
    val number_of_batches
    
    output:
    path "batches/wb_*.csv"

    """
    create_wormbase_batches.py "$gene_ids_csv" "$number_of_batches"
    """
}

process GET_WORMBASE_PAPERS {
    publishDir "${params.results_dir}/references", mode:'copy'
    conda "dan-dev-sc"

    input:
    path wb_data_file

    output:
    path "${(wb_data_file.name).substring(0, (wb_data_file.name).length() - 4)}_out.csv"

    """
    get_reference_data.py "$wb_data_file"
    """
}

process AGGREGATE_WORMBASE_PAPERS {
    publishDir "${params.results_dir}/references", mode:'copy'
    conda "dan-dev-sc"

    input:
    path('*')

    output:
    path "wb_reference_papers.csv"

    """
    aggregate_reference_data.py
    """
}

process PROCESS_ONTOLOGIES {
    publishDir "${params.results_dir}/ontology", mode:'copy'
    conda "dan-dev-sc"

    input:
    path category_data_file

    output:
    path "${(category_data_file.name).substring(0, (category_data_file.name).length() - 4)}_out.csv"

    """
    get_gene_ontology_data.py "$category_data_file"
    """
}


