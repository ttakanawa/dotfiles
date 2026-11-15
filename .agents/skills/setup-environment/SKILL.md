---
name: setup-environment
description: Set up or change project development environments using mise and uv. Use for initial setup, runtime or development-tool installation and updates, and environment configuration changes. Do not use for routine coding, testing, or script execution in an existing environment.
---

# Set Up a Development Environment

## Existing Projects

- Inspect project instructions, environment configuration, runtime version requirements, dependency definitions, and lockfiles before choosing tools or versions.
- Preserve existing project tools and version requirements. Migrate to mise or uv only when explicitly requested.

## Tools and Runtimes

- Use mise to manage runtimes and development tools for new environments, including Python itself and uv.
- Reuse existing mise configuration. Run `mise install` to install configured tools; use `mise use` for requested additions or version changes.
- Keep project-specific tool choices in project configuration. Change global configuration only when requested.
- If mise is not active in the current shell, use `mise exec --` to run commands with the configured tools.

## Python

- Use uv for virtual environments and dependency management in new or uv-managed projects. Preserve existing dependency definitions and lockfiles unless a change is requested.
- When creating a virtual environment for a new mise/uv-managed project, select the mise-managed interpreter explicitly:

  ```bash
  uv venv --python "$(mise which python)" --no-python-downloads
  ```

- Use `uv sync` to install declared dependencies in uv-managed projects and `uv add` for requested dependency additions.
- In uv-managed projects, use `uv run` for Python execution and `uv run -m` for modules; do not invoke python or python3 directly.
- In projects managed by other tools, use `uv run --no-project --no-sync --no-python-downloads` with `--python` pointing to the existing environment's interpreter. Keep dependency management with the project's existing tools.
