#!/usr/bin/env nextflow 

params.pubmed_ids_path ="${launchDir}/results/pubmed_ids/${params.pubmed_ids_csv}"

log.info """\
 P A R A M S -- GET WORMBASE PUBMED IDS
 =====================================
 number_of_batches   : ${params.number_of_batches}
 publish_dir         : ${params.publish_dir}
 pubmed_ids_path     : ${params.pubmed_ids_path}
 pmid_summary_csv      : ${params.pmid_summary_csv}

 """

// import modules

include { GET_WORMBASE_BATCHES } from '../modules/wormbase'
include { GET_PMID_SUMMARY     } from '../modules/wormbase'
include { AGGREGATE_DATA       } from '../modules/wormbase'
include { GET_PMID_JOIN        } from '../modules/wormbase'

/* 
 * main script flow
 */
workflow RUN_GET_PMID_SUMMARY {
    GET_WORMBASE_BATCHES( params.pubmed_ids_path, params.number_of_batches )
    GET_PMID_SUMMARY ( GET_WORMBASE_BATCHES.out.flatten() )
    AGGREGATE_DATA ( GET_PMID_SUMMARY.out.collect(), params.pmid_summary_csv)
    GET_PMID_JOIN  ( AGGREGATE_DATA.out, params.pubmed_ids_path)

}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone! Wormbase data can be found here --> ${params.publish_dir}\n" : "Oops .. something went wrong" )
}
