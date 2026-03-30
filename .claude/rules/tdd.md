# TDD (Test-Driven Development)

Prefer canonical TDD as defined by Kent Beck.

## Canonical TDD Workflow

1. **Test List** — enumerate expected behaviors before writing any code
2. **Write one failing test** — design the interface (how behavior is called)
3. **Make it pass** — minimal implementation only
4. **Refactor** — design the implementation (internal structure)
5. **Repeat** — pick the next item from the test list

## Key Constraints

- One test at a time — write, pass, refactor, then next
- Interface design happens in step 2; implementation design in step 4
- Do NOT write all tests upfront — that is test-first, not TDD
- Do NOT refactor while making a test pass — separate the two phases
