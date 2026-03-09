# Performance Checklist

Severity: **MEDIUM**

- [ ] **Inefficient algorithms** — O(n^2) when O(n log n) or O(n) is possible
- [ ] **Missing memoization** — Repeated expensive computations without caching
- [ ] **Missing caching** — Repeated I/O or API calls that could be cached
- [ ] **Synchronous I/O in async context** — Blocking operations in async code paths
- [ ] **N+1 queries** — Querying inside a loop instead of batching or eager loading
