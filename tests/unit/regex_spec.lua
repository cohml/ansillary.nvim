describe("ansillary.regex", function()
  local regex
  local helper

  before_each(function()
    helper = require("tests.test_helper")
    helper.setup_vim_mock()

    -- Clear require cache
    package.loaded["ansillary.regex"] = nil
    regex = require("ansillary.regex")
  end)

  describe("ANSI pattern matching", function()
    it("should match basic octal escape sequences", function()
      local line = "Hello \\033[31mworld\\033[0m!"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(7, start_pos)
      assert.are.equal(14, end_pos)
      assert.are.equal("31", ansi_code)
    end)

    it("should match short escape sequences", function()
      local line = "Hello \\e[32mgreen\\e[0m text"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(7, start_pos)
      assert.are.equal(12, end_pos)
      assert.are.equal("32", ansi_code)
    end)

    it("should match hex escape sequences (lowercase)", function()
      local line = "Test \\x1b[1;34mblue\\x1b[0m"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(6, start_pos)
      assert.are.equal(15, end_pos)
      assert.are.equal("1;34", ansi_code)
    end)

    it("should match hex escape sequences (uppercase)", function()
      local line = "Test \\x1B[1;35mmagenta\\x1B[0m"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(6, start_pos)
      assert.are.equal(15, end_pos)
      assert.are.equal("1;35", ansi_code)
    end)

    it("should match Unicode 4-digit escape sequences", function()
      local line = "Text \\u001b[36mcyan\\u001b[0m"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(6, start_pos)
      assert.are.equal(15, end_pos)
      assert.are.equal("36", ansi_code)
    end)

    it("should match Unicode 8-digit escape sequences", function()
      local line = "Text \\U0000001b[37mwhite\\U0000001b[0m"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(6, start_pos)
      assert.are.equal(19, end_pos)
      assert.are.equal("37", ansi_code)
    end)

    it("should match bash quoted formats", function()
      local test_cases = {
        "$'\\033[31m'",
        "$'\\e[32m'",
        "$'\\x1b[33m'",
        "$'\\x1B[34m'",
        "$'\\u001b[35m'",
        "$'\\U0000001b[36m'"
      }

      for i, pattern in ipairs(test_cases) do
        local line = "Test " .. pattern .. " text"
        local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

        assert.is_not_nil(start_pos, "Failed to match pattern: " .. pattern)
        assert.is_not_nil(ansi_code, "Failed to extract ANSI code from: " .. pattern)
      end
    end)

    it("should match literal ESC character sequences", function()
      local line = "Test \027[31mred\027[0m text"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(6, start_pos)
      assert.are.equal(10, end_pos)
      assert.are.equal("31", ansi_code)
    end)

    it("should match caret notation sequences", function()
      local line = "Test ^[[32mgreen^[[0m text"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(6, start_pos)
      assert.are.equal(11, end_pos)
      assert.are.equal("32", ansi_code)
    end)

    it("should handle multiple ANSI codes in one sequence", function()
      local line = "\\033[1;4;31mBold underlined red\\033[0m"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(1, start_pos)
      assert.are.equal(12, end_pos)
      assert.are.equal("1;4;31", ansi_code)
    end)

    it("should handle empty ANSI codes (reset)", function()
      local line = "Text \\033[m reset"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(6, start_pos)
      assert.are.equal(11, end_pos)
      assert.are.equal("", ansi_code)
    end)

    it("should return nil for lines without ANSI codes", function()
      local line = "Just regular text"
      local result = regex.find_ansi_sequence(line, 1)

      assert.is_nil(result)
    end)

    it("should find next ANSI sequence after given position", function()
      local line = "\\033[31mred\\033[0m and \\033[32mgreen\\033[0m"
      local _, end_pos1 = regex.find_ansi_sequence(line, 1)
      local start_pos2 = regex.find_ansi_sequence(line, end_pos1 + 1)

      assert.are.equal(12, start_pos2)
    end)
  end)

  describe("find_next_ansi_position", function()
    it("should find the position of the next ANSI sequence", function()
      local line = "text \\033[31mred\\033[0m more text \\e[32mgreen\\e[0m"
      local next_pos = regex.find_next_ansi_position(line, 20)

      assert.are.equal(35, next_pos)
    end)

    it("should return nil when no more ANSI sequences found", function()
      local line = "\\033[31mred\\033[0m plain text"
      local next_pos = regex.find_next_ansi_position(line, 20)

      assert.is_nil(next_pos)
    end)

    it("should find closest ANSI sequence among multiple patterns", function()
      local line = "text \\e[31m closer \\033[32m farther"
      local next_pos = regex.find_next_ansi_position(line, 1)

      assert.are.equal(6, next_pos)
    end)
  end)

  describe("edge cases", function()
    it("should handle malformed ANSI sequences gracefully", function()
      local line = "\\033[31 incomplete sequence"
      local result = regex.find_ansi_sequence(line, 1)

      assert.is_nil(result)
    end)

    it("should handle sequences at beginning of line", function()
      local line = "\\033[31mStart with color"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(1, start_pos)
      assert.are.equal(8, end_pos)
      assert.are.equal("31", ansi_code)
    end)

    it("should handle sequences at end of line", function()
      local line = "End with color\\033[0m"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(15, start_pos)
      assert.are.equal(21, end_pos)
      assert.are.equal("0", ansi_code)
    end)

    it("should handle consecutive ANSI sequences", function()
      local line = "\\033[1m\\033[31m\\033[4m"
      local start_pos1, end_pos1, code1 = regex.find_ansi_sequence(line, 1)
      local start_pos2, end_pos2, code2 = regex.find_ansi_sequence(line, end_pos1 + 1)
      local start_pos3, end_pos3, code3 = regex.find_ansi_sequence(line, end_pos2 + 1)

      assert.are.equal("1", code1)
      assert.are.equal("31", code2)
      assert.are.equal("4", code3)
      assert.are.equal(end_pos1 + 1, start_pos2)
      assert.are.equal(end_pos2 + 1, start_pos3)
    end)

    it("should handle very long ANSI codes", function()
      local long_code = "1;2;3;4;5;7;8;9;30;31;32;33;34;35;36;37;40;41;42;43;44;45;46;47"
      local line = "\\033[" .. long_code .. "m"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(1, start_pos)
      assert.are.equal(long_code, ansi_code)
    end)
  end)

  describe("grep format support", function()
    it("should match grep color output format", function()
      local line = "match: \027[31m\027[Kpattern\027[m\027[K text"
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

      assert.are.equal(8, start_pos)
      assert.are.equal(15, end_pos)
      assert.are.equal("31", ansi_code)
    end)
  end)

  describe("CSI format support", function()
    it("should match CSI escape sequences", function()
      local test_cases = {
        "\\x9b31m",
        "\\u009b32m",
        "\\23333m",
        "\15534m"
      }

      for _, pattern in ipairs(test_cases) do
        local line = "Test " .. pattern .. " text"
        local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, 1)

        assert.is_not_nil(start_pos, "Failed to match CSI pattern: " .. pattern)
      end
    end)
  end)
end)
