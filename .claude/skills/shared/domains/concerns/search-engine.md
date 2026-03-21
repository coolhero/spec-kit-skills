# Concern: search-engine

> Full-text search, inverted indexes, tokenization/stemming, query DSL, relevance scoring, faceted search, autocomplete.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: full-text search, Elasticsearch, search index, inverted index, relevance scoring, search query, Solr, Meilisearch, Typesense

**Secondary**: tokenization, stemming, lemmatization, analyzer, faceted search, autocomplete, typeahead, fuzzy search, BM25, TF-IDF, search ranking, filter, aggregation, highlight, suggestion, synonyms

### Code Patterns (R1 — for source analysis)

- Engines: `@elastic/elasticsearch`, `elasticsearch-py`, `solr`, `meilisearch`, `typesense`, `algolia`, `lunr`, `minisearch`
- Patterns: `index.search()`, `match_query`, `multi_match`, `bool_query`, `aggs`, `facets`, `highlight`, `suggest`
- Database: PostgreSQL `tsvector`/`tsquery`, MongoDB `$text`/`$search`, MySQL `FULLTEXT`
- Analyzers: `standard`, `custom`, `stop`, `snowball`, `ngram`, `edge_ngram`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: http-api, data-io
- **Profiles**: —
