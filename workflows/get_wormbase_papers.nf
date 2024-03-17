#!/usr/bin/env nextflow 

log.info """\
 P A R A M S -- GET WORMBASE PAPERS
 =====================================
 wormbase_version      : ${params.wormbase_version}
 number_of_batches     : ${params.number_of_batches}
 reference_papers_csv  : ${params.reference_papers_csv}
 publish_dir           : ${params.publish_dir}
 """

// import modules
include { GET_WORMBASE_DATA    } from '../modules/wormbase'
include { GET_WORMBASE_BATCHES } from '../modules/wormbase'
include { GET_WORMBASE_PAPERS  } from '../modules/wormbase'
include { AGGREGATE_DATA       } from '../modules/wormbase'

/* 
 * main script flow
 */
workflow RUN_GET_WORMBASE_PAPERS {
    GET_WORMBASE_DATA ( params.wormbase_version )
    GET_WORMBASE_BATCHES( GET_WORMBASE_DATA.out.gene_ids_csv, params.number_of_batches )
    GET_WORMBASE_PAPERS ( GET_WORMBASE_BATCHES.out.flatten() )
    AGGREGATE_DATA ( GET_WORMBASE_PAPERS.out.collect(), params.reference_papers_csv )
}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone! Wormbase data can be found here --> ${params.publish_dir}\n" : "Oops .. something went wrong" )
}
