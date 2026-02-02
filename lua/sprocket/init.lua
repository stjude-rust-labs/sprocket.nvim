local M = {}

M._initialized = false

function M.setup(opts)
  if M._initialized then
    return
  end
  M._initialized = true

  local config = require("sprocket.config")
  config.setup(opts)

  require("sprocket.lsp").setup()
  require("sprocket.commands").setup()

  pcall(function()
    require("sprocket.language").setup()
  end)
end

function M.status()
  return require("sprocket.status").component()
end

function M.restart()
  require("sprocket.lsp").restart()
end

return M
