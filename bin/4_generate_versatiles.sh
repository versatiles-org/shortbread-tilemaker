#!/usr/bin/env bash
cd "$(dirname "$0")/.."

# if you convert the whole planet you need:
# - 170 GB RAM 
# - 400 GB SSD
# - time:
#    -  3 minutes for download
#    - 50 minutes for osmium
#    - 70 minutes for tilemaker
#    - 180 minutes for versatiles

mkdir -p data

set -e

# reading arguments
TILE_URL=$1 # url of pbf file
TILE_NAME=$2 # name of the result
TILE_BBOX=$3 # bbox

if [[ $TILE_URL != http* ]]
then
    echo "First argument must be a valid URL, e.g. https://download.geofabrik.de/europe/germany/brandenburg-latest.osm.pbf"
    exit 1
fi

if [ -z "$TILE_NAME" ]
then
    echo "Second argument must be a name"
    exit 1
fi

if [ -z "$TILE_BBOX" ]
then
    TILE_BBOX="-180,-86,180,86"
fi

echo "GENERATE OSM VECTOR TILES:"
echo "   URL:  $TILE_URL"
echo "   NAME: $TILE_NAME"
echo "   BBOX: $TILE_BBOX"


echo "RENDER TILES"
tilemaker \
    --input "$FILE_SORTED" \
    --config config/config.json \
    --process config/process.lua \
    --bbox "$TILE_BBOX" \
    --output data/$TILE_NAME.mbtiles \
    --compact \
    --store data/tmp
rm -rf data/tmp || true


exit 0

echo "CONVERT TILES"
file_size=$(stat -c %s data/output.mbtiles)
ram_disk_size=$(perl -E "use POSIX;say ceil($file_size/1073741824 + 0.3)")
mkdir -p ramdisk
mount -t tmpfs -o size=${ram_disk_size}G ramdisk ramdisk
mv data/output.mbtiles ramdisk
time versatiles convert -c brotli ramdisk/output.mbtiles data/output.versatiles

echo "RETURN RESULT"
mv data/output.versatiles "/app/result/${TILE_NAME}.versatiles"
