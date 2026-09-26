---
name: markdown-writing-style
description: Use when creating or updating any markdown file.
---

Apply the following formatting rules to all markdown output.

## Code Block Indentation

Always indent fenced code blocks by 2 spaces and specify the language identifier.

OK:

  ```bash
  echo "hello"
  ```

NG:

```bash
echo "hello"
```

## Table Separator

Insert a space after the opening `|` and before the closing `|` in separator rows.

- OK: `| ------ | ------------- |`
  - NG: `|------|-------------|`

## Code References

Write every reference to a class, interface, method, function, or file path as a hyperlink. Link each occurrence, not only the first one in a document.

Choose the link target by where the document lives.

| Document location | Link target |
| ------------------- | ------------- |
| Inside the repository (README, CLAUDE.md, skills, docs) | Repository-relative path |
| Outside the repository (Confluence, MR / PR description) | Permalink pinned to the latest `master` / `main` commit |

Point at the exact lines with `#L<start>-L<end>`. When the reference has a name, that name is the link text. When it is a line range with no name — a config block, a conditional branch — show the range in the link text so the reader sees which lines it points at without opening the link.

Keep link text short. Use the bare identifier — a class, method, or file name — and let the URL carry the directory hierarchy. Write the path in the link text only when the reader cannot tell the reference apart without it, such as same-named files in different directories or references that span multiple repositories.

Never wrap link text in backticks.

  ```markdown
  <!-- OK: class reference, the class name is the link text -->
  [UserService](src/services/user-service.ts)

  <!-- OK: file reference, the file name is the link text -->
  [config.yaml](config/config.yaml)

  <!-- OK: line anchor for a method, the method name is the link text -->
  [UserService.findById](src/services/user-service.ts#L61-L63)

  <!-- OK: line range with no name, so the range stays visible -->
  [config.yaml#L10-L18](config/config.yaml#L10-L18)

  <!-- OK: permalink for a document outside the repository -->
  [UserService](https://github.com/owner/repo/blob/e2eb483.../src/services/user-service.ts)

  <!-- OK: path in the link text because two files share a name -->
  [api/package.json](api/package.json) and [web/package.json](web/package.json)

  <!-- NG: full path as link text when the name alone is enough -->
  [src/services/user-service.ts](src/services/user-service.ts)

  <!-- NG: the link points at a line range but the link text hides it -->
  [config.yaml](config/config.yaml#L10-L18)

  <!-- NG: plain code span with no link -->
  `UserService`

  <!-- NG: link text wrapped in backticks -->
  [`UserService`](src/services/user-service.ts)
  ```

When no link target exists — a third-party class outside the repository, or a directory that is not a git clone — write the name as plain text and state why it is not linked.
