
process PARSE_WORMCAT_CATEGORIES {
    publishDir "${params.results_dir}/wormcat", mode:'copy'
    conda "dan-dev-sc"

    input:
    path wormcat_db
    val category

    output:
    path 'wc_*.csv'

    """
    parse_wormcat_categorie.py "$wormcat_db" "$category"
    """
}



process PROCESS_CATEGORY {
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

params.category_pag_names=["Transcription: unassigned", "Transmembrane protein", "Transmembrane transport", "Unassigned"]
params.wormcat_db_file = "${launchDir}/data/whole_genome_v2_nov-11-2021.csv"
params.results_dir = "${launchDir}/results"
WorkflowUtils.initialize(params, log)

workflow {
    category_ch = channel.fromList(params.category_pag_names)
    PARSE_WORMCAT_CATEGORIES(params.wormcat_db_file, category_ch)|
    PROCESS_CATEGORY
}
