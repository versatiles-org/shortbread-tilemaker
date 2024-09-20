#!/usr/bin/env bash
cd "$(dirname "$0")/.."
source bin/lib/utils.sh
set -euo pipefail

mkdir -p data/result
mkdir -p data/tmp

# if you convert the whole planet you need:
# - 170 GB RAM
# - 400 GB SSD
# - time:
#    -  3 minutes for download
#    - 50 minutes for osmium
#    - 70 minutes for tilemaker
#    - 180 minutes for versatiles
BBOX=""
FAST=""
LEVEL=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -b | --bbox)
            BBOX="$2"
            shift # past argument
            shift # past value
            ;;
        -f | --fast)
            FAST=true
            shift # past value
            ;;
        -l | --level)
            LEVEL="$2"
            shift # past argument
            shift # past value
            ;;
        -* | --*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done

if [ ${#POSITIONAL_ARGS[@]} -eq 1 ]; then
    NAME=${POSITIONAL_ARGS[0]};
else
    log_error "need one pbf as source"
fi

ARGS=(
    "--input" "data/osm/$NAME.pbf"
    "--process" "config/process.lua"
    "--output" "data/result/$NAME.mbtiles"
#    "--verbose"
    "--compact"
)

ARGS+=("--config" "config/config.json")

if [[ $BBOX ]]; then
    ARGS+=("--bbox" "$BBOX")
fi

if [[ $FAST ]]; then
    ARGS+=("--fast" "--no-compress-nodes" "--no-compress-ways" "--materialize-geometries")
else
    ARGS+=("--store" "data/tmp")
fi

#jq '.settings.minzoom = 0 | .settings.maxzoom = 14' config/config.json >data/tmp/config.json --config data/tmp/config.json \
log_message "render tiles"
UBSAN_OPTIONS=print_stacktrace=1 time tilemaker "${ARGS[@]}"

rm -rf data/tmp || true
