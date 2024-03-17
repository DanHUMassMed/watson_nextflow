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
    publishDir "${params.data_dir}", mode:'copy', overwrite: true
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
    maxForks 10

    input:
    path wb_data_file

    output:
    path "${(wb_data_file.name).substring(0, (wb_data_file.name).length() - 4)}_out.csv", optional: true

    """
    get_reference_data.py "$wb_data_file"
    """
}


process GET_GENE_ONTOLOGY_DATA {
    publishDir "${params.results_dir}/ontologies", mode:'copy'
    conda "dan-dev-sc"
    maxForks 10

    input:
    path wb_data_file

    output:
    path "${(wb_data_file.name).substring(0, (wb_data_file.name).length() - 4)}_out.csv", optional: true

    """
    get_gene_ontology_data.py "$wb_data_file"
    """
}


process GET_PUBMED_IDS {
    publishDir "${params.results_dir}/pubmed_ids", mode:'copy'
    conda "dan-dev-sc"
    maxForks 10

    input:
    path wb_data_file

    output:
    path "${(wb_data_file.name).substring(0, (wb_data_file.name).length() - 4)}_out.csv", optional: true

    """
    get_pubmed_ids.py "$wb_data_file"
    """
}

process GET_PMID_SUMMARY {
    publishDir "${params.results_dir}/pmid_summary", mode:'copy'
    conda "dan-dev-sc"
    maxForks 1

    input:
    path wb_data_file

    output:
    path "${(wb_data_file.name).substring(0, (wb_data_file.name).length() - 4)}_out.csv", optional: true

    """
    get_pmid_summary.py "$wb_data_file"
    """
}

process AGGREGATE_DATA {
    publishDir "${params.publish_dir}", mode:'copy'
    conda "dan-dev-sc"

    input:
    path('*')
    val out_file_nm

    output:
    path "${out_file_nm}"

    """
    aggregate_data.py "${out_file_nm}"
    """
}


process SELECT_UNIQUE_DATA {
    publishDir "${params.publish_dir}", mode:'copy'
    conda "dan-dev-sc"

    input:
    path input_csv_file
    val unique_field

    output:
    path "unique_${input_csv_file.name}"

    """
    select_unique.py "${input_csv_file}" "${unique_field}"
    """
}


process GET_PMID_JOIN {
    publishDir "${params.publish_dir}", mode:'copy'
    conda "dan-dev-sc"

    input:
    path pmid_summary_csv
    path wb_pubmedp_ids

    output:
    path "wb_wbp_id_summary.csv"

    """
    get_pmid_join.py "${pmid_summary_csv}" "${wb_pubmedp_ids}"
    """
}
