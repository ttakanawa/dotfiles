local function find_git_toplevel()
  local result = vim.fn.system("git -C " .. vim.fn.shellescape(vim.fn.getcwd()) .. " rev-parse --show-toplevel")
  local root = vim.trim(result)
  if vim.v.shell_error == 0 and root ~= "" then
    return root
  end
  return vim.fn.getcwd()
end

local git_root = find_git_toplevel()

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          root_dir = function(bufnr, on_dir)
            -- Find the nearest composer.json not in a vendor directory
            local root = vim.fs.root(bufnr, function(name, path)
              return name == "composer.json" and not path:find("/vendor/")
            end)
            on_dir(root or git_root)
          end,
          init_options = {
            licenceKey = os.getenv("INTELEPHENSE_LICENSE_KEY"),
            storagePath = vim.fn.stdpath("cache") .. "/intelephense",
          },
          settings = {
            intelephense = {
              references = {
                exclude = {},
              },
              rename = {
                exclude = {},
              },
              environment = {
                includePaths = {
                  git_root .. "/src/vendor",
                },
              },
              files = {
                maxSize = 5000000,
                associations = { "*.php" },
                exclude = {
                  "**/.git/**",
                  "**/.svn/**",
                  "**/.hg/**",
                  "**/CVS/**",
                  "**/.DS_Store/**",
                  "**/node_modules/**",
                  "**/bower_components/**",
                  "**/.history/**",
                  -- "**/vendor/**" はデフォルトにあるが、ここでは除外しない
                },
              },
            },
          },
        },
      },
    },
  },
}
