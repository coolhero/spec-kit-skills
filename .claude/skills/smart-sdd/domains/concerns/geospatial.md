# Concern: geospatial

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> Lat/lng queries, R-tree/H3 indexing, geo-fencing, distance calculations, map tile serving, reverse geocoding.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/geospatial.md`](../../../shared/domains/concerns/geospatial.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Proximity query: user provides location + radius → spatial index queried (R-tree, H3, geohash) → results filtered by distance → sorted by proximity → returned with distance metadata
- Geo-fencing: fence defined as polygon/circle → device location update received → point-in-polygon test executed → enter/exit event emitted → notification/action triggered
- Reverse geocoding: coordinates received → nearest address lookup via geocoding service → structured address returned (street, city, country, postal code) → result cached with TTL
- Map tile serving: client requests tile (z/x/y) → tile cache checked → on miss, tile rendered from vector/raster source → stored in cache → served with appropriate cache headers

### SC Anti-Patterns (reject if seen)
- "Location search works" — must specify coordinate system (WGS84), index type, and distance calculation method (Haversine vs Vincenty)
- "Geo-fencing is implemented" — must specify polygon format (GeoJSON), update frequency, and enter/exit event handling
- "Map is displayed" — must specify tile source, zoom levels, and coordinate projection

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Indexing** | R-tree? H3? S2? Geohash? PostGIS? Which spatial index for the query patterns? |
| **Queries** | Nearest-neighbor? Within radius? Within polygon? Intersection? What distance function? |
| **Precision** | What coordinate precision needed? Meter-level? Sub-meter? How to handle antimeridian/poles? |
| **Tiles** | Vector tiles or raster? Tile server (self-hosted vs Mapbox/Google)? Offline tile packages? |
| **Geocoding** | Forward and/or reverse? Which provider? Rate limits? Caching strategy? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| GEO-001 | Coordinate order swap | Lat/lng swapped (lng,lat vs lat,lng) → queries return results from wrong hemisphere → silent data corruption | Standardize on one format project-wide (GeoJSON uses [lng, lat]); validate coordinate ranges at input (lat: -90..90, lng: -180..180) |
| GEO-002 | Antimeridian crossing | Bounding box queries fail when crossing 180th meridian → missing results near date line | Split queries at antimeridian or use S2/H3 cells that handle wrapping natively; test with Pacific-region data |
| GEO-003 | Distance calculation error | Using Euclidean distance on lat/lng → wildly inaccurate at high latitudes → wrong proximity results | Use Haversine or Vincenty formula; for short distances (<10km) projected coordinates acceptable; document chosen method |
| GEO-004 | Spatial index not used | Query planner bypasses spatial index → full table scan → O(n) instead of O(log n) → timeout on large datasets | EXPLAIN ANALYZE spatial queries; ensure ST_DWithin/ST_Contains use index; avoid function wrapping that defeats index |
| GEO-005 | Stale geocoding cache | Cached geocoding results never invalidated → addresses change → users see outdated location data | Set TTL on geocoding cache (e.g., 30 days); provide manual cache invalidation; version cache entries |
