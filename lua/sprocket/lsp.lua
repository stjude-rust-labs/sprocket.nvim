local M = {}

local status = require("sprocket.status")

local setup_in_progress = false
local setup_complete = false

local function get_cmd()
  local binary = require("sprocket.binary")
  local config = require("sprocket.config").get()

  local path = binary.get_path()
  if not path then
    return nil
  end

  local args = { path, "analyzer", "--stdio" }

  if config.server.lint then
    table.insert(args, "--lint")
  end

  local level = config.server.log_level
  if level == "verbose" then
    table.insert(args, "-vvv")
  elseif level == "info" then
    table.insert(args, "-vv")
  else
    table.insert(args, "-q")
  end

  return args
end

local function on_attach(client, bufnr)
  local config = require("sprocket.config").get()

  if config.format_on_save then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false, id = client.id })
      end,
    })
  end

  if config.lsp.on_attach then
    config.lsp.on_attach(client, bufnr)
  end
end

local function get_capabilities()
  local config = require("sprocket.config").get()

  if config.lsp.capabilities then
    if type(config.lsp.capabilities) == "function" then
      return config.lsp.capabilities()
    end
    return config.lsp.capabilities
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if has_cmp then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

function M.setup()
  -- Prevent concurrent setup calls
  if setup_in_progress or setup_complete then
    return
  end
  setup_in_progress = true

  local binary = require("sprocket.binary")
  local config = require("sprocket.config").get()

  binary.ensure_installed(function(success)
    if not success then
      setup_in_progress = false
      status.set("error", "Binary not found")
      vim.schedule(function()
        pcall(vim.notify, "[sprocket] Binary not found. Run :Sprocket update or install manually.", vim.log.levels.WARN)
      end)
      return
    end

    vim.schedule(function()
      local ok, err = pcall(function()
        local cmd = get_cmd()
        if not cmd then
          status.set("error", "Failed to build command")
          return
        end

        local handlers = {
          ["$/progress"] = function(_, result, _)
            if result.value then
              if result.value.kind == "begin" then
                status.set("starting", result.value.title)
              elseif result.value.kind == "end" then
                status.set("running", nil)
              end
            end
          end,
        }

        if config.lsp.handlers then
          handlers = vim.tbl_extend("force", handlers, config.lsp.handlers)
        end

        vim.lsp.config.sprocket = {
          cmd = cmd,
          filetypes = { "wdl" },
          root_markers = { ".git", "sprocket.toml" },
          name = "sprocket",
          capabilities = get_capabilities(),
          on_attach = on_attach,
          handlers = handlers,
          on_init = function(_)
            status.set("running", nil)
          end,
          on_exit = function(code, _, _)
            if code ~= 0 then
              status.set("error", "Server exited with code " .. code)
            else
              status.set("inactive", nil)
            end
          end,
        }

        vim.lsp.enable("sprocket")
        setup_complete = true

        -- Check for updates in the background
        if config.binary.check_updates then
          local current = binary.get_version()
          binary.get_latest_version(function(latest)
            if latest and current and current ~= latest then
              vim.schedule(function()
                pcall(
                  vim.notify,
                  string.format("[sprocket] Update available: %s -> %s. Run :Sprocket update", current, latest),
                  vim.log.levels.INFO
                )
              end)
            end
          end)
        end
      end)

      setup_in_progress = false
      if not ok then
        status.set("error", "Setup failed")
        pcall(vim.notify, "[sprocket] Setup failed: " .. tostring(err), vim.log.levels.ERROR)
      end
    end)
  end)
end

function M.stop()
  for _, client in ipairs(vim.lsp.get_clients({ name = "sprocket" })) do
    client:stop()
  end
  status.set("inactive", nil)
end

function M.restart()
  status.set("starting", "Restarting...")
  M.stop()

  vim.defer_fn(function()
    pcall(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "wdl" then
          vim.lsp.start(vim.lsp.config.sprocket, { bufnr = buf })
        end
      end
    end)
  end, 500)
end

return M
