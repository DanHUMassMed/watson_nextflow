
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




params.category_pag_names=["Transcription: unassigned", "Transmembrane protein", "Transmembrane transport", "Unassigned"]
//params.category_names=["Peroxisome"]
//params.category_names=["Cell cycle", "Chaperone", "Cilia", "Cytoskeleton", "Development", "DNA" ]
//params.category_names= ["Extracellular material", "Globin", "Lysosome", "Major sperm protein", "Metabolism", "mRNA functions", "Muscle function"]
//params.category_names=["Neuronal function", "Nuclear pore", "Nucleic acid", "Protein modification", "Proteolysis general", "Proteolysis proteasome", "Ribosome", "Signaling"]
//params.category_names=["Stress response", "Trafficking", "Transcription factor", "Transcription: chromatin",  "Transcription: dosage compensation", "Transcription: general machinery"]

//params.category_not_covered_names=["Non-coding RNA", "Pseudogene"]
params.category_not_covered_names=["Pseudogene"]

params.wormcat_db_file = "${launchDir}/data/whole_genome_v2_nov-11-2021.csv"
params.results_dir = "${launchDir}/results"
WorkflowUtils.initialize(params, log)

workflow {
    category_ch = channel.fromList(params.category_not_covered_names)
    PARSE_WORMCAT_CATEGORIES(params.wormcat_db_file, category_ch)|
    PROCESS_CATEGORY
}
