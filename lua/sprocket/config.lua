local M = {}

local defaults = {
  binary = {
    path = nil,
    auto_install = false,
    check_updates = false,
  },
  server = {
    lint = false,
    log_level = "quiet",
  },
  format_on_save = false,
  status = {
    enabled = true,
    icons = {
      ok = "󰗡",
      warning = "",
      error = "",
      loading = "󰑮",
    },
  },
  lsp = {
    capabilities = nil,
    on_attach = nil,
    handlers = nil,
  },
}

M._config = nil

function M.setup(opts)
  M._config = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

function M.get()
  if not M._config then
    M.setup({})
  end
  return M._config
end

return M
