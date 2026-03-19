#!/bin/bash
set -euo pipefail

PLANET_PBF="/data/planet-latest.osm.pbf"
FILTERED_PBF="/data/admin-filtered.osm.pbf"
OUTPUT_DIR="/data/admin-points-4326"
PGDATA="/data/pgdata"
MARKERS="/data/.markers"
TORRENT_URL="https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf.torrent"

export PGDATA

step_done() { [ -f "$MARKERS/$1" ]; }
mark_done() { mkdir -p "$MARKERS"; date -Iseconds > "$MARKERS/$1"; }

start_postgres() {
  if ! su postgres -c "pg_isready" &>/dev/null; then
    echo "Starting PostgreSQL..."
    if [ ! -f "$PGDATA/PG_VERSION" ]; then
      mkdir -p "$PGDATA"
      chown postgres:postgres "$PGDATA"
      su postgres -c "initdb -D $PGDATA"
    fi
    su postgres -c "pg_ctl -D $PGDATA -l /tmp/pg.log start"
    # Wait for PostgreSQL to be ready
    until su postgres -c "pg_isready" &>/dev/null; do sleep 1; done
  fi
}

stop_postgres() {
  if su postgres -c "pg_isready" &>/dev/null; then
    echo "Stopping PostgreSQL..."
    su postgres -c "pg_ctl -D $PGDATA stop"
  fi
}

# === Step 1: Download planet PBF via torrent ===
if step_done step1_download; then
  echo "Step 1: Download already complete, skipping."
else
  echo "=== Step 1: Download planet PBF ==="
  aria2c \
    --seed-time=0 \
    --continue=true \
    --check-integrity=true \
    --dir=/data \
    --out=planet-latest.osm.pbf \
    "$TORRENT_URL"
  mark_done step1_download
fi

# === Step 2: Filter with osmium ===
if step_done step2_filter; then
  echo "Step 2: Filter already complete, skipping."
else
  echo "=== Step 2: Filter planet dump ==="
  osmium tags-filter --progress \
    -o "$FILTERED_PBF" --overwrite \
    "$PLANET_PBF" \
    r/boundary=administrative r/admin_level=2 r/admin_level=4
  mark_done step2_filter
fi

# === Step 3: Import into PostgreSQL ===
if step_done step3_import; then
  echo "Step 3: Import already complete, skipping."
else
  echo "=== Step 3: Import with osm2pgsql ==="
  start_postgres

  # Create database if it doesn't exist
  if ! su postgres -c "psql -lqt" | cut -d\| -f1 | grep -qw adminpolygons; then
    su postgres -c "psql -c 'CREATE DATABASE adminpolygons;'"
    su postgres -c "psql -d adminpolygons -c 'CREATE EXTENSION postgis;'"
    su postgres -c "psql -d adminpolygons -c 'CREATE EXTENSION hstore;'"
  fi

  su postgres -c "osm2pgsql -d adminpolygons -s --hstore --multi-geometry --latlong $FILTERED_PBF"
  mark_done step3_import
fi

# === Step 4: Export shapefile ===
if step_done step4_export; then
  echo "Step 4: Export already complete, skipping."
else
  echo "=== Step 4: Export shapefile ==="
  start_postgres

  mkdir -p "$OUTPUT_DIR"

  # Create a view to avoid quoting issues with pgsql2shp
  su postgres -c "psql -d adminpolygons -f -" <<'EOSQL'
CREATE OR REPLACE VIEW admin_export AS
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
EOSQL

  su postgres -c "pgsql2shp -f /tmp/admin_points.shp adminpolygons admin_export"

  cp /tmp/admin_points.{shp,shx,dbf,prj} "$OUTPUT_DIR/"
  echo "UTF-8" > "$OUTPUT_DIR/admin_points.cpg"
  mark_done step4_export
fi

# === Step 5: Cleanup intermediate files ===
if step_done step5_cleanup; then
  echo "Step 5: Cleanup already complete, skipping."
else
  echo "=== Step 5: Cleanup ==="
  stop_postgres
  rm -f "$PLANET_PBF"
  rm -f "$FILTERED_PBF"
  rm -rf "$PGDATA"
  mark_done step5_cleanup
fi

stop_postgres 2>/dev/null || true

echo "=== Done ==="
echo "Shapefile written to $OUTPUT_DIR/"
