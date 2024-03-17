#!/usr/bin/env nextflow 

log.info """\
 P A R A M S -- GET GENE ONTOLOGY DATA
 =====================================
 wormbase_version       : ${params.wormbase_version}
 number_of_batches      : ${params.number_of_batches}
 gene_ontology_data_csv : ${params.gene_ontology_data_csv}
 publish_dir            : ${params.publish_dir}
 """

// import modules
include { GET_WORMBASE_DATA       } from '../modules/wormbase'
include { GET_WORMBASE_BATCHES    } from '../modules/wormbase'
include { GET_GENE_ONTOLOGY_DATA  } from '../modules/wormbase'
include { AGGREGATE_DATA          } from '../modules/wormbase'

/* 
 * main script flow
 */
workflow RUN_GET_GENE_ONTOLOGY_DATA {
    GET_WORMBASE_DATA ( params.wormbase_version )
    GET_WORMBASE_BATCHES( GET_WORMBASE_DATA.out.gene_ids_csv, params.number_of_batches )
    GET_GENE_ONTOLOGY_DATA ( GET_WORMBASE_BATCHES.out.flatten() )
    AGGREGATE_DATA ( GET_GENE_ONTOLOGY_DATA.out.collect(), params.gene_ontology_data_csv )
}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone! Wormbase data can be found here --> ${params.publish_dir}\n" : "Oops .. something went wrong" )
}
