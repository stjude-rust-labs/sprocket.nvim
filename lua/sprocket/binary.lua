local M = {}

local uv = vim.uv or vim.loop

local function get_data_dir()
  return vim.fn.stdpath("data") .. "/sprocket"
end

local function get_bin_path()
  local ext = uv.os_uname().sysname:find("Windows") and ".exe" or ""
  return get_data_dir() .. "/bin/sprocket" .. ext
end

local function get_platform()
  local os_info = uv.os_uname()
  local sysname = os_info.sysname
  local machine = os_info.machine

  local arch
  if machine == "arm64" or machine == "aarch64" then
    arch = "aarch64"
  else
    arch = "x86_64"
  end

  if sysname == "Darwin" then
    return arch .. "-apple-darwin", "tar.gz"
  elseif sysname == "Linux" then
    return arch .. "-unknown-linux-gnu", "tar.gz"
  elseif sysname:find("Windows") then
    return arch .. "-pc-windows-msvc", "zip"
  end

  vim.schedule(function()
    vim.notify(
      string.format("[sprocket] Unsupported platform: %s (%s)", sysname, machine),
      vim.log.levels.WARN
    )
  end)
  return nil, nil
end

function M.get_path()
  local config = require("sprocket.config").get()

  -- 1. Explicit path
  if config.binary.path then
    if vim.fn.executable(config.binary.path) == 1 then
      return config.binary.path
    end
    vim.notify(
      "[sprocket] Configured binary not found: " .. config.binary.path,
      vim.log.levels.WARN
    )
  end

  -- 2. Auto-installed binary
  local data_path = get_bin_path()
  if uv.fs_stat(data_path) then
    return data_path
  end

  -- 3. `PATH` fallback
  local path_binary = vim.fn.exepath("sprocket")
  if path_binary ~= "" then
    return path_binary
  end

  return nil
end

function M.get_version()
  local path = M.get_path()
  if not path then
    return nil
  end

  local result = vim.system({ path, "--version" }, { text = true }):wait()
  if result.code == 0 then
    local version = result.stdout:match("sprocket v?(%S+)")
    if version then
      -- Strip trailing non-version characters (e.g., from `0.20.0-dirty`)
      version = version:match("^([%d%.]+)")
    end
    return version
  end

  return nil
end

function M.get_latest_version(callback)
  vim.system(
    { "curl", "-sL", "--max-time", "30", "https://crates.io/api/v1/crates/sprocket" },
    { text = true },
    function(result)
      if result.code == 0 then
        local data = vim.json.decode(result.stdout)
        if data and data.crate and data.crate.max_stable_version then
          callback(data.crate.max_stable_version)
          return
        end
      end
      callback(nil)
    end
  )
end

function M.download(version, callback)
  local platform, ext = get_platform()
  if not platform then
    vim.schedule(function()
      callback(false, "Unsupported platform")
    end)
    return
  end

  local filename = string.format("sprocket-v%s-%s.%s", version, platform, ext)
  local url = string.format(
    "https://github.com/stjude-rust-labs/sprocket/releases/download/v%s/%s",
    version,
    filename
  )

  local data_dir = get_data_dir()
  local bin_dir = data_dir .. "/bin"
  local archive_path = data_dir .. "/" .. filename
  local bin_path = get_bin_path()

  vim.schedule(function()
    vim.fn.mkdir(bin_dir, "p")
    vim.notify("[sprocket] Downloading " .. version .. "...", vim.log.levels.INFO)

    vim.system({ "curl", "-sL", "--max-time", "120", "-o", archive_path, url }, {}, function(result)
      if result.code ~= 0 then
        vim.schedule(function()
          callback(false, "Download failed")
        end)
        return
      end

      local extract_cmd
      if ext == "tar.gz" then
        extract_cmd = { "tar", "-xzf", archive_path, "-C", bin_dir }
      else
        extract_cmd = { "unzip", "-o", archive_path, "-d", bin_dir }
      end

      vim.system(extract_cmd, { text = true }, function(extract_result)
        vim.schedule(function()
          vim.fn.delete(archive_path)

          if extract_result.code ~= 0 then
            local err_msg = extract_result.stderr or "unknown error"
            vim.notify("[sprocket] Extraction failed: " .. err_msg, vim.log.levels.ERROR)
            callback(false, "Extraction failed: " .. err_msg)
            return
          end

          vim.fn.setfperm(bin_path, "rwxr-xr-x")
          vim.notify("[sprocket] Installed version " .. version, vim.log.levels.INFO)
          callback(true, nil)
        end)
      end)
    end)
  end)
end

function M.update()
  local current = M.get_version()
  M.get_latest_version(function(latest)
    if not latest then
      vim.schedule(function()
        vim.notify("[sprocket] Failed to check latest version", vim.log.levels.ERROR)
      end)
      return
    end

    if current and current == latest then
      vim.schedule(function()
        vim.notify("[sprocket] Already at latest version: " .. latest, vim.log.levels.INFO)
      end)
      return
    end

    M.download(latest, function(success, err)
      if not success then
        vim.schedule(function()
          vim.notify("[sprocket] Update failed: " .. (err or "unknown error"), vim.log.levels.ERROR)
        end)
      end
    end)
  end)
end

function M.ensure_installed(callback)
  if M.get_path() then
    callback(true)
    return
  end

  local config = require("sprocket.config").get()
  if not config.binary.auto_install then
    callback(false)
    return
  end

  M.get_latest_version(function(version)
    if not version then
      vim.schedule(function()
        callback(false)
      end)
      return
    end

    M.download(version, function(success, _)
      callback(success)
    end)
  end)
end

return M
