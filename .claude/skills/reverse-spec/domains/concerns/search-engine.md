# Concern: search-engine (reverse-spec)

> Search engine detection. Identifies full-text search, indexing pipelines, and relevance scoring patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/search-engine.md`](../../../shared/domains/concerns/search-engine.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Search engine used (Elasticsearch, Meilisearch, Typesense, Algolia, database full-text)
- Indexing pipeline (real-time vs batch, index refresh strategy)
- Analyzer configuration (tokenizers, filters, language support)
- Query types used (match, multi_match, bool, phrase, fuzzy)
- Faceted search and aggregation patterns
- Autocomplete/typeahead implementation
