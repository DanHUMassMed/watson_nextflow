#!/usr/bin/env nextflow 

params.reference_papers_path ="${launchDir}/results/references/${params.reference_papers_csv}"

log.info """\
 P A R A M S -- GET WORMBASE PUBMED IDS
 =====================================
 number_of_batches     : ${params.number_of_batches}
 publish_dir           : ${params.publish_dir}
 reference_papers_path : ${params.reference_papers_path}
 pubmed_ids_csv        : ${params.pubmed_ids_csv}

 """

// import modules
include { SELECT_UNIQUE_DATA   } from '../modules/wormbase'
include { GET_WORMBASE_BATCHES } from '../modules/wormbase'
include { GET_PUBMED_IDS       } from '../modules/wormbase'
include { AGGREGATE_DATA       } from '../modules/wormbase'

/* 
 * main script flow
 */
workflow RUN_GET_PUBMED_IDS {
    SELECT_UNIQUE_DATA (params.reference_papers_path, params.unique_wbp_id)
    GET_WORMBASE_BATCHES( SELECT_UNIQUE_DATA.out, params.number_of_batches )
    GET_PUBMED_IDS ( GET_WORMBASE_BATCHES.out.flatten() )
    AGGREGATE_DATA ( GET_PUBMED_IDS.out.collect(), params.pubmed_ids_csv)
}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone! Wormbase data can be found here --> ${params.publish_dir}\n" : "Oops .. something went wrong" )
}
