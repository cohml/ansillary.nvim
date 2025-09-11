describe("ansillary integration tests", function()
  local ansillary
  local helper
  local fixtures
  local mock_state

  before_each(function()
    helper = require("tests.test_helper")
    fixtures = require("tests.fixtures.ansi_samples")
    helper.setup_vim_mock()

    -- Enhanced mocking for integration tests
    mock_state = {
      highlights = {},
      extmarks = {},
      buffer_highlights = {},
      namespaces = {},
      sign_calls = {},
    }

    vim.api.nvim_set_hl = function(ns, name, attrs)
      table.insert(mock_state.highlights, {ns = ns, name = name, attrs = attrs})
    end

    vim.api.nvim_buf_add_highlight = function(bufnr, ns_id, hl_group, line, col_start, col_end)
      table.insert(mock_state.buffer_highlights, {
        bufnr = bufnr, ns_id = ns_id, hl_group = hl_group, line = line, col_start = col_start, col_end = col_end
      })
    end

    vim.api.nvim_buf_set_extmark = function(bufnr, ns_id, line, col, opts)
      local mark_id = math.random(1, 1000)
      table.insert(mock_state.extmarks, {
        bufnr = bufnr, ns_id = ns_id, line = line, col = col, opts = opts, mark_id = mark_id
      })
      return mark_id
    end

    vim.api.nvim_create_namespace = function(name)
      local ns_id = #mock_state.namespaces + 1
      table.insert(mock_state.namespaces, {name = name, id = ns_id})
      return ns_id
    end

    -- Mock sign functions
    vim.fn = vim.fn or {}
    vim.fn.sign_define = function(name, opts)
      table.insert(mock_state.sign_calls, {func = "sign_define", args = {name, opts}})
    end
    vim.fn.sign_place = function(id, group, name, buffer, opts)
      table.insert(mock_state.sign_calls, {func = "sign_place", args = {id, group, name, buffer, opts}})
    end
    vim.fn.sign_unplace = function(group, opts)
      table.insert(mock_state.sign_calls, {func = "sign_unplace", args = {group, opts}})
    end

    -- Clear require cache
    package.loaded["ansillary.init"] = nil
    package.loaded["ansillary.config"] = nil
    package.loaded["ansillary.highlights"] = nil
    package.loaded["ansillary.regex"] = nil

    ansillary = require("ansillary.init")
  end)

  describe("basic color processing", function()
    it("should process all basic foreground colors", function()
      for _, sample in ipairs(fixtures.basic_colors) do
        helper.create_test_buffer({sample.text})
        ansillary.setup()
        ansillary._trigger_highlighting_for_tests()

        -- Check that appropriate highlight was created and applied
        local found_color_highlight = false
        for _, hl in ipairs(mock_state.highlights) do
          if hl.name:match("fg" .. sample.expected_fg) then
            found_color_highlight = true
            break
          end
        end
        assert.is_true(found_color_highlight, "Failed to create highlight for: " .. sample.description)

        -- Reset for next iteration
        mock_state.highlights = {}
        mock_state.buffer_highlights = {}
      end
    end)

    it("should process all bright foreground colors", function()
      for _, sample in ipairs(fixtures.bright_colors) do
        helper.create_test_buffer({sample.text})
        ansillary.setup()
        ansillary._trigger_highlighting_for_tests()

        local found_color_highlight = false
        for _, hl in ipairs(mock_state.highlights) do
          if hl.name:match("fg" .. sample.expected_fg) then
            found_color_highlight = true
            break
          end
        end
        assert.is_true(found_color_highlight, "Failed to create highlight for: " .. sample.description)

        mock_state.highlights = {}
        mock_state.buffer_highlights = {}
      end
    end)

    it("should process all background colors", function()
      for _, sample in ipairs(fixtures.background_colors) do
        helper.create_test_buffer({sample.text})
        ansillary.setup()
        ansillary._trigger_highlighting_for_tests()

        local found_color_highlight = false
        for _, hl in ipairs(mock_state.highlights) do
          if hl.name:match("bg" .. sample.expected_bg) then
            found_color_highlight = true
            break
          end
        end
        assert.is_true(found_color_highlight, "Failed to create highlight for: " .. sample.description)

        mock_state.highlights = {}
        mock_state.buffer_highlights = {}
      end
    end)
  end)

  describe("text style processing", function()
    it("should process all text styles", function()
      for _, sample in ipairs(fixtures.text_styles) do
        helper.create_test_buffer({sample.text})
        ansillary.setup()
        ansillary._trigger_highlighting_for_tests()

        -- For supported styles, check highlight creation
        if not sample.expected_attrs.dim and not sample.expected_attrs.blink then
          local found_style_highlight = false
          for _, hl in ipairs(mock_state.highlights) do
            for attr, expected in pairs(sample.expected_attrs) do
              if hl.attrs[attr] == expected then
                found_style_highlight = true
                break
              end
            end
          end
          assert.is_true(found_style_highlight, "Failed to create highlight for: " .. sample.description)
        end

        mock_state.highlights = {}
        mock_state.buffer_highlights = {}
      end
    end)

    it("should process combined styles and colors", function()
      for _, sample in ipairs(fixtures.combined_styles) do
        helper.create_test_buffer({sample.text})
        ansillary.setup()
        ansillary._trigger_highlighting_for_tests()

        -- Should create highlight with combined attributes
        local found_combined_highlight = false
        for _, hl in ipairs(mock_state.highlights) do
          local matches_all = true
          for attr, expected in pairs(sample.expected_attrs) do
            if attr == "fg" then
              if not hl.name:match("fg" .. expected) then
                matches_all = false
                break
              end
            elseif attr == "bg" then
              if not hl.name:match("bg" .. expected) then
                matches_all = false
                break
              end
            else
              if not hl.attrs[attr] then
                matches_all = false
                break
              end
            end
          end
          if matches_all then
            found_combined_highlight = true
            break
          end
        end
        assert.is_true(found_combined_highlight, "Failed to create combined highlight for: " .. sample.description)

        mock_state.highlights = {}
        mock_state.buffer_highlights = {}
      end
    end)
  end)

  describe("escape sequence format support", function()
    it("should handle all escape sequence formats", function()
      for _, sample in ipairs(fixtures.escape_formats) do
        helper.create_test_buffer({sample.text})
        ansillary.setup()

        assert.has_no.errors(function()
          ansillary._trigger_highlighting_for_tests()
        end, "Failed to process: " .. sample.description)

        mock_state.highlights = {}
        mock_state.buffer_highlights = {}
      end
    end)

    it("should handle bash quoted formats", function()
      for _, sample in ipairs(fixtures.bash_quoted) do
        helper.create_test_buffer({sample.text})
        ansillary.setup()

        assert.has_no.errors(function()
          ansillary._trigger_highlighting_for_tests()
        end, "Failed to process: " .. sample.description)

        mock_state.highlights = {}
        mock_state.buffer_highlights = {}
      end
    end)
  end)

  describe("edge case handling", function()
    it("should handle all edge cases gracefully", function()
      for _, sample in ipairs(fixtures.edge_cases) do
        helper.create_test_buffer({sample.text})
        ansillary.setup()

        assert.has_no.errors(function()
          ansillary._trigger_highlighting_for_tests()
        end, "Failed to handle edge case: " .. sample.description)

        mock_state.highlights = {}
        mock_state.buffer_highlights = {}
      end
    end)

    it("should handle real-world samples", function()
      for _, sample in ipairs(fixtures.real_world) do
        helper.create_test_buffer({sample.text})
        ansillary.setup()

        assert.has_no.errors(function()
          ansillary._trigger_highlighting_for_tests()
        end, "Failed to handle real-world sample: " .. sample.description)

        mock_state.highlights = {}
        mock_state.buffer_highlights = {}
      end
    end)
  end)

  describe("multiline processing", function()
    it("should handle complex multiline samples", function()
      for _, sample in ipairs(fixtures.multiline_samples) do
        helper.create_test_buffer(sample.lines)
        ansillary.setup()

        assert.has_no.errors(function()
          ansillary._trigger_highlighting_for_tests()
        end, "Failed to handle multiline sample: " .. sample.description)

        -- Should create highlights for multiple lines
        assert.is_true(#mock_state.highlights > 0, "No highlights created for: " .. sample.description)
        assert.is_true(#mock_state.buffer_highlights > 0, "No buffer highlights applied for: " .. sample.description)

        mock_state.highlights = {}
        mock_state.buffer_highlights = {}
      end
    end)
  end)

  describe("concealment integration", function()
    it("should create extmarks for concealment", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({conceal = true, reveal_on_cursorline = false})
      ansillary._trigger_highlighting_for_tests()

      -- Should create concealment extmarks
      local concealment_extmarks = 0
      for _, extmark in ipairs(mock_state.extmarks) do
        if extmark.opts.conceal == "" then
          concealment_extmarks = concealment_extmarks + 1
        end
      end
      assert.is_true(concealment_extmarks > 0, "No concealment extmarks created")
    end)

    it("should respect reveal_on_cursorline setting", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      vim.api.nvim_win_get_cursor = function(winid) return {1, 0} end

      ansillary.setup({conceal = true, reveal_on_cursorline = true})
      ansillary._trigger_highlighting_for_tests()

      -- Should not conceal on cursor line
      local concealed_on_cursor_line = false
      for _, extmark in ipairs(mock_state.extmarks) do
        if extmark.line == 0 and extmark.opts.conceal == "" then
          concealed_on_cursor_line = true
          break
        end
      end
      assert.is_false(concealed_on_cursor_line, "ANSI codes concealed on cursor line when reveal_on_cursorline is true")
    end)
  end)

  describe("ANSI highlighting integration", function()
    it("should highlight ANSI sequences with custom formatting", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({
        ansi_highlights = {
          enabled = true,
          format = {
            fg = {color = "#666666", style = "bold"},
            bg = {color = "auto"}
          }
        }
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should create ANSI sequence highlights
      local ansi_highlights = 0
      for _, hl in ipairs(mock_state.highlights) do
        if hl.name:match("AnsillaryANSI_") then
          ansi_highlights = ansi_highlights + 1
        end
      end
      assert.is_true(ansi_highlights > 0, "No ANSI sequence highlights created")

      -- Should apply highlights to buffer
      local ansi_buffer_highlights = 0
      for _, buf_hl in ipairs(mock_state.buffer_highlights) do
        if buf_hl.hl_group:match("AnsillaryANSI_") then
          ansi_buffer_highlights = ansi_buffer_highlights + 1
        end
      end
      assert.is_true(ansi_buffer_highlights > 0, "No ANSI sequence highlights applied to buffer")
    end)

    it("should use auto inheritance correctly", function()
      helper.create_test_buffer({"\\033[1;31mbold red\\033[0m"})
      ansillary.setup({
        ansi_highlights = {
          enabled = true,
          format = {
            fg = {color = "auto", style = "auto"},
            bg = {color = "auto"}
          }
        }
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should reuse existing highlight groups for auto inheritance
      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end, "Auto inheritance failed")
    end)
  end)

  describe("filetype filtering integration", function()
    it("should process enabled filetypes", function()
      vim.bo.filetype = "log"
      helper.create_test_buffer({"\\033[31mlog entry\\033[0m"})
      ansillary.setup({enabled_filetypes = {"log", "txt"}})
      ansillary._trigger_highlighting_for_tests()

      assert.is_true(#mock_state.highlights > 0, "No highlights created for enabled filetype")
    end)

    it("should skip disabled filetypes", function()
      vim.bo.filetype = "markdown"
      helper.create_test_buffer({"\\033[31mmarkdown text\\033[0m"})
      ansillary.setup({
        enabled_filetypes = {"*"},
        disabled_filetypes = {"markdown"}
      })

      -- Should setup without error
      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)

      -- Should have correct configuration
      local state = ansillary.get_state()
      assert.are.same({"*"}, state.config.enabled_filetypes)
      assert.are.same({"markdown"}, state.config.disabled_filetypes)
    end)

    it("should handle file extension matching", function()
      vim.api.nvim_buf_get_name = function(bufnr) return "/path/to/file.log" end
      helper.create_test_buffer({"\\033[32mlog file content\\033[0m"})
      ansillary.setup({enabled_filetypes = {"*.log"}})
      ansillary._trigger_highlighting_for_tests()

      assert.is_true(#mock_state.highlights > 0, "No highlights created for file extension match")
    end)
  end)

  describe("full workflow integration", function()
    it("should handle complete highlighting workflow", function()
      local test_content = {
        "\\033[1;34m=== Test Output ===\\033[0m",
        "\\033[32m✓ Test 1 passed\\033[0m",
        "\\033[31m✗ Test 2 failed\\033[0m",
        "\\033[33m⚠ Test 3 warning\\033[0m"
      }

      helper.create_test_buffer(test_content)
      ansillary.setup({
        conceal = true,
        reveal_on_cursorline = true,
        ansi_highlights = {
          enabled = true,
          format = {
            fg = {color = "auto", style = "auto"},
            bg = {color = "auto"},
          },
        },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should create multiple highlights
      assert.is_true(#mock_state.highlights >= 4, "Not enough highlights created")
      -- Should apply highlights to buffer
      assert.is_true(#mock_state.buffer_highlights >= 4, "Not enough buffer highlights applied")
      -- Should create concealment extmarks
      assert.is_true(#mock_state.extmarks > 0, "No concealment extmarks created")
    end)

    it("should handle toggle operations correctly", function()
      helper.create_test_buffer({"\\033[31mtest\\033[0m"})
      ansillary.setup()

      -- Initial state
      assert.are.equal(true, ansillary.enabled)

      -- Toggle plugin off
      ansillary.toggle()
      assert.are.equal(false, ansillary.enabled)

      -- Toggle plugin back on
      ansillary.toggle()
      assert.are.equal(true, ansillary.enabled)

      -- Toggle concealment
      local initial_conceal = ansillary.get_state().config.conceal
      ansillary.toggle_conceal()
      assert.are.equal(not initial_conceal, ansillary.get_state().config.conceal)

      -- Toggle reveal on cursorline
      local initial_reveal = ansillary.get_state().config.reveal_on_cursorline
      ansillary.toggle_reveal()
      assert.are.equal(not initial_reveal, ansillary.get_state().config.reveal_on_cursorline)

      -- Toggle text highlighting
      local initial_text = ansillary.get_state().config.text_highlights.enabled
      ansillary.toggle_text_highlights()
      assert.are.equal(not initial_text, ansillary.get_state().config.text_highlights.enabled)

      -- Toggle ANSI highlighting
      local initial_ansi = ansillary.get_state().config.ansi_highlights.enabled
      ansillary.toggle_ansi_highlights()
      assert.are.equal(not initial_ansi, ansillary.get_state().config.ansi_highlights.enabled)
    end)
  end)

  describe("text_highlights integration", function()
    it("should apply text highlighting by default", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({
        text_highlights = {
          enabled = true,
          format = {
            fg = { color = "auto", style = "auto" },
            bg = { color = "auto" },
          },
        },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should create highlights for text content
      assert.is_true(#mock_state.highlights > 0, "No highlights created for text content")
      assert.is_true(#mock_state.buffer_highlights > 0, "No buffer highlights applied for text content")
    end)

    it("should disable text highlighting when enabled = false", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({
        text_highlights = {
          enabled = false,
        },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should not create any text highlights
      local text_highlights = 0
      for _, highlight in ipairs(mock_state.buffer_highlights) do
        if highlight.hl_group:match("^Ansillary") then
          text_highlights = text_highlights + 1
        end
      end
      assert.are.equal(0, text_highlights, "Text highlights created when disabled")
    end)

    it("should use custom colors when specified", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({
        text_highlights = {
          enabled = true,
          format = {
            fg = { color = "#00ff00", style = "auto" },
            bg = { color = "auto" },
          },
        },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should create a custom highlight with the specified color
      local found_custom = false
      for _, highlight in ipairs(mock_state.highlights) do
        if highlight.name == "AnsillaryText_Custom" and highlight.attrs.fg == "#00ff00" then
          found_custom = true
          break
        end
      end
      assert.is_true(found_custom, "Custom text highlight not created")
    end)

    it("should use custom styles when specified", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({
        text_highlights = {
          enabled = true,
          format = {
            fg = { color = "auto", style = "bold,italic" },
            bg = { color = "auto" },
          },
        },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should create a custom highlight with the specified styles
      local found_custom = false
      for _, highlight in ipairs(mock_state.highlights) do
        if highlight.name == "AnsillaryText_Custom" and
           highlight.attrs.bold and highlight.attrs.italic then
          found_custom = true
          break
        end
      end
      assert.is_true(found_custom, "Custom text highlight with styles not created")
    end)
  end)

  describe("signcolumn integration", function()
    it("should place signs for lines with ANSI codes when enabled", function()
      helper.create_test_buffer({
        "normal line",
        "\\033[31mred text\\033[0m",
        "another normal line",
        "\\e[1;32mbold green\\e[0m"
      })
      ansillary.setup({
        signcolumn = {
          enabled = true,
          icon = "A",
          color = "#6d8086",
        },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should place signs only for lines 2 and 4 (with ANSI codes)
      local sign_placements = 0
      for _, sign_call in ipairs(mock_state.sign_calls) do
        if sign_call.func == "sign_place" then
          sign_placements = sign_placements + 1
        end
      end
      assert.are.equal(2, sign_placements, "Should place exactly 2 signs")
    end)

    it("should not place signs when disabled", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({
        signcolumn = { enabled = false, },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should not place any signs
      local sign_placements = 0
      for _, sign_call in ipairs(mock_state.sign_calls) do
        if sign_call.func == "sign_place" then
          sign_placements = sign_placements + 1
        end
      end
      assert.are.equal(0, sign_placements, "Should not place any signs when disabled")
    end)
  end)
end)
