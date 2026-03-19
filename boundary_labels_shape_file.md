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

A Docker image in `admin-points/` bundles PostgreSQL, PostGIS, osm2pgsql, and Osmium to generate the shapefile in a single step.

### Build the image

```sh
docker build -t admin-points admin-points/
```

### Run

Mount the planet PBF file and an output directory:

```sh
docker run --rm \
  -v /path/to/planet-latest.osm.pbf:/data/planet-latest.osm.pbf:ro \
  -v ./data/admin-points-4326:/data/admin-points-4326 \
  admin-points
```

The shapefile will be written to `data/admin-points-4326/admin_points.shp`.
