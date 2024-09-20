#!/bin/bash
# Change to the script's parent directory
cd "$(dirname "$0")/.."
source bin/lib/utils.sh

# Exit on error, uninitialized variable use, or pipefail
set -euo pipefail

# Ensure the 'data' directory exists and enter it
mkdir -p data/shapefiles
cd data/shapefiles


# Function to download and extract files only if ETag has changed
function download_and_extract {
    local URL=$1
    local FILE="${URL##*/}"
    local FILE_ETAG="${FILE}.etag"

    # Retrieve the ETag from the server and compare with the stored ETag
    local NEW_ETAG=$(curl -sI "$URL" | grep -i "^ETag:" | awk '{print $2}' | tr -d '"')
    local OLD_ETAG=$( [[ -f "$FILE_ETAG" ]] && cat "$FILE_ETAG" || echo '')

    if [[ "$NEW_ETAG" == "$OLD_ETAG" ]]; then
        log_message "No changes detected for $FILE"
        return
    fi

    # Download the file if ETag is different
    log_message "Download new \"$FILE\""
    download "$URL" "$FILE"
    echo "$NEW_ETAG" >"$FILE_ETAG"

    # Unzip the file, overwriting old files without prompting
    log_message "Unzipping ..."
    unzip -qou "$FILE"

    rm "$FILE"
}

# Function to transform shapefile projections
function transform_shp {
    local FILE=$1
    local OUT_FILE=$2

    # Use ogr2ogr to convert the shapefile to the specified projection
    ogr2ogr -f "ESRI Shapefile" "$OUT_FILE" "$FILE" -t_srs EPSG:4326 -lco ENCODING=utf8
}

# Download and extract shapefiles
download_and_extract "https://osmdata.openstreetmap.de/download/water-polygons-split-4326.zip"
download_and_extract "https://osmdata.openstreetmap.de/download/simplified-water-polygons-split-3857.zip"
download_and_extract "https://shortbread-tiles.org/shapefiles/admin-points-4326.zip"

# If directory exists, transform shapefile and cleanup
if [[ -d simplified-water-polygons-split-3857 ]]; then
    mkdir -p simplified-water-polygons-split-4326
    log_message "Transforming water polygons"
    transform_shp simplified-water-polygons-split-3857/simplified_water_polygons.shp simplified-water-polygons-split-4326/simplified_water_polygons.shp
    rm -r simplified-water-polygons-split-3857
fi
