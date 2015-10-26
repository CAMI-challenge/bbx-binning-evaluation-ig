#!/bin/bash

# exit script if one command fails
set -o errexit

# exit script if Variable is not set
set -o nounset

INPUT="${BBX_MNTDIR:-/bbx}/mnt/input/biobox.yaml"
OUTPUT="${BBX_MNTDIR:-/bbx}/mnt/output"
METADATA=/bbx/mnt/metadata

#validate yaml
validate-biobox-file --schema /schema.yaml --input $INPUT

# create cache
CACHE="${BBX_CACHEDIR:-/bbx/mnt/cache}"
mkdir -p "$CACHE"

# Since this script is the entrypoint to your container
# you can access the task in `docker run task` as the first argument
TASK=${1:-default}

# Ensure the biobox.yaml file is valid
#validate-biobox-file \
#  --input ${INPUT} \
#  --schema /schema.yaml \

# check if output folder exists/is mounted
if ! [ -d "$OUTPUT" ]; then
  echo "$OUTPUT does not exist."
  exit 1
fi

# Parse the read locations from this file
FASTA=$(yaml2json < $INPUT  | jq --raw-output '.arguments.sequences.path')
BINNING_TRUE=$(yaml2json < $INPUT | jq --raw-output '.arguments.labels.path')
BINNING_ASSIGNMENTS=$(yaml2json < $INPUT  | jq --raw-output '.arguments.predictions.path')
DATABASES=$(yaml2json < $INPUT  | jq --raw-output '.arguments.databases.taxonomy.path')

# Use grep to get $TASK in /Taskfile
CMD=$(egrep ^${TASK}: /Taskfile | cut -f 2 -d ':')
if [[ -z ${CMD} ]]; then
  echo "Abort, no task found for '${TASK}'."
  exit 1
fi

# Functions
binning2tax() { cat $@ | grep -v -e '^@' -e '^#' -e '^$' | cut -f 1,2; } # bioboxes.org binning to simple TAB-separated

#create temporary directory in /tmp
TMP_DIR="$(mktemp -d)"

# Convert binning files to two-column TSV
TAX_ASSIGNMENTS="$TMP_DIR/prediction.tax"
binning2tax "$BINNING_ASSIGNMENTS" > "$TAX_ASSIGNMENTS"
TAX_TRUE="$TMP_DIR/label.tax"
binning2tax "$BINNING_TRUE" > "$TAX_TRUE"

# if /bbx/metadata is mounted create log.txt
if [ -d "$METADATA" ]; then
  CMD="($CMD) >& $METADATA/log.txt"
fi

# Run the given task with eval.
# Eval evaluates a String as if you would use it on a command line.
eval ${CMD}
