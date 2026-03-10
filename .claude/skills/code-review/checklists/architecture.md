# Architecture Checklist

Severity: **HIGH**

- [ ] **Layer violation** — Domain logic leaking into upper layers (application, presentation) or infrastructure concerns mixed into domain
- [ ] **Dependency direction reversal** — Lower layers referencing upper layers, or domain depending on infrastructure
- [ ] **Misplaced responsibility** — Logic placed in a module or layer where it does not belong
- [ ] **Cross-cutting change inconsistency** — Changes spanning multiple files with conflicting or incoherent design intent
