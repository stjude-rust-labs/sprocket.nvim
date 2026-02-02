local config = require("sprocket.config")

describe("sprocket.config", function()
  before_each(function()
    config._config = nil
  end)

  describe("setup", function()
    it("uses defaults when called with no arguments", function()
      config.setup()
      local cfg = config.get()

      assert.is_nil(cfg.binary.path)
      assert.is_false(cfg.binary.auto_install)
      assert.is_false(cfg.binary.check_updates)
      assert.is_false(cfg.server.lint)
      assert.equals("quiet", cfg.server.log_level)
      assert.is_false(cfg.format_on_save)
      assert.is_true(cfg.status.enabled)
    end)

    it("uses defaults when called with empty table", function()
      config.setup({})
      local cfg = config.get()

      assert.is_false(cfg.format_on_save)
      assert.is_true(cfg.status.enabled)
    end)

    it("merges user options with defaults", function()
      config.setup({
        format_on_save = true,
        binary = {
          path = "/custom/path/sprocket",
        },
      })
      local cfg = config.get()

      assert.is_true(cfg.format_on_save)
      assert.equals("/custom/path/sprocket", cfg.binary.path)
      assert.is_false(cfg.binary.auto_install)
    end)

    it("deep merges nested tables", function()
      config.setup({
        status = {
          icons = {
            ok = "✓",
          },
        },
      })
      local cfg = config.get()

      assert.equals("✓", cfg.status.icons.ok)
      assert.equals("", cfg.status.icons.warning)
      assert.equals("", cfg.status.icons.error)
    end)

    it("allows setting server options", function()
      config.setup({
        server = {
          lint = true,
          log_level = "verbose",
        },
      })
      local cfg = config.get()

      assert.is_true(cfg.server.lint)
      assert.equals("verbose", cfg.server.log_level)
    end)
  end)

  describe("get", function()
    it("initializes with defaults if setup was not called", function()
      local cfg = config.get()

      assert.is_not_nil(cfg)
      assert.is_false(cfg.format_on_save)
    end)

    it("returns same config on multiple calls", function()
      config.setup({ format_on_save = true })

      local cfg1 = config.get()
      local cfg2 = config.get()

      assert.equals(cfg1, cfg2)
    end)
  end)
end)
