local M = {}

local state = {
  status = "inactive",
  message = nil,
  info_win = nil,
}

function M.set(status, message)
  state.status = status
  state.message = message
end

function M.get()
  return state.status, state.message
end

function M.component()
  local config = require("sprocket.config").get()
  if not config.status.enabled then
    return ""
  end

  local icons = config.status.icons
  local icon_map = {
    inactive = "",
    starting = icons.loading,
    running = icons.ok,
    warning = icons.warning,
    error = icons.error,
  }

  local icon = icon_map[state.status] or ""
  if icon == "" then
    return ""
  end

  return icon .. " Sprocket"
end

function M.show_info()
  -- Close existing info window if open
  if state.info_win and vim.api.nvim_win_is_valid(state.info_win) then
    vim.api.nvim_win_close(state.info_win, true)
    state.info_win = nil
  end

  local binary = require("sprocket.binary")
  local config = require("sprocket.config").get()
  local path = binary.get_path()
  local version = path and binary.get_version() or nil

  local lines = {
    "Sprocket Info",
    string.rep("─", 40),
    "",
    "Status:  " .. state.status,
    "Binary:  " .. (path or "not found"),
    "Version: " .. (version or "unknown"),
    "",
    "Configuration:",
    "  Lint:           " .. tostring(config.server.lint),
    "  Format on save: " .. tostring(config.format_on_save),
    "  Auto install:   " .. tostring(config.binary.auto_install),
  }

  if state.message then
    table.insert(lines, "")
    table.insert(lines, "Message: " .. state.message)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"

  local width = 44
  local height = #lines
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Sprocket ",
    title_pos = "center",
  })

  state.info_win = win

  local function close_win()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    state.info_win = nil
  end

  vim.keymap.set("n", "q", close_win, { buffer = buf })
  vim.keymap.set("n", "<Esc>", close_win, { buffer = buf })
end

return M
