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
- [ ] **TODO/FIXME without tickets** — TODOs should reference issue numbers
- [ ] **Poor naming** — Single-letter variables (x, tmp, data) in non-trivial contexts
- [ ] **Magic numbers** — Unexplained numeric constants; extract to named constants
- [ ] **Inconsistent formatting** — Mixed styles within the same file
- [ ] **Missing documentation for public APIs** — Exported functions/commands without documentation
