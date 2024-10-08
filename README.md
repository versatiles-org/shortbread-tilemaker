# Shortbread Vector Tiles – Tilemaker Configuration

This Git repository contains the Tilemaker configuration files in order to produce
vector tiles in the Shortbread schema.

* [Instructions](https://shortbread.geofabrik.de/make-vectortiles/)
* [Schema documentation](https://shortbread.geofabrik.de/schema/)

## Authors

This set of configuration files has been created for Geofabrik by Michael Reichert 
and Amanda McCann before it was put on Github. Further contributors may be visible 
in the git history.

## License and Copyright

Because this set of configuration files is intended to go with the tilemaker software,
it is released under the same license as tilemaker itself, the [FTWPL license](./LICENCE.txt).


```bash
./bin/1_download_shapefiles.sh
./bin/2_download_osm.sh https://download.geofabrik.de/europe/germany/brandenburg-latest.osm.pbf brandenburg
./bin/3_generate_mbtiles.sh brandenburg 11.2,51.3,14.8,53.6
```
