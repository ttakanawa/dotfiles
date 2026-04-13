-- neotest-phpunit: Configuration for running tests via Docker
--
-- ============================================================================
-- Setup
-- ============================================================================
--
-- 1. Enable vim.o.exrc = true in options.lua (already configured)
-- 2. Enable test.core and lang.php LazyExtras
-- 3. Place .nvim.lua in the project root (see template below)
--
-- ============================================================================
-- .nvim.lua template (place in project root)
-- ============================================================================
--
-- For projects running tests via Docker odman, only declarative config is
-- needed. This plugin config automatically generates the wrapper script.
--
-- ```lua
-- -- Minimal config (when defaults are fine)
-- vim.g.neotest_phpunit_docker = {}
--
-- -- Custom config
-- vim.g.neotest_phpunit_docker = {
--   src_subdir = "src",                     -- default: "" (project root)
--   compose_cmd = "podman compose",         -- default: "docker compose"
--   service = "web",                        -- default: "app"
--   container_workdir = "/app/",            -- default: "/var/www/"
--   phpunit_bin = "./vendor/bin/phpunit",   -- default: "./vendor/bin/phpunit"
--   env = { UNIT_TEST_DB = "mydb_test" },   -- default: {} (extra env vars)
-- }
-- ```
--
-- Direct specification via vim.g.neotest_phpunit_command is also supported.
--
-- ============================================================================
-- Customization
-- ============================================================================
--
-- Adjust the following for your project:
--   - compose_cmd       → "docker compose", "podman compose", etc.
--   - service           → container service name
--   - container_workdir → WORKDIR inside container (trailing / required)
--   - src_subdir        → subdirectory containing phpunit.xml
--   - phpunit_bin       → path to PHPUnit binary inside container
--   - env               → env vars passed to exec (e.g. { DB = "test_db" })
--
-- ============================================================================
-- Known caveats
-- ============================================================================
--
-- DataProvider test names:
--   PHPUnit's JUnit XML appends a "with data set "..."" suffix to
--   DataProvider test names. However, neotest-phpunit builds IDs from
--   method names only, causing an ID mismatch that marks results as failed.
--   → The wrapper's sed removes "with data set ..." to work around this.
--   (ref: olimorris/neotest-phpunit#23)
--
-- exrc trust prompt:
--   When loading .nvim.lua for the first time, a trust confirmation dialog
--   appears. Press "a" (allow) to permit auto-loading in future sessions.

--- Generate a wrapper script for running phpunit via Docker compose.
--- The wrapper handles:
---   1. Host absolute path → container relative path conversion
---   2. --log-junit redirection through volume mounts
---   3. JUnit XML path and test name normalization
--- @param config table Docker configuration options
--- @return string[] command
local function generate_docker_wrapper(config)
  local project_root = vim.fn.getcwd()
  local src_subdir = config.src_subdir or ""
  local src_root = src_subdir ~= "" and (project_root .. "/" .. src_subdir) or project_root
  local compose_cmd = config.compose_cmd or "docker compose"
  local service = config.service or "app"
  local container_workdir = config.container_workdir or "/var/www/"
  local phpunit_bin = config.phpunit_bin or "./vendor/bin/phpunit"
  local env = config.env or {}

  -- Build -e KEY=VALUE flags for compose exec
  local env_flags = ""
  for k, v in pairs(env) do
    env_flags = env_flags .. " -e " .. k .. "=" .. v
  end

  -- Ensure container_workdir ends with /
  if not container_workdir:match("/$") then
    container_workdir = container_workdir .. "/"
  end

  -- Use project-specific wrapper filename to avoid collisions
  local project_hash = vim.fn.sha256(project_root):sub(1, 8)
  local wrapper = vim.fn.stdpath("cache") .. "/neotest-phpunit-" .. project_hash .. ".sh"

  local script = ([=[#!/bin/bash
SRC="%s"; PRJ="%s"; WORKDIR="%s"
ARGS=(); LOG=""
for arg in "$@"; do
  case "$arg" in
    --log-junit=*) LOG="${arg#--log-junit=}"; ARGS+=("--log-junit=${WORKDIR}.neotest-result.xml") ;;
    "$SRC"/*) ARGS+=("${arg#$SRC/}") ;;
    "$SRC"|"$PRJ") ;;
    *) ARGS+=("$arg") ;;
  esac
done
cd "$PRJ" && %s exec%s -T %s %s "${ARGS[@]}"; EC=$?
[[ -n "$LOG" ]] && {
  sed -E 's|'"$WORKDIR"'|'"$SRC"'/|g; s| with data set [^"]*||g' "$SRC/.neotest-result.xml" > "$LOG" 2>/dev/null
  rm -f "$SRC/.neotest-result.xml" 2>/dev/null
}
exit $EC]=]):format(src_root, project_root, container_workdir, compose_cmd, env_flags, service, phpunit_bin)

  vim.fn.writefile(vim.split(script, "\n"), wrapper)
  vim.fn.setfperm(wrapper, "rwxr-xr-x")

  return { wrapper }
end

return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
  },
  opts = function(_, opts)
    opts.floating = { border = "rounded" }

    local cmd = vim.g.neotest_phpunit_command
    if not cmd then
      local docker_config = vim.g.neotest_phpunit_docker
      if docker_config then
        cmd = generate_docker_wrapper(docker_config)
      end
    end

    if not cmd then
      return
    end

    -- Override the adapter registered by LazyVim's lang.php extra with string key
    opts.adapters = opts.adapters or {}
    opts.adapters["neotest-phpunit"] = {
      phpunit_cmd = function()
        return cmd
      end,
      root_ignore_files = { "tests/Pest.php" },
    }
  end,
}
