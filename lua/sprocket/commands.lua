local M = {}

local function run_sprocket(args, on_complete)
  local binary = require("sprocket.binary")
  local path = binary.get_path()

  if not path then
    vim.notify("[sprocket] Binary not found", vim.log.levels.ERROR)
    return
  end

  local cmd = { path }
  vim.list_extend(cmd, args)

  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        if result.stdout and result.stdout ~= "" then
          vim.notify(result.stdout, vim.log.levels.INFO)
        else
          vim.notify("[sprocket] Command completed successfully", vim.log.levels.INFO)
        end
      else
        local msg = result.stderr ~= "" and result.stderr or "Command failed"
        vim.notify(msg, vim.log.levels.ERROR)
      end

      if on_complete then
        on_complete(result.code == 0)
      end
    end)
  end)
end

local subcommands = {
  restart = {
    desc = "Restart LSP server",
    run = function(_)
      vim.notify("[sprocket] Restarting LSP...", vim.log.levels.INFO)
      require("sprocket.lsp").restart()
    end,
  },

  stop = {
    desc = "Stop LSP server",
    run = function(_)
      require("sprocket.lsp").stop()
      vim.notify("[sprocket] LSP stopped", vim.log.levels.INFO)
    end,
  },

  check = {
    desc = "Validate WDL file",
    run = function(args)
      local path = args[1] or vim.api.nvim_buf_get_name(0)
      if path == "" then
        vim.notify("[sprocket] No file specified and current buffer has no path", vim.log.levels.ERROR)
        return
      end
      run_sprocket({ "check", path })
    end,
  },

  format = {
    desc = "Format WDL file",
    run = function(args)
      local path = args[1] or vim.api.nvim_buf_get_name(0)
      if path == "" then
        vim.notify("[sprocket] No file specified and current buffer has no path", vim.log.levels.ERROR)
        return
      end
      run_sprocket({ "format", "overwrite", path })
    end,
  },

  lint = {
    desc = "Run linter",
    run = function(args)
      local path = args[1] or vim.api.nvim_buf_get_name(0)
      if path == "" then
        vim.notify("[sprocket] No file specified and current buffer has no path", vim.log.levels.ERROR)
        return
      end
      run_sprocket({ "lint", path })
    end,
  },

  update = {
    desc = "Update sprocket binary",
    run = function(_)
      require("sprocket.binary").update()
    end,
  },

  info = {
    desc = "Show version and status",
    run = function(_)
      require("sprocket.status").show_info()
    end,
  },

  version = {
    desc = "Show sprocket version",
    run = function(_)
      local binary = require("sprocket.binary")
      local current = binary.get_version()
      if current then
        vim.notify("[sprocket] Version: " .. current, vim.log.levels.INFO)
        binary.get_latest_version(function(latest)
          if latest and latest ~= current then
            vim.schedule(function()
              vim.notify(
                string.format("[sprocket] Update available: %s -> %s", current, latest),
                vim.log.levels.INFO
              )
            end)
          end
        end)
      else
        vim.notify("[sprocket] Not installed", vim.log.levels.WARN)
      end
    end,
  },

  log = {
    desc = "Open LSP log file",
    run = function(_)
      vim.cmd("edit " .. vim.lsp.get_log_path())
    end,
  },
}

local function complete(_, cmdline, _)
  local args = vim.split(cmdline, "%s+")
  if #args <= 2 then
    local candidates = {}
    for name, _ in pairs(subcommands) do
      table.insert(candidates, name)
    end
    table.sort(candidates)
    return candidates
  end
  return {}
end

function M.setup()
  vim.api.nvim_create_user_command("Sprocket", function(opts)
    local args = opts.fargs
    local subcmd = args[1]

    if not subcmd then
      vim.notify("[sprocket] Usage: :Sprocket <subcommand>", vim.log.levels.INFO)
      vim.notify("Available: " .. table.concat(vim.tbl_keys(subcommands), ", "), vim.log.levels.INFO)
      return
    end

    local handler = subcommands[subcmd]
    if not handler then
      vim.notify("[sprocket] Unknown subcommand: " .. subcmd, vim.log.levels.ERROR)
      return
    end

    local subargs = vim.list_slice(args, 2)
    handler.run(subargs)
  end, {
    nargs = "*",
    complete = complete,
    desc = "Sprocket commands",
  })
end

return M
