# Concern: geospatial (reverse-spec)

> Geospatial capability detection. Identifies spatial indexing, geo-queries, and map rendering patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/geospatial.md`](../../../shared/domains/concerns/geospatial.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Spatial database and index type (PostGIS, H3, R-tree, geohash)
- Query patterns (proximity, containment, intersection) and performance characteristics
- Coordinate system and projection usage (WGS84, UTM)
- Map tile serving architecture (vector vs raster, self-hosted vs provider)
- Geocoding provider and caching strategy
- Geo-fencing implementation and event handling
