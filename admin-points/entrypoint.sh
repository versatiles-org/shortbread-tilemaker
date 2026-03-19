#!/bin/bash
set -euo pipefail

INPUT_PBF="/data/planet-latest.osm.pbf"
OUTPUT_DIR="/data/admin-points-4326"

if [ ! -f "$INPUT_PBF" ]; then
  echo "Error: $INPUT_PBF not found. Mount it via -v /path/to/planet-latest.osm.pbf:$INPUT_PBF"
  exit 1
fi

echo "=== Step 1: Filter planet dump ==="
osmium tags-filter --progress \
  -o /tmp/admin.osm.pbf --overwrite \
  "$INPUT_PBF" \
  r/boundary=administrative r/admin_level=2 r/admin_level=4

echo "=== Step 2: Start PostgreSQL ==="
pg_ctlcluster 17 main start
su postgres -c "psql -c \"CREATE DATABASE adminpolygons;\""
su postgres -c "psql -d adminpolygons -c \"CREATE EXTENSION postgis;\""
su postgres -c "psql -d adminpolygons -c \"CREATE EXTENSION hstore;\""

echo "=== Step 3: Import with osm2pgsql ==="
su postgres -c "osm2pgsql -d adminpolygons --hstore --multi-geometry --latlong /tmp/admin.osm.pbf"

echo "=== Step 4: Export shapefile ==="
mkdir -p "$OUTPUT_DIR"
su postgres -c "pgsql2shp -f /tmp/admin_points.shp adminpolygons \"
  SELECT
    admin_level AS admin_leve,
    name,
    tags->'name:en' AS name_en,
    tags->'name:fr' AS name_fr,
    tags->'name:es' AS name_es,
    tags->'name:de' AS name_de,
    tags->'name:ar' AS name_ar,
    tags->'name:el' AS name_el,
    tags->'name:it' AS name_it,
    tags->'name:nl' AS name_nl,
    tags->'name:pl' AS name_pl,
    tags->'name:pt' AS name_pt,
    tags->'name:uk' AS name_uk,
    ST_Area(ST_Transform(way, 3857)) / 10000 AS way_area,
    ST_PointOnSurface(way) AS geom
  FROM planet_osm_polygon
  WHERE osm_id < 0
    AND boundary = 'administrative'
    AND admin_level IN ('2', '4')
  ORDER BY way_area DESC;
\""

cp /tmp/admin_points.{shp,shx,dbf,prj} "$OUTPUT_DIR/"
# Create cpg file for UTF-8 encoding
echo "UTF-8" > "$OUTPUT_DIR/admin_points.cpg"

echo "=== Step 5: Shutdown PostgreSQL ==="
pg_ctlcluster 17 main stop

echo "=== Done ==="
echo "Shapefile written to $OUTPUT_DIR/"
