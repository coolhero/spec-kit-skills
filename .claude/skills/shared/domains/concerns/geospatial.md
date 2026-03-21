# Concern: geospatial

> Lat/lng queries, R-tree/H3 indexing, geo-fencing, distance calculations, map tile serving, reverse geocoding.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: geospatial, GIS, latitude, longitude, geo-fencing, spatial index, map tiles, geocoding, PostGIS, coordinate system

**Secondary**: R-tree, H3, S2, bounding box, polygon, geohash, spatial query, distance calculation, Haversine, great circle, reverse geocode, tile server, vector tiles, raster tiles, WGS84, EPSG

### Code Patterns (R1 — for source analysis)

- Databases: PostGIS, MongoDB `2dsphere`, Redis `GEOADD`/`GEOSEARCH`, Elasticsearch geo queries, SpatiaLite
- Libraries: `turf.js`, `geolib`, `shapely`, `geopandas`, `h3-js`, `s2geometry`, `jts` (Java), `geo` (Rust)
- Tile servers: `mapbox-gl`, `leaflet`, `openlayers`, `deck.gl`, `maplibre`
- Patterns: `ST_DWithin`, `ST_Contains`, `ST_Intersects`, `GeoJSON`, `Point`, `Polygon`, `Feature`, `FeatureCollection`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: http-api, data-io
- **Profiles**: —
