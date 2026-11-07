---
name: explain-schema
description: Explain relational database schemas and table structures with a Unicode relationship diagram followed by a concise table-granularity summary. Use when describing how database tables relate, what one record represents, and each table's role. Do not use for unrelated Markdown tables.
---

# Explain Schema

When explaining a relational database schema, present the information in this order:

1. A Unicode box-drawing relationship diagram.
2. A three-column summary covering each table's record granularity and role.

## Relationship Diagram

- Draw each table as a left-aligned box using Unicode box-drawing characters.
- Connect related tables with horizontal and vertical lines so the full relationship structure is visible at a glance.
- Put the cardinality beside each endpoint, using forms such as `(1)`, `(0..1)`, and `(0..many)`.
- Add a short relationship verb where it clarifies the connection, such as `contains`, `classifies`, `supplies`, `observed`, `governed_by`, `controlled_by`, or `audited`.
- Keep table names visually prominent and use uppercase names in the diagram unless the source schema has a meaningful alternative convention.
- Arrange tables vertically and route connectors to the right when that keeps crossings and ambiguity low.
- Ensure every connector can be traced unambiguously to both related tables.

Example shape:

  ```text
  ┌───────────────────────────┐
  │ PARENT_TABLE              │
  │                           ├──(1) contains───────────┐
  └───────────────────────────┘                         │
                                                        │
  ┌───────────────────────────┐                         │
  │ CHILD_TABLE               │                         │
  │                           ├──(0..many)──────────────┘
  └───────────────────────────┘
  ```

## Table Summary

Follow the diagram with these columns in this exact order:

- `Table`
- `Record Granularity`
- `Role`

Use lowercase table names in the summary unless preserving the source notation is important. Describe granularity as the business key or entity combination represented by one row, not merely as “one record.” Keep the role concise while naming the main data or responsibility owned by the table.

Render the summary as an aligned plain-text table with Unicode horizontal separators rather than a Markdown pipe table. For example:

  ```text
   Table          Record Granularity    Role
  ━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━
   parent_table    Parent entity         Shared parent information
  ─────────────  ────────────────────  ───────────────────────────
   child_table     Parent × child key    Details belonging to a parent
  ```

If several tables share one lifecycle or audit purpose, they may share a summary row using `table_a / table_b` only when separate rows would add no useful distinction. Otherwise, give every table its own row.
