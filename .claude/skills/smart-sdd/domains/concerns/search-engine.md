# Concern: search-engine

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> Full-text search, inverted indexes, tokenization/stemming, query DSL, relevance scoring, faceted search, autocomplete.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/search-engine.md`](../../../shared/domains/concerns/search-engine.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Index pipeline: data created/updated → indexing event emitted → document transformed to search schema → indexed in search engine → index refresh/commit → searchable within SLA (near-real-time or batch)
- Search query: user submits query → query parsed and analyzed (tokenization, stemming) → search executed against index → results scored by relevance → facets/aggregations computed → results returned with highlights and metadata
- Autocomplete: user types characters → prefix/ngram query sent after debounce → suggestions retrieved from dedicated index → ranked by popularity/relevance → displayed with category/context → selection navigates to result
- Faceted search: user applies filter → facet values computed from result set → filtered results returned → remaining facet counts updated → active filters displayed → filters composable (AND/OR)

### SC Anti-Patterns (reject if seen)
- "Search works" — must specify search engine, index strategy (real-time vs batch), and relevance tuning approach
- "Results are relevant" — must specify ranking factors, boosting rules, and how relevance is measured/tuned
- "Autocomplete is fast" — must specify index type (ngram, prefix), debounce timing, and result limit

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Engine** | Elasticsearch? Meilisearch? Typesense? Algolia? Database full-text? What drove the choice? |
| **Indexing** | Real-time or batch? Index refresh interval? Schema mapping? Multi-language analyzers? |
| **Relevance** | BM25? Custom scoring? Field boosting? User signals (clicks, conversions)? A/B testing relevance? |
| **Facets** | Which fields are faceted? Hierarchical facets? Range facets? Facet count accuracy? |
| **Scale** | Index size? Query volume? Sharding strategy? Replica count? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| SE-001 | Index drift | Primary data updated but search index not re-indexed → stale search results → user confusion | Event-driven indexing on data change; periodic full reindex as safety net; monitor index lag metric |
| SE-002 | Query injection | User input interpolated directly into search DSL → attacker crafts query to extract unauthorized data or crash engine | Sanitize and parameterize user input; use search client's query builder API; never string-concatenate queries |
| SE-003 | Missing analyzer config | Default analyzer used for non-English content → stemming/tokenization wrong → poor recall for CJK, Arabic, etc. | Configure language-specific analyzers per field; test search quality with multilingual content |
| SE-004 | Facet cardinality explosion | Faceting on high-cardinality field (e.g., user ID) → memory exhaustion on search node → cluster instability | Limit facetable fields to bounded cardinality; set max facet count; use approximate counts for high-cardinality |
| SE-005 | Autocomplete latency spike | Autocomplete queries hit main index instead of dedicated lightweight index → slow response → degraded UX | Separate autocomplete index with ngram/edge-ngram mapping; set aggressive timeout; return cached suggestions on timeout |
