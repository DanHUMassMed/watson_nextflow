#!/bin/bash
email=$(echo "$USER" | cut -d'-' -f1)
email=${email}@umassmed.edu
nextflow -c config/this_run.config run ../..  -resume
#nextflow -c config/this_run.config run ../..  -resume -bg
#nextflow -c conf/experiment.config run ../../RNA-Seq-Nextflow ./run    