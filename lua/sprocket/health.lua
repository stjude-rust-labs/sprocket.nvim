local M = {}

function M.check()
  vim.health.start("sprocket.nvim")

  -- Check Neovim version
  local nvim_version = vim.version()
  local version_str = nvim_version.major .. "." .. nvim_version.minor .. "." .. nvim_version.patch
  if vim.fn.has("nvim-0.11") == 1 then
    vim.health.ok("Neovim version: " .. version_str)
  else
    vim.health.error("Neovim 0.11+ required (found " .. version_str .. ")", {
      "Upgrade to Neovim 0.11 or later",
    })
  end

  -- Check binary
  local binary = require("sprocket.binary")
  local path = binary.get_path()

  if path then
    vim.health.ok("sprocket binary found: " .. path)

    local version = binary.get_version()
    if version then
      vim.health.ok("sprocket version: " .. version)
    else
      vim.health.warn("Could not determine sprocket version")
    end
  else
    local config = require("sprocket.config").get()
    if config.binary.auto_install then
      vim.health.warn("sprocket not found (will auto-install on first use)")
    else
      vim.health.error("sprocket binary not found", {
        "Download from https://github.com/stjude-rust-labs/sprocket/releases",
        "Or enable `binary.auto_install` in config and run `:Sprocket update`",
      })
    end
  end

  -- Check for `curl` (needed for auto-install)
  if vim.fn.executable("curl") == 1 then
    vim.health.ok("curl is available")
  else
    vim.health.warn("curl not found (needed for auto-installation)")
  end

  -- Check for `tar`/`unzip` (needed for extraction)
  local uv = vim.uv or vim.loop
  local sysname = uv.os_uname().sysname
  if sysname:lower():match("windows") then
    if vim.fn.executable("unzip") == 1 then
      vim.health.ok("unzip is available")
    else
      vim.health.warn("unzip not found (needed for auto-installation on Windows)")
    end
  else
    if vim.fn.executable("tar") == 1 then
      vim.health.ok("tar is available")
    else
      vim.health.warn("tar not found (needed for auto-installation)")
    end
  end

  -- Check LSP status
  vim.health.start("LSP Status")

  local clients = vim.lsp.get_clients({ name = "sprocket" })
  if #clients > 0 then
    vim.health.ok("Sprocket LSP is running")
    for _, client in ipairs(clients) do
      vim.health.info("  Client ID: " .. client.id)
      if client.config.root_dir then
        vim.health.info("  Root dir: " .. client.config.root_dir)
      end
    end
  else
    vim.health.info("Sprocket LSP is not running (open a `.wdl` file to start)")
  end

  -- Check optional dependencies
  vim.health.start("Optional Dependencies")

  -- Check `nvim-cmp`
  local has_cmp = pcall(require, "cmp")
  if has_cmp then
    vim.health.ok("nvim-cmp is installed (completion integration enabled)")
  else
    vim.health.info("nvim-cmp not installed (using built-in completion)")
  end

  -- Check configuration
  vim.health.start("Configuration")

  local config = require("sprocket.config").get()
  vim.health.info("Lint enabled: " .. tostring(config.server.lint))
  vim.health.info("Format on save: " .. tostring(config.format_on_save))
  vim.health.info("Auto install: " .. tostring(config.binary.auto_install))
  vim.health.info("Check updates: " .. tostring(config.binary.check_updates))
  vim.health.info("Log level: " .. config.server.log_level)
end

return M
