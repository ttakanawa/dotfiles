#!/bin/bash
# Legacy hook entry point for sessions that loaded the old configuration.
# PermissionRequest runs before auto-review and cannot tell whether a person
# will need to approve. Native Codex approval notifications handle that state.
cat >/dev/null
exit 0
