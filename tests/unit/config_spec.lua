describe("ansillary.config", function()
  local config
  local helper

  before_each(function()
    helper = require("tests.test_helper")
    helper.setup_vim_mock()

    -- Clear require cache
    package.loaded["ansillary.config"] = nil
    config = require("ansillary.config")
  end)

  describe("default configuration", function()
    it("should have correct default values", function()
      assert.are.equal(true, config.conceal)
      assert.are.equal(true, config.reveal_on_cursorline)
      assert.are.equal(true, config.warn_on_unsupported)
      assert.are.equal(true, config.text_highlights.enabled)
      assert.are.equal("auto", config.text_highlights.format.fg.color)
      assert.are.equal("auto", config.text_highlights.format.fg.style)
      assert.are.equal("auto", config.text_highlights.format.bg.color)
      assert.are.equal(false, config.ansi_highlights.enabled)
      assert.are.equal("auto", config.ansi_highlights.format.fg.color)
      assert.are.equal("auto", config.ansi_highlights.format.fg.style)
      assert.are.equal("auto", config.ansi_highlights.format.bg.color)
    end)

    it("should have correct filetype defaults", function()
      assert.are.same({"*"}, config.enabled_filetypes)
      assert.are.same({}, config.disabled_filetypes)
    end)
  end)

  describe("configuration structure", function()
    it("should have all required top-level keys", function()
      local required_keys = {
        "conceal",
        "reveal_on_cursorline",
        "warn_on_unsupported",
        "text_highlights",
        "ansi_highlights",
        "signcolumn",
        "enabled_filetypes",
        "disabled_filetypes"
      }

      for _, key in ipairs(required_keys) do
        assert.is_not_nil(config[key], "Missing required config key: " .. key)
      end
    end)

    it("should have correct text_highlights structure", function()
      assert.is_table(config.text_highlights)
      assert.is_boolean(config.text_highlights.enabled)
      assert.is_table(config.text_highlights.format)
      assert.is_table(config.text_highlights.format.fg)
      assert.is_table(config.text_highlights.format.bg)
    end)

    it("should have correct ansi_highlights structure", function()
      assert.is_table(config.ansi_highlights)
      assert.is_boolean(config.ansi_highlights.enabled)
      assert.is_table(config.ansi_highlights.format)
      assert.is_table(config.ansi_highlights.format.fg)
      assert.is_table(config.ansi_highlights.format.bg)
    end)

    it("should have correct signcolumn structure", function()
      assert.is_table(config.signcolumn)
      assert.is_boolean(config.signcolumn.enabled)
      assert.is_string(config.signcolumn.icon)
      assert.is_table(config.signcolumn.format)
      assert.is_string(config.signcolumn.format.color)
      assert.is_string(config.signcolumn.format.style)
    end)

    it("should have correct format structure", function()
      local fg = config.ansi_highlights.format.fg
      local bg = config.ansi_highlights.format.bg

      assert.is_string(fg.color)
      assert.is_string(fg.style)
      assert.is_string(bg.color)
    end)

    it("should have correct filetype configuration types", function()
      assert.is_table(config.enabled_filetypes)
      assert.is_table(config.disabled_filetypes)
    end)
  end)

  describe("boolean configuration values", function()
    it("should have boolean type for conceal", function()
      assert.is_boolean(config.conceal)
    end)

    it("should have boolean type for reveal_on_cursorline", function()
      assert.is_boolean(config.reveal_on_cursorline)
    end)

    it("should have boolean type for warn_on_unsupported", function()
      assert.is_boolean(config.warn_on_unsupported)
    end)

    it("should have boolean type for text_highlights.enabled", function()
      assert.is_boolean(config.text_highlights.enabled)
    end)

    it("should have boolean type for ansi_highlights.enabled", function()
      assert.is_boolean(config.ansi_highlights.enabled)
    end)

    it("should have boolean type for signcolumn.enabled", function()
      assert.is_boolean(config.signcolumn.enabled)
    end)
  end)

  describe("string configuration values", function()
    it("should have string type for format colors and styles", function()
      assert.is_string(config.ansi_highlights.format.fg.color)
      assert.is_string(config.ansi_highlights.format.fg.style)
      assert.is_string(config.ansi_highlights.format.bg.color)
    end)

    it("should have valid auto values", function()
      assert.are.equal("auto", config.ansi_highlights.format.fg.color)
      assert.are.equal("auto", config.ansi_highlights.format.fg.style)
      assert.are.equal("auto", config.ansi_highlights.format.bg.color)
    end)
  end)

  describe("array configuration values", function()
    it("should have arrays for filetype configurations", function()
      assert.is_table(config.enabled_filetypes)
      assert.is_table(config.disabled_filetypes)

      -- Check they are array-like (have numeric indices)
      for i, v in ipairs(config.enabled_filetypes) do
        assert.is_string(v)
      end

      for i, v in ipairs(config.disabled_filetypes) do
        assert.is_string(v)
      end
    end)

    it("should have wildcard in enabled_filetypes by default", function()
      local has_wildcard = false
      for _, ft in ipairs(config.enabled_filetypes) do
        if ft == "*" then
          has_wildcard = true
          break
        end
      end
      assert.is_true(has_wildcard)
    end)
  end)
end)
