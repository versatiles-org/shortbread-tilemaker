This data is used as supplementary data to create vector tiles in
the Shortbread vector tile schema.

See boundary_labels_shape_file.md for how to regenerate this data.


PACKAGE CONTENT
===============

This package contains points to label administrative polygons. The
points are derived from OpenStreetMap data by using the
`ST_PointOnSurface` function.

Fields:

* `admin_leve`: value of the OSM `admin_level` key.
* `name`: value of the OSM `name` key.
* `name_en`: value of the OSM `name:en` key.
* `name_fr`: value of the OSM `name:fr` key.
* `name_es`: value of the OSM `name:es` key.
* `name_de`: value of the OSM `name:de` key.
* `name_ar`: value of the OSM `name:ar` key.
* `name_el`: value of the OSM `name:el` key.
* `name_it`: value of the OSM `name:it` key.
* `name_nl`: value of the OSM `name:nl` key.
* `name_pl`: value of the OSM `name:pl` key.
* `name_pt`: value of the OSM `name:pt` key.
* `name_uk`: value of the OSM `name:uk` key.
* `way_area`: area of the boundary polygon in Web Mercator in ha.


LICENSE
=======

This data is Copyright OpenStreetMap contributors. It is
available under the Open Database License (ODbL).

For more information see https://www.openstreetmap.org/copyright

