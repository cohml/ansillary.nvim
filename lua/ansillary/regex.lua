-- ANSI escape sequence pattern definitions and extraction functions
-- This module contains all the regex patterns used to match various ANSI escape sequence formats

local M = {}

-- NOTE: Order matters - more specific patterns should come first
M.ansi_patterns = {
  -- Grep format must come first for priority
  {
    pattern = "(\027%[[0-9;]*m\027%[K)",
    extract = function(match)
      return string.match(match, "\027%[([0-9;]*)m\027%[K")
    end
  },

  -- Bash $'...' quoted formats
  {
    pattern = "(%$'\\033%[[0-9;]*m')",
    extract = function(match)
      return string.match(match, "%$'\\033%[([0-9;]*)m'")
    end
  },
  {
    pattern = "(%$'\\e%[[0-9;]*m')",
    extract = function(match)
      return string.match(match, "%$'\\e%[([0-9;]*)m'")
    end
  },
  {
    pattern = "(%$'\\x1[bB]%[[0-9;]*m')",
    extract = function(match)
      return string.match(match, "%$'\\x1[bB]%[([0-9;]*)m'")
    end
  },
  {
    pattern = "(%$'\\u001[bB]%[[0-9;]*m')",
    extract = function(match)
      return string.match(match, "%$'\\u001[bB]%[([0-9;]*)m'")
    end
  },
  {
    pattern = "(%$'\\U0000001[bB]%[[0-9;]*m')",
    extract = function(match)
      return string.match(match, "%$'\\U0000001[bB]%[([0-9;]*)m'")
    end
  },
  {
    pattern = "(%$'\\x9[bB][0-9;]*m')",
    extract = function(match)
      return string.match(match, "%$'\\x9[bB]([0-9;]*)m'")
    end
  },
  {
    pattern = "(%$'\\u009[bB][0-9;]*m')",
    extract = function(match)
      return string.match(match, "%$'\\u009[bB]([0-9;]*)m'")
    end
  },

  -- CSI (Control Sequence Introducer) formats
  {
    pattern = "(\\x9[bB][0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\x9[bB]([0-9;]*)m")
    end
  },
  {
    pattern = "(\\u009[bB][0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\u009[bB]([0-9;]*)m")
    end
  },
  {
    pattern = "(\\233[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\233([0-9;]*)m")
    end
  },
  {
    pattern = "(\155[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\155([0-9;]*)m")
    end
  },

  -- Standard ESC formats
  {
    pattern = "(\\033%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\033%[([0-9;]*)m")
    end
  },
  {
    pattern = "(\\27%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\27%[([0-9;]*)m")
    end
  },
  {
    pattern = "(\\e%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\e%[([0-9;]*)m")
    end
  },
  {
    pattern = "(\\x1[bB]%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\x1[bB]%[([0-9;]*)m")
    end
  },
  {
    pattern = "(\\x{1b}%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\x{1b}%[([0-9;]*)m")
    end
  },
  {
    pattern = "(\\u001[bB]%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\u001[bB]%[([0-9;]*)m")
    end
  },
  {
    pattern = "(\\u{1b}%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\u{1b}%[([0-9;]*)m")
    end
  },
  {
    pattern = "(\\U0000001[bB]%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\U0000001[bB]%[([0-9;]*)m")
    end
  },

  -- Literal representations
  {
    pattern = "(%^%[%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "%^%[%[([0-9;]*)m")
    end
  },
  {
    pattern = "(%^%[ %[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "%^%[ %[([0-9;]*)m")
    end
  },
  {
    pattern = "(\\<Esc>%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\<Esc>%[([0-9;]*)m")
    end
  },
  {
    pattern = "(`e%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "`e%[([0-9;]*)m")
    end
  },
  {
    pattern = "(␛%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "␛%[([0-9;]*)m")
    end
  },
  {
    pattern = "(\\N{ESC}%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\N{ESC}%[([0-9;]*)m")
    end
  },
  {
    pattern = "(\\c%[%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\\c%[%[([0-9;]*)m")
    end
  },

  -- Actual ESC character
  {
    pattern = "(\027%[[0-9;]*m)",
    extract = function(match)
      return string.match(match, "\027%[([0-9;]*)m")
    end,
  },
}

-- Convert patterns for simple finding (without captures)
-- Used for finding next ANSI sequence positions
M.simple_patterns = {}
for _, entry in ipairs(M.ansi_patterns) do
  table.insert(M.simple_patterns, (entry.pattern:gsub("^%((.*)%)$", "%1")))
end

-- Find the first ANSI sequence in a line starting from a given column
function M.find_ansi_sequence(line, start_col)
  for i, entry in ipairs(M.ansi_patterns) do
    local start_pos, end_pos, match = string.find(line, entry.pattern, start_col)
    if start_pos then
      local ansi_code = entry.extract(match)
      return start_pos, end_pos, ansi_code
    end
  end
  return nil
end

-- Find the position of the next ANSI sequence in a line
function M.find_next_ansi_position(line, start_pos)
  local next_ansi = nil
  for _, pattern in ipairs(M.simple_patterns) do
    local pos = string.find(line, pattern, start_pos)
    if pos and (not next_ansi or pos < next_ansi) then
      next_ansi = pos
    end
  end
  return next_ansi
end

return M
