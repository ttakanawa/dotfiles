# Writing Style

## Mixed Japanese-English Text

When embedding English words in Japanese text, insert a half-width space on both sides of the English word.

- OK: `Claude Code は CLI ツールです`
- NG: `Claude Codeは CLIツールです`

Numbers do not require surrounding spaces.

- OK: `Claude Code で3つのファイルを作成した`
- NG: `Claude Codeで3つのファイルを作成した`

## Markdown

### Code Block Indentation

Always indent fenced code blocks by 2 spaces and specify the language identifier.

- OK:

  ```bash
  echo "hello"
  ```

- NG:

```bash
echo "hello"
```

### Table Separator

Insert a space after the opening `|` and before the closing `|` in separator rows.

- OK: `| ------ | ------------- |`
- NG: `|------|-------------|`
