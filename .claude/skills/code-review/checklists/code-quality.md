# Code Quality Checklist

Severity: **HIGH**

- [ ] **Large functions** (>50 lines) — Split into smaller, focused functions
- [ ] **Large files** (>800 lines) — Extract modules by responsibility
- [ ] **Deep nesting** (>4 levels) — Use early returns, extract helpers
- [ ] **Missing error handling** — Unhandled errors, empty catch/rescue blocks
- [ ] **Debug output left in code** — Remove debug logging before merge
- [ ] **Missing tests** — New code paths without test coverage
- [ ] **Dead code** — Commented-out code, unused imports/variables, unreachable branches
- [ ] **Unexpected mutation** — Modifying shared state, arguments, or globals without clear intent
