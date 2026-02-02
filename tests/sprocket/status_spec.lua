local config = require("sprocket.config")
local status = require("sprocket.status")

describe("sprocket.status", function()
  before_each(function()
    config._config = nil
    status.set("inactive", nil)
  end)

  describe("component", function()
    it("returns empty string when status is disabled", function()
      config.setup({ status = { enabled = false } })

      local result = status.component()

      assert.equals("", result)
    end)

    it("returns empty string when status is inactive", function()
      config.setup({})
      status.set("inactive", nil)

      local result = status.component()

      assert.equals("", result)
    end)

    it("returns icon and label when running", function()
      config.setup({})
      status.set("running", nil)

      local result = status.component()

      assert.equals("󰗡 Sprocket", result)
    end)

    it("uses custom icons from config", function()
      config.setup({
        status = {
          enabled = true,
          icons = {
            ok = "✓",
            warning = "!",
            error = "✗",
            loading = "…",
          },
        },
      })
      status.set("running", nil)

      local result = status.component()

      assert.equals("✓ Sprocket", result)
    end)
  end)

  describe("set and get", function()
    it("updates and retrieves status", function()
      status.set("running", nil)

      local s, msg = status.get()

      assert.equals("running", s)
      assert.is_nil(msg)
    end)

    it("stores message", function()
      status.set("error", "Something went wrong")

      local s, msg = status.get()

      assert.equals("error", s)
      assert.equals("Something went wrong", msg)
    end)
  end)
end)
