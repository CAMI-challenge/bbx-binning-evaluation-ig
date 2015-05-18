#!/bin/bash

# exit script if one command fails
set -o errexit

# exit script if Variable is not set
set -o nounset

INPUT=/bbx/input/biobox.yaml
OUTPUT=/bbx/output
METADATA=/bbx/metadata

# Since this script is the entrypoint to your container
# you can access the task in `docker run task` as the first argument
TASK=$1

# Ensure the biobox.yaml file is valid
validate-biobox-file \
  --input ${INPUT} \
  --schema /schema.yaml \

mkdir -p ${OUTPUT}

# Parse the read locations from this file
FASTA=$(yaml2json < $INPUT  | jq --raw-output '.arguments[] | select(.fasta) | .fasta | .value  ' )
BINNING_TRUE=$(yaml2json < $INPUT | jq --raw-output ' .arguments[] | select(.binning) | .binning[] | select(.type == true) | .value ' )
BINNING_ASSIGNMENTS=$(yaml2json < $INPUT  | jq --raw-output ' .arguments[] | select(.binning) | .binning[] | select(.type == "assignments") | .value ')
SCAFFOLD_CONTIG_MAPPING=$(yaml2json < $INPUT  | jq --raw-output '  .arguments[] | select(.scaffold_contig_mapping) | .scaffold_contig_mapping ')
DATABASES=$(yaml2json < $INPUT  | jq --raw-output ' .arguments[] | select(.databases) | .databases[] | select(.id == "ncbi_taxonomy") | .value ')

#create temporary directory in /tmp
TMP_DIR=$(mktemp -d)

# Use grep to get $TASK in /Taskfile
CMD=$(egrep ^${TASK}: /Taskfile | cut -f 2 -d ':')
if [[ -z ${CMD} ]]; then
  echo "Abort, no task found for '${TASK}'."
  exit 1
fi

# if /bbx/metadata is mounted create log.txt
if [ -d "$METADATA" ]; then
  CMD="($CMD) >& $METADATA/log.txt"
fi

# Run the given task with eval.
# Eval evaluates a String as if you would use it on a command line.
eval ${CMD}
