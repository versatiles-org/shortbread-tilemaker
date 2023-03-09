## Admin

tilemaker can read shapefiles, Geofabrik has prepared shapefiles for water polygons and labels of administrative areas.
admin.geojson overrides the prepared geofabrik labels, fixes some placement problems and provides sensible labeling options for `name`.

## Prepare Planet

Osmium can filter the planet file to only retain data that is actually needed by tilemaker, and reassign the ids so tilemaker needs less memory

`osmium tags-filter --progress -e versatiles/osmium-filters -o <planet-filtered.osm.pbf> <planet.osm.pbf>`
`osmium renumber --progress -o <planet-renumbered.osm.pbf> <planet-filtererd.osm.pbf>`
