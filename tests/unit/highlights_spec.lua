describe("ansillary.highlights", function()
  local highlights
  local helper
  local mock_highlight_calls

  before_each(function()
    helper = require("tests.test_helper")
    helper.setup_vim_mock()

    -- Track highlight calls
    mock_highlight_calls = {}
    vim.api.nvim_set_hl = function(ns, name, attrs)
      table.insert(mock_highlight_calls, {ns = ns, name = name, attrs = attrs})
    end

    -- Clear require cache
    package.loaded["ansillary.highlights"] = nil
    highlights = require("ansillary.highlights")
  end)

  describe("color mapping", function()
    it("should return correct basic colors", function()
      assert.are.equal("#000000", highlights.get_color(0)) -- Black
      assert.are.equal("#cd0000", highlights.get_color(1)) -- Red
      assert.are.equal("#00cd00", highlights.get_color(2)) -- Green
      assert.are.equal("#cdcd00", highlights.get_color(3)) -- Yellow
      assert.are.equal("#0000ee", highlights.get_color(4)) -- Blue
      assert.are.equal("#cd00cd", highlights.get_color(5)) -- Magenta
      assert.are.equal("#00cdcd", highlights.get_color(6)) -- Cyan
      assert.are.equal("#e5e5e5", highlights.get_color(7)) -- White
    end)

    it("should return correct bright colors", function()
      assert.are.equal("#7f7f7f", highlights.get_color(8))  -- Bright Black
      assert.are.equal("#ff0000", highlights.get_color(9))  -- Bright Red
      assert.are.equal("#00ff00", highlights.get_color(10)) -- Bright Green
      assert.are.equal("#ffff00", highlights.get_color(11)) -- Bright Yellow
      assert.are.equal("#5c5cff", highlights.get_color(12)) -- Bright Blue
      assert.are.equal("#ff00ff", highlights.get_color(13)) -- Bright Magenta
      assert.are.equal("#00ffff", highlights.get_color(14)) -- Bright Cyan
      assert.are.equal("#ffffff", highlights.get_color(15)) -- Bright White
    end)

    it("should return white for out-of-range colors", function()
      assert.are.equal("#ffffff", highlights.get_color(16))
      assert.are.equal("#ffffff", highlights.get_color(255))
      -- NOTE: negative numbers return nil due to current implementation
      assert.is_nil(highlights.get_color(-1))
    end)
  end)

  describe("create_base_highlights", function()
    it("should create concealment highlight", function()
      highlights.create_base_highlights()

      local conceal_call = nil
      for _, call in ipairs(mock_highlight_calls) do
        if call.name == "AnsillaryConceal" then
          conceal_call = call
          break
        end
      end

      assert.is_not_nil(conceal_call)
      assert.are.equal("NONE", conceal_call.attrs.fg)
      assert.are.equal("NONE", conceal_call.attrs.bg)
      assert.are.equal(100, conceal_call.attrs.blend)
    end)

    it("should create foreground color highlights", function()
      highlights.create_base_highlights()

      for i = 0, 15 do
        local fg_call = nil
        local expected_name = "AnsillaryFg" .. i
        for _, call in ipairs(mock_highlight_calls) do
          if call.name == expected_name then
            fg_call = call
            break
          end
        end

        assert.is_not_nil(fg_call, "Missing fg highlight for color " .. i)
        assert.are.equal(highlights.get_color(i), fg_call.attrs.fg)
      end
    end)

    it("should create background color highlights", function()
      highlights.create_base_highlights()

      for i = 0, 15 do
        local bg_call = nil
        local expected_name = "AnsillaryBg" .. i
        for _, call in ipairs(mock_highlight_calls) do
          if call.name == expected_name then
            bg_call = call
            break
          end
        end

        assert.is_not_nil(bg_call, "Missing bg highlight for color " .. i)
        assert.are.equal(highlights.get_color(i), bg_call.attrs.bg)
      end
    end)

    it("should create style highlights", function()
      highlights.create_base_highlights()

      local expected_styles = {
        {name = "AnsillaryBold", attr = "bold"},
        {name = "AnsillaryDim", attr = "italic"}, -- NOTE: Dim maps to italic
        {name = "AnsillaryItalic", attr = "italic"},
        {name = "AnsillaryUnderline", attr = "underline"},
        {name = "AnsillaryReverse", attr = "reverse"},
        {name = "AnsillaryStrikethrough", attr = "strikethrough"}
      }

      for _, expected in ipairs(expected_styles) do
        local style_call = nil
        for _, call in ipairs(mock_highlight_calls) do
          if call.name == expected.name then
            style_call = call
            break
          end
        end

        assert.is_not_nil(style_call, "Missing style highlight: " .. expected.name)
        assert.are.equal(true, style_call.attrs[expected.attr])
      end
    end)
  end)

  describe("create_ansi_highlight", function()
    local test_text_attrs

    before_each(function()
      test_text_attrs = {
        fg = "#ff0000",
        bg = "#00ff00",
        bold = true,
        italic = true,
        underline = false,
        reverse = false,
        strikethrough = false
      }
    end)

    it("should inherit colors when set to auto", function()
      local ansi_config = {
        fg = {color = "auto", style = "auto"},
        bg = {color = "auto"},
      }

      local result = highlights.create_ansi_highlight(test_text_attrs, ansi_config)

      assert.are.equal("#ff0000", result.fg)
      assert.are.equal("#00ff00", result.bg)
    end)

    it("should use custom colors when specified", function()
      local ansi_config = {
        fg = {color = "#0000ff", style = "auto"},
        bg = {color = "#ffff00"}
      }

      local result = highlights.create_ansi_highlight(test_text_attrs, ansi_config)

      assert.are.equal("#0000ff", result.fg)
      assert.are.equal("#ffff00", result.bg)
    end)

    it("should inherit styles when set to auto", function()
      local ansi_config = {
        fg = {color = "auto", style = "auto"},
        bg = {color = "auto"},
      }

      local result = highlights.create_ansi_highlight(test_text_attrs, ansi_config)

      assert.are.equal(true, result.bold)
      assert.are.equal(true, result.italic)
      assert.is_nil(result.underline)
      assert.is_nil(result.reverse)
      assert.is_nil(result.strikethrough)
    end)

    it("should parse custom style strings", function()
      local ansi_config = {
        fg = {color = "auto", style = "bold,underline"},
        bg = {color = "auto"}
      }

      local result = highlights.create_ansi_highlight(test_text_attrs, ansi_config)

      assert.are.equal(true, result.bold)
      assert.are.equal(true, result.underline)
      assert.is_nil(result.italic)
    end)

    it("should handle multiple custom styles", function()
      local ansi_config = {
        fg = {color = "auto", style = "italic,reverse,strikethrough"},
        bg = {color = "auto"}
      }

      local result = highlights.create_ansi_highlight(test_text_attrs, ansi_config)

      assert.are.equal(true, result.italic)
      assert.are.equal(true, result.reverse)
      assert.are.equal(true, result.strikethrough)
      assert.is_nil(result.bold)
      assert.is_nil(result.underline)
    end)

    it("should trim whitespace in style strings", function()
      local ansi_config = {
        fg = {color = "auto", style = " bold , italic , underline "},
        bg = {color = "auto"}
      }

      local result = highlights.create_ansi_highlight(test_text_attrs, ansi_config)

      assert.are.equal(true, result.bold)
      assert.are.equal(true, result.italic)
      assert.are.equal(true, result.underline)
    end)

    it("should handle empty style strings", function()
      local ansi_config = {
        fg = {color = "auto", style = ""},
        bg = {color = "auto"}
      }

      local result = highlights.create_ansi_highlight(test_text_attrs, ansi_config)

      -- Should not have any style attributes
      assert.is_nil(result.bold)
      assert.is_nil(result.italic)
      assert.is_nil(result.underline)
    end)

    it("should ignore invalid style names", function()
      local ansi_config = {
        fg = {color = "auto", style = "bold,invalid,italic,unknown"},
        bg = {color = "auto"}
      }

      local result = highlights.create_ansi_highlight(test_text_attrs, ansi_config)

      assert.are.equal(true, result.bold)
      assert.are.equal(true, result.italic)
      -- Invalid styles should not be set
      assert.is_nil(result.invalid)
      assert.is_nil(result.unknown)
    end)
  end)

  describe("create_text_highlight", function()
    local test_parsed_attrs

    before_each(function()
      test_parsed_attrs = {
        fg = 1,  -- Red
        bg = 4,  -- Blue
        bold = true,
        italic = false,
        underline = true,
        reverse = false,
        strikethrough = false
      }
    end)

    it("should inherit ANSI colors when set to auto", function()
      local text_config = {
        fg = { color = "auto", style = "auto" },
        bg = { color = "auto" }
      }

      local result = highlights.create_text_highlight(test_parsed_attrs, text_config)

      assert.are.equal(highlights.get_color(1), result.fg)
      assert.are.equal(1, result.ctermfg)
      assert.are.equal(highlights.get_color(4), result.bg)
      assert.are.equal(4, result.ctermbg)
      assert.are.equal(true, result.bold)
      assert.are.equal(true, result.underline)
      assert.is_nil(result.italic)
      assert.is_nil(result.reverse)
      assert.is_nil(result.strikethrough)
    end)

    it("should use custom colors when specified", function()
      local text_config = {
        fg = { color = "#ff00ff", style = "auto" },
        bg = { color = "#00ffff" }
      }

      local result = highlights.create_text_highlight(test_parsed_attrs, text_config)

      assert.are.equal("#ff00ff", result.fg)
      assert.are.equal("#00ffff", result.bg)
      assert.is_nil(result.ctermfg)
      assert.is_nil(result.ctermbg)
      -- Should still inherit ANSI styling
      assert.are.equal(true, result.bold)
      assert.are.equal(true, result.underline)
    end)

    it("should use custom styles when specified", function()
      local text_config = {
        fg = { color = "auto", style = "italic,reverse" },
        bg = { color = "auto" }
      }

      local result = highlights.create_text_highlight(test_parsed_attrs, text_config)

      -- Should use ANSI colors
      assert.are.equal(highlights.get_color(1), result.fg)
      assert.are.equal(highlights.get_color(4), result.bg)
      -- Should use custom styles, ignoring ANSI styling
      assert.are.equal(true, result.italic)
      assert.are.equal(true, result.reverse)
      assert.is_nil(result.bold)
      assert.is_nil(result.underline)
      assert.is_nil(result.strikethrough)
    end)

    it("should handle missing ANSI attributes with auto mode", function()
      local attrs_no_colors = {
        bold = true
      }

      local text_config = {
        fg = { color = "auto", style = "auto" },
        bg = { color = "auto" }
      }

      local result = highlights.create_text_highlight(attrs_no_colors, text_config)

      assert.is_nil(result.fg)
      assert.is_nil(result.bg)
      assert.is_nil(result.ctermfg)
      assert.is_nil(result.ctermbg)
      assert.are.equal(true, result.bold)
    end)
  end)

  describe("edge cases", function()
    it("should handle nil text attributes", function()
      local ansi_config = {
        fg = {color = "#ffffff", style = "bold"},
        bg = {color = "#000000"}
      }

      local result = highlights.create_ansi_highlight({}, ansi_config)

      assert.are.equal("#ffffff", result.fg)
      assert.are.equal("#000000", result.bg)
      assert.are.equal(true, result.bold)
    end)

    it("should handle missing text attribute fields", function()
      local text_attrs = {fg = "#ff0000"} -- Missing other fields
      local ansi_config = {
        fg = {color = "auto", style = "auto"},
        bg = {color = "auto"},
      }

      local result = highlights.create_ansi_highlight(text_attrs, ansi_config)

      assert.are.equal("#ff0000", result.fg)
      assert.is_nil(result.bg)
      -- Should not throw error on missing style fields
    end)

    it("should handle mixed auto and custom configuration", function()
      local text_attrs = {
        fg = "#red",
        bg = "#green",
        bold = true
      }
      local ansi_config = {
        fg = {color = "auto", style = "italic,underline"},
        bg = {color = "#blue"},
      }

      local result = highlights.create_ansi_highlight(text_attrs, ansi_config)

      assert.are.equal("#red", result.fg) -- Auto color
      assert.are.equal("#blue", result.bg) -- Custom color
      assert.are.equal(true, result.italic) -- Custom style
      assert.are.equal(true, result.underline) -- Custom style
      assert.is_nil(result.bold) -- Not inherited when using custom styles
    end)
  end)
end)
