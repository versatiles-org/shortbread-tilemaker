#!/usr/bin/env bash
cd "$(dirname "$0")/.."
source bin/lib/utils.sh
set -euo pipefail

mkdir -p data/osm
cd data/osm

# reading arguments
URL=$1 # url of pbf file
NAME=$2 # name of the result

if [[ $URL != http* ]]
then
    log_error "First argument must be a valid URL, e.g. https://download.geofabrik.de/europe/germany/brandenburg-latest.osm.pbf"
    exit 1
fi

if [ -z "$NAME" ]
then
    log_error "Second argument must be the name"
    exit 1
fi



FILE_OUTPUT="${NAME}.pbf"
FILE_UNSORTED="${NAME}.raw.pbf"
if [[ ! -f $FILE_UNSORTED ]]; then
    log_message "download data"
    download "$URL" "$FILE_UNSORTED"
else
    log_message "data already downloaded"
fi


if [[ ! -f $FILE_OUTPUT ]]; then
    log_message "sort data"
    osmium renumber --progress -o "$FILE_OUTPUT" "$FILE_UNSORTED"
else
    log_message "data already sorted"
fi
