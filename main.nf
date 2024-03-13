#!/usr/bin/env nextflow 


if(params.run_get_wormbase_papers) {
  include { RUN_GET_WORMBASE_PAPERS } from "./workflows/get_wormbase_papers"
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

    if(params.run_get_gene_ontology_data ) {
        log.info("Running Get Gene Ontology Data")
        RUN_GET_GENE_ONTOLOGY_DATA() 
    }
 }