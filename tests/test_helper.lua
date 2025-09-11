-- Test helper functions and setup for ansillary.nvim tests
local M = {}

-- Mock vim API for testing
local mock_vim = {
  api = {
    nvim_create_namespace = function(name)
      return math.random(1, 1000)
    end,
    nvim_set_hl = function(ns, name, attrs)
      -- Mock highlight setting
    end,
    nvim_buf_add_highlight = function(bufnr, ns_id, hl_group, line, col_start, col_end)
      -- Mock buffer highlight
    end,
    nvim_buf_clear_namespace = function(bufnr, ns_id, line_start, line_end)
      -- Mock clear namespace
    end,
    nvim_buf_set_extmark = function(bufnr, ns_id, line, col, opts)
      return math.random(1, 1000)
    end,
    nvim_get_current_buf = function()
      return 1
    end,
    nvim_buf_get_lines = function(bufnr, start, end_line, strict_indexing)
      return {"test line"}
    end,
    nvim_win_get_cursor = function(winid)
      return {1, 0}
    end,
    nvim_create_augroup = function(name, opts)
      return name
    end,
    nvim_create_autocmd = function(events, opts)
      -- Mock autocmd
    end,
    nvim_buf_is_valid = function(bufnr)
      return true
    end,
    nvim_create_user_command = function(name, cmd, opts)
      -- Mock user command
    end,
  },
  bo = {
    filetype = "lua"
  },
  wo = {},
  g = {},
  log = {
    levels = {
      WARN = 1,
      ERROR = 2,
      INFO = 3,
    },
  },
  notify = function(message, level)
    -- Mock notification
  end,
  tbl_deep_extend = function(behavior, ...)
    local result = {}
    for i = 1, select('#', ...) do
      local tbl = select(i, ...)
      if type(tbl) == 'table' then
        for k, v in pairs(tbl) do
          if type(v) == 'table' and type(result[k]) == 'table' then
            result[k] = M.deep_extend('force', result[k], v)
          else
            result[k] = v
          end
        end
      end
    end
    return result
  end,
  split = function(str, sep)
    local result = {}
    for match in (str .. sep):gmatch("(.-)" .. sep) do
      table.insert(result, match)
    end
    return result
  end,
  schedule = function(callback)
    callback()
  end,
  fn = {
    fnamemodify = function(fname, mods)
      if mods == ":e" then
        return fname:match("%.([^%.]+)$") or ""
      end
      return fname
    end,
  },
}

-- Helper function to deep extend tables (for mocking vim.tbl_deep_extend)
function M.deep_extend(behavior, ...)
  local result = {}
  for i = 1, select('#', ...) do
    local tbl = select(i, ...)
    if type(tbl) == 'table' then
      for k, v in pairs(tbl) do
        if type(v) == 'table' and type(result[k]) == 'table' then
          result[k] = M.deep_extend('force', result[k], v)
        else
          result[k] = v
        end
      end
    end
  end
  return result
end

-- Mock vim API globally for tests
function M.setup_vim_mock()
  _G.vim = mock_vim
  _G.vim.tbl_deep_extend = M.deep_extend
end

-- Create test buffer content with ANSI codes
function M.create_test_buffer(lines)
  mock_vim.api.nvim_buf_get_lines = function(bufnr, start, end_line, strict_indexing)
    return lines or {"test line"}
  end
end

-- Reset vim mock to default state
function M.reset_vim_mock()
  M.setup_vim_mock()
end

-- Assert that two tables are equal (deep comparison)
function M.assert_table_equal(expected, actual, path)
  path = path or "root"

  if type(expected) ~= type(actual) then
    error("Type mismatch at " .. path .. ": expected " .. type(expected) .. ", got " .. type(actual))
  end

  if type(expected) == "table" then
    for k, v in pairs(expected) do
      if actual[k] == nil then
        error("Missing key at " .. path .. "." .. tostring(k))
      end
      M.assert_table_equal(v, actual[k], path .. "." .. tostring(k))
    end

    for k, v in pairs(actual) do
      if expected[k] == nil then
        error("Unexpected key at " .. path .. "." .. tostring(k))
      end
    end
  else
    if expected ~= actual then
      error("Value mismatch at " .. path .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
    end
  end
end

return M
