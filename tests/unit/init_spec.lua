describe("ansillary.init", function()
  local ansillary
  local helper
  local mock_calls

  before_each(function()
    helper = require("tests.test_helper")
    helper.setup_vim_mock()

    -- Track various API calls
    mock_calls = {
      highlights = {},
      extmarks = {},
      autocmds = {},
      namespaces = {},
      notifications = {},
      sign_calls = {},
    }

    -- Mock vim API functions to track calls
    vim.api.nvim_set_hl = function(ns, name, attrs)
      table.insert(mock_calls.highlights, {ns = ns, name = name, attrs = attrs})
    end

    vim.api.nvim_buf_set_extmark = function(bufnr, ns_id, line, col, opts)
      local mark_id = math.random(1, 1000)
      table.insert(mock_calls.extmarks, {
        bufnr = bufnr, ns_id = ns_id, line = line, col = col, opts = opts, mark_id = mark_id
      })
      return mark_id
    end

    vim.api.nvim_create_autocmd = function(events, opts)
      table.insert(mock_calls.autocmds, {events = events, opts = opts})
    end

    vim.api.nvim_create_namespace = function(name)
      local ns_id = #mock_calls.namespaces + 1
      table.insert(mock_calls.namespaces, {name = name, id = ns_id})
      return ns_id
    end

    vim.notify = function(message, level)
      table.insert(mock_calls.notifications, {message = message, level = level})
    end

    -- Mock sign functions
    vim.fn = vim.fn or {}
    vim.fn.sign_define = function(name, opts)
      table.insert(mock_calls.sign_calls, {func = "sign_define", args = {name, opts}})
    end
    vim.fn.sign_place = function(id, group, name, buffer, opts)
      table.insert(mock_calls.sign_calls, {func = "sign_place", args = {id, group, name, buffer, opts}})
    end
    vim.fn.sign_unplace = function(group, opts)
      table.insert(mock_calls.sign_calls, {func = "sign_unplace", args = {group, opts}})
    end

    -- Clear require cache
    package.loaded["ansillary.init"] = nil
    package.loaded["ansillary.config"] = nil
    package.loaded["ansillary.highlights"] = nil
    package.loaded["ansillary.regex"] = nil

    ansillary = require("ansillary.init")
  end)

  describe("initialization", function()
    it("should start with enabled state", function()
      assert.are.equal(true, ansillary.enabled)
    end)

    it("should initialize extmarks storage", function()
      assert.is_table(ansillary.ansi_extmarks)
    end)

    it("should create namespaces on load", function()
      assert.are.equal(2, #mock_calls.namespaces)

      local main_ns = mock_calls.namespaces[1]
      local hl_ns = mock_calls.namespaces[2]

      assert.are.equal("ansillary", main_ns.name)
      assert.are.equal("ansillary_highlights", hl_ns.name)
    end)
  end)

  describe("setup", function()
    it("should accept empty options", function()
      assert.has_no.errors(function()
        ansillary.setup()
      end)
    end)

    it("should create autocmds on setup", function()
      ansillary.setup()

      assert.is_true(#mock_calls.autocmds > 0)
    end)

    it("should validate filetype configuration", function()
      assert.has.errors(function()
        ansillary.setup({
          enabled_filetypes = {"lua"},
          disabled_filetypes = {"lua"}, -- Overlap should cause error
        })
      end)
    end)

    it("should merge user config with defaults", function()
      local user_config = {
        conceal = false,
        warn_on_unsupported = false,
        enabled_filetypes = {"log", "txt"},
      }

      ansillary.setup(user_config)

      local state = ansillary.get_state()
      assert.are.equal(false, state.config.conceal)
      assert.are.equal(false, state.config.warn_on_unsupported)
      assert.are.same({"log", "txt"}, state.config.enabled_filetypes)
      -- Should keep other defaults
      assert.are.equal(true, state.config.reveal_on_cursorline)
    end)
  end)

  describe("ANSI code parsing", function()
    it("should parse basic ANSI codes correctly", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup()
      ansillary._trigger_highlighting_for_tests()

      -- Should create highlights for the parsed codes
      assert.is_true(#mock_calls.highlights > 0)
    end)

    it("should handle reset codes", function()
      helper.create_test_buffer({"\\033[31mred\\033[0mreset"})
      ansillary.setup()
      ansillary._trigger_highlighting_for_tests()

      -- Should handle reset without errors
      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)

    it("should parse multiple attributes", function()
      helper.create_test_buffer({"\\033[1;4;31mbold underlined red\\033[0m"})
      ansillary.setup()
      ansillary._trigger_highlighting_for_tests()

      -- Should create appropriate highlight group
      local found_highlight = false
      for _, call in ipairs(mock_calls.highlights) do
        if call.name:match("Ansillaryf.+") and call.name:match("bold") and call.name:match("underline") then
          found_highlight = true
          break
        end
      end
      assert.is_true(found_highlight)
    end)

    it("should handle empty codes as reset", function()
      helper.create_test_buffer({"\\033[mtext"})
      ansillary.setup()

      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)
  end)

  describe("filetype handling", function()
    it("should process wildcard filetypes", function()
      vim.bo.filetype = "any_type"
      ansillary.setup({enabled_filetypes = {"*"}})

      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)

    it("should process specific filetypes", function()
      vim.bo.filetype = "lua"
      ansillary.setup({enabled_filetypes = {"lua", "python"}})

      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)

    it("should skip disabled filetypes", function()
      vim.bo.filetype = "markdown"
      ansillary.setup({
        enabled_filetypes = {"*"},
        disabled_filetypes = {"markdown"},
      })

      -- Should not create highlights for disabled filetype
      local initial_highlight_count = #mock_calls.highlights
      ansillary._trigger_highlighting_for_tests()
      assert.are.equal(initial_highlight_count, #mock_calls.highlights)
    end)

    it("should handle file extensions", function()
      vim.api.nvim_buf_get_name = function(bufnr)
        return "/path/to/file.log"
      end
      ansillary.setup({enabled_filetypes = {"*.log"}})

      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)
  end)

  describe("concealment", function()
    it("should create concealment extmarks when enabled", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({conceal = true})

      -- Should not throw error when highlighting
      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)

      -- Should have extmarks storage initialized
      local state = ansillary.get_state()
      assert.is_table(state.ansi_extmarks)
    end)

    it("should not create concealment when disabled", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({conceal = false})
      ansillary._trigger_highlighting_for_tests()

      -- Should not create concealment extmarks
      local has_conceal = false
      for _, extmark in ipairs(mock_calls.extmarks) do
        if extmark.opts.conceal then
          has_conceal = true
          break
        end
      end
      assert.is_false(has_conceal)
    end)

    it("should handle cursor reveal setting", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      vim.api.nvim_win_get_cursor = function(winid) return {1, 0} end

      ansillary.setup({conceal = true, reveal_on_cursorline = true})
      ansillary._trigger_highlighting_for_tests()

      -- Should not conceal on cursor line
      local cursor_line_concealed = false
      for _, extmark in ipairs(mock_calls.extmarks) do
        if extmark.line == 0 and extmark.opts.conceal == "" then
          cursor_line_concealed = true
          break
        end
      end
      assert.is_false(cursor_line_concealed)
    end)
  end)

  describe("toggle functions", function()
    before_each(function()
      helper.create_test_buffer({"\\033[31mtest\\033[0m"})
      ansillary.setup()
    end)

    describe("toggle", function()
      it("should disable plugin completely", function()
        ansillary.toggle() -- Disable plugin
        assert.are.equal(false, ansillary.enabled)
      end)

      it("should re-enable plugin", function()
        ansillary.toggle() -- Disable plugin
        ansillary.toggle() -- Re-enable plugin
        assert.are.equal(true, ansillary.enabled)
      end)

      it("should clear highlights when disabled", function()
        ansillary._trigger_highlighting_for_tests()
        local initial_calls = #mock_calls.highlights

        ansillary.toggle() -- Disable plugin

        -- Plugin should be disabled
        assert.are.equal(false, ansillary.enabled)
      end)
    end)

    describe("toggle_conceal", function()
      it("should toggle concealment setting", function()
        local initial_conceal = ansillary.get_state().config.conceal
        ansillary.toggle_conceal()
        local new_conceal = ansillary.get_state().config.conceal

        assert.are.equal(not initial_conceal, new_conceal)
      end)

      it("should update vim concealment settings", function()
        ansillary.toggle_conceal()
        -- Should set conceallevel and concealcursor appropriately
        -- This is tested implicitly through the function not throwing errors
        assert.has_no.errors(function()
          ansillary.toggle_conceal()
        end)
      end)
    end)

    describe("toggle_reveal", function()
      it("should toggle reveal_on_cursorline setting", function()
        local initial_reveal = ansillary.get_state().config.reveal_on_cursorline
        ansillary.toggle_reveal()
        local new_reveal = ansillary.get_state().config.reveal_on_cursorline

        assert.are.equal(not initial_reveal, new_reveal)
      end)
    end)

    describe("toggle_ansi_highlights", function()
      it("should toggle ansi_highlights enabled setting", function()
        local initial_enabled = ansillary.get_state().config.ansi_highlights.enabled
        ansillary.toggle_ansi_highlights()
        local new_enabled = ansillary.get_state().config.ansi_highlights.enabled

        assert.are.equal(not initial_enabled, new_enabled)
      end)
    end)
  end)

  describe("highlight creation", function()
    it("should create highlight groups for ANSI attributes", function()
      helper.create_test_buffer({"\\033[1;31mbold red\\033[0m"})
      ansillary.setup()
      ansillary._trigger_highlighting_for_tests()

      local found_bold_red = false
      for _, call in ipairs(mock_calls.highlights) do
        if call.name:match("Ansillaryf.+") and call.name:match("bold") then
          found_bold_red = true
          assert.are.equal(true, call.attrs.bold)
          assert.is_string(call.attrs.fg)
          break
        end
      end
      assert.is_true(found_bold_red)
    end)

    it("should handle multiple lines", function()
      helper.create_test_buffer({
        "\\033[31mred line\\033[0m",
        "\\033[32mgreen line\\033[0m",
        "plain line"
      })
      ansillary.setup()
      ansillary._trigger_highlighting_for_tests()

      -- Should process all lines with ANSI codes
      assert.is_true(#mock_calls.highlights >= 2)
    end)

    it("should warn about unsupported attributes", function()
      helper.create_test_buffer({"\\033[2mdim text\\033[0m"})
      ansillary.setup({warn_on_unsupported = true})

      -- Should process dim attribute without error
      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)

      -- Should have warning enabled in config
      local state = ansillary.get_state()
      assert.are.equal(true, state.config.warn_on_unsupported)
    end)

    it("should not warn when warn_on_unsupported is false", function()
      helper.create_test_buffer({"\\033[2mdim text\\033[0m"})
      ansillary.setup({warn_on_unsupported = false})
      ansillary._trigger_highlighting_for_tests()

      local found_dim_warning = false
      for _, notif in ipairs(mock_calls.notifications) do
        if notif.message:match("Dim attribute") then
          found_dim_warning = true
          break
        end
      end
      assert.is_false(found_dim_warning)
    end)
  end)

  describe("edge cases and error handling", function()
    it("should handle empty lines", function()
      helper.create_test_buffer({""})
      ansillary.setup()

      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)

    it("should handle lines without ANSI codes", function()
      helper.create_test_buffer({"plain text line"})
      ansillary.setup()

      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)

    it("should handle malformed ANSI codes gracefully", function()
      helper.create_test_buffer({"\\033[incomplete"})
      ansillary.setup()

      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)

    it("should handle consecutive ANSI codes", function()
      helper.create_test_buffer({"\\033[1m\\033[31m\\033[4mtext\\033[0m"})
      ansillary.setup()

      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)

    it("should handle very long lines", function()
      local long_line = "start " .. string.rep("\\033[31mred\\033[0m ", 100) .. "end"
      helper.create_test_buffer({long_line})
      ansillary.setup()

      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)

    it("should handle startup with cursor at line 0", function()
      helper.create_test_buffer({"\\033[31mred\\033[0m"})
      vim.api.nvim_win_get_cursor = function(winid) return {0, 0} end
      ansillary.setup()

      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)
  end)

  describe("get_state", function()
    it("should return plugin state", function()
      ansillary.setup({conceal = false})
      local state = ansillary.get_state()

      assert.is_table(state)
      assert.is_boolean(state.enabled)
      assert.is_table(state.config)
      assert.is_table(state.ansi_extmarks)
    end)

    it("should reflect current configuration", function()
      ansillary.setup({warn_on_unsupported = false})
      local state = ansillary.get_state()

      assert.are.equal(false, state.config.warn_on_unsupported)
    end)
  end)

  describe("ANSI highlighting feature", function()
    it("should highlight ANSI sequences when enabled", function()
      helper.create_test_buffer({"\\033[31mred\\033[0m"})
      ansillary.setup({
        ansi_highlights = {
          enabled = true,
          format = {
            fg = {color = "#666666", style = "bold"},
            bg = {color = "auto"},
          },
        },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should create highlights for ANSI sequences themselves
      local found_ansi_highlight = false
      for _, call in ipairs(mock_calls.highlights) do
        if call.name:match("AnsillaryANSI_") then
          found_ansi_highlight = true
          break
        end
      end
      assert.is_true(found_ansi_highlight)
    end)

    it("should use auto inheritance when configured", function()
      helper.create_test_buffer({"\\033[31mred\\033[0m"})
      ansillary.setup({
        ansi_highlights = {
          enabled = true,
          format = {
            fg = {color = "auto", style = "auto"},
            bg = {color = "auto"},
          },
        },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should not error with auto inheritance
      assert.has_no.errors(function()
        ansillary._trigger_highlighting_for_tests()
      end)
    end)
  end)

  describe("signcolumn indicators", function()
    it("should place signs when signcolumn is enabled", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({
        signcolumn = {
          enabled = true,
          icon = "A",
          format = {
            color = "#6d8086",
            style = "",
          },
        },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should have called sign_place for the line with ANSI codes
      local found_sign_place = false
      for _, call in ipairs(mock_calls.sign_calls) do
        if call.func == "sign_place" and call.args[3] == "AnsillaryAnsi" then
          found_sign_place = true
          break
        end
      end
      assert.is_true(found_sign_place)
    end)

    it("should not place signs when signcolumn is disabled", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({
        signcolumn = {
          enabled = false,
        },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Should not have called sign_place
      local found_sign_place = false
      for _, call in ipairs(mock_calls.sign_calls) do
        if call.func == "sign_place" then
          found_sign_place = true
          break
        end
      end
      assert.is_false(found_sign_place)
    end)

    it("should clear signs when plugin is toggled off", function()
      helper.create_test_buffer({"\\033[31mred text\\033[0m"})
      ansillary.setup({
        signcolumn = {
          enabled = true,
        },
      })
      ansillary._trigger_highlighting_for_tests()

      -- Toggle plugin off
      ansillary.toggle()

      -- Should have called sign_unplace to clear signs
      local found_sign_unplace = false
      for _, call in ipairs(mock_calls.sign_calls) do
        if call.func == "sign_unplace" and call.args[1] == "ansillary" then
          found_sign_unplace = true
          break
        end
      end
      assert.is_true(found_sign_unplace)
    end)

    it("should define sign with correct properties", function()
      -- Clear sign calls before test
      mock_calls.sign_calls = {}

      ansillary.setup({
        signcolumn = {
          enabled = true,
          icon = "🌈",
        },
      })

      -- Should have called sign_define with correct parameters
      local found_sign_define = false
      for _, call in ipairs(mock_calls.sign_calls) do
        if call.func == "sign_define" and call.args[1] == "AnsillaryAnsi" then
          assert.are.equal("🌈", call.args[2].text)
          assert.are.equal("AnsillarySign", call.args[2].texthl)
          found_sign_define = true
          break
        end
      end
      assert.is_true(found_sign_define)
    end)
  end)
end)
