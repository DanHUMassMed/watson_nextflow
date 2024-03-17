#!/usr/bin/env nextflow 


if(params.run_get_wormbase_papers) {
  include { RUN_GET_WORMBASE_PAPERS } from "./workflows/get_wormbase_papers"
}

if(params.run_get_pubmed_ids) {
  include { RUN_GET_PUBMED_IDS } from "./workflows/get_pubmed_ids"
}

if(params.run_get_pmid_summary) {
  include { RUN_GET_PMID_SUMMARY } from "./workflows/get_pmid_summary"
}



if(params.run_get_gene_ontology_data) {
  include { RUN_GET_GENE_ONTOLOGY_DATA } from "./workflows/get_gene_ontology_data"
}

WorkflowUtils.initialize(params, log)

workflow {
    if(params.run_get_wormbase_papers ) {
        log.info("Running Get Wormbase Papers")
        RUN_GET_WORMBASE_PAPERS() 
    }

    if(params.run_get_pubmed_ids ) {
        log.info("Running Get Pubmed Ids")
        RUN_GET_PUBMED_IDS() 
    }

    if(params.run_get_pmid_summary ) {
        log.info("Running Get PMID Summary")
        RUN_GET_PMID_SUMMARY() 
    }

    if(params.run_get_gene_ontology_data ) {
        log.info("Running Get Gene Ontology Data")
        RUN_GET_GENE_ONTOLOGY_DATA() 
    }
 }