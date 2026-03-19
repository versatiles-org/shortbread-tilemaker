# Boundary Labels Shape File

The *boundary_labels* layer uses a shape file of labelling points for administrative polygons as data source
because Tilemaker offers a centroid but no PointOnSurface function. This file explains how to create the shape file.

## Content of the Shape File

The shape file must have the following fields:

* `admin_leve`: value of OSM `admin_level=*` tag
* `name`: value of OSM `name=*` tag
* `name_en`: value of OSM `name:en=*` tag
* `name_fr`: value of OSM `name:fr=*` tag
* `name_es`: value of OSM `name:es=*` tag
* `name_de`: value of OSM `name:de=*` tag
* `name_ar`: value of OSM `name:ar=*` tag
* `name_el`: value of OSM `name:el=*` tag
* `name_it`: value of OSM `name:it=*` tag
* `name_nl`: value of OSM `name:nl=*` tag
* `name_pl`: value of OSM `name:pl=*` tag
* `name_pt`: value of OSM `name:pt=*` tag
* `name_uk`: value of OSM `name:uk=*` tag
* `way_area`: polygon area in ha in Web Mercator projection

The features must be sorted by `way_area` in descending order.

The shape file must contain features with `admin_level=2` and `admin_level=4` only.

## Create Shape File using Docker

A Docker image in `admin-points/` bundles PostgreSQL, PostGIS, osm2pgsql, Osmium, and aria2 to generate the shapefile. It automatically downloads the planet PBF via torrent and supports resuming interrupted runs.

### Build the image

```sh
docker build -t admin-points admin-points/
```

### Run

Mount a data directory for downloads, intermediate files, and output:

```sh
docker run --rm -v /path/to/data:/data admin-points
```

The pipeline will:

1. Download the planet PBF via torrent (aria2)
2. Filter for admin boundaries (osmium)
3. Import into PostgreSQL (osm2pgsql)
4. Export the shapefile (pgsql2shp)
5. Clean up intermediate files (~70 GB freed)

The shapefile will be written to `/path/to/data/admin-points-4326/admin_points.shp`.

### Resuming interrupted runs

The pipeline is idempotent. Each step records a marker file on completion. If the container is interrupted, simply rerun the same command — completed steps will be skipped automatically.

To force a step to rerun, delete its marker file in `/path/to/data/.markers/` (e.g. `step3_import`).

### Testing with an existing PBF

To skip the torrent download and use your own PBF:

```sh
# Place your PBF file
cp my-extract.osm.pbf /path/to/data/planet-latest.osm.pbf

# Create the download marker so step 1 is skipped
mkdir -p /path/to/data/.markers
date -Iseconds > /path/to/data/.markers/step1_download

# Run
docker run --rm -v /path/to/data:/data admin-points
```
