local config = require("ansillary.config")
local highlights = require("ansillary.highlights")
local regex = require("ansillary.regex")

local M = {}

-- Plugin state
M.enabled = true

-- Store extmarks for cursor-based concealment
M.ansi_extmarks = {}

-- Store signcolumn signs for lines with ANSI codes
M.ansi_signs = {}

-- Cached namespace IDs
local ns_id = vim.api.nvim_create_namespace("ansillary")
local hl_ns_id = vim.api.nvim_create_namespace("ansillary_highlights")

-- Sign definition and management
local function setup_sign_definition()
  -- Define the sign with the configured icon and color
  vim.fn.sign_define("AnsillaryAnsi", {
    text = config.signcolumn.icon,
    texthl = "AnsillarySign",
  })

  -- Create highlight group for the sign
  vim.api.nvim_set_hl(0, "AnsillarySign", { fg = config.signcolumn.color, })
end

local function place_sign(bufnr, line_number)
  if not config.signcolumn.enabled then
    return
  end

  -- Check if sign already exists for this line
  if M.ansi_signs[bufnr] and M.ansi_signs[bufnr][line_number] then
    return
  end

  -- Initialize buffer sign storage
  if not M.ansi_signs[bufnr] then
    M.ansi_signs[bufnr] = {}
  end

  -- Place the sign
  vim.fn.sign_place(0, "ansillary", "AnsillaryAnsi", bufnr, { lnum = line_number, })
  M.ansi_signs[bufnr][line_number] = true
end

local function clear_signs(bufnr)
  if M.ansi_signs[bufnr] then
    vim.fn.sign_unplace("ansillary", { buffer = bufnr, })
    M.ansi_signs[bufnr] = {}
  end
end

-- Helper function to validate filetype configuration
local function validate_filetype_config()
  local enabled = config.enabled_filetypes or {}
  local disabled = config.disabled_filetypes or {}

  -- Check for overlaps between enabled and disabled filetypes
  for _, enabled_ft in ipairs(enabled) do
    for _, disabled_ft in ipairs(disabled) do
      if enabled_ft == disabled_ft then
        error(string.format(
          "ansillary.nvim: Filetype '%s' found in both enabled_filetypes and disabled_filetypes",
          enabled_ft
        ))
      end
    end
  end
end

-- Helper function to check if a filetype should be processed
local function should_process_filetype(filetype)
  local enabled = config.enabled_filetypes or {}
  local disabled = config.disabled_filetypes or {}

  -- Also consider the current buffer's file extension
  local bufname = vim.api.nvim_buf_get_name(0)
  local ext = ""
  if bufname ~= "" then
    ext = vim.fn.fnamemodify(bufname, ":e")
  end

  local function matches(entry)
    return entry == "*"
        or entry == filetype
        or (ext ~= "" and entry == ext)
  end

  -- Disabled wins over enabled
  for _, d in ipairs(disabled) do
    if matches(d) then
      return false
    end
  end
  for _, e in ipairs(enabled) do
    if matches(e) then
      return true
    end
  end
  return false
end

local function parse_ansi_code(code)
  if not code then
    return {}
  end

  -- Handle empty code as reset (ESC[m is equivalent to ESC[0m)
  if code == "" then
    return {reset = true}
  end

  local attributes = {}
  local parts = vim.split(code, ";")

  for _, part in ipairs(parts) do
    local num = tonumber(part)
    if num then
      if num == 0 then
        attributes.reset = true
      elseif num == 1 then
        attributes.bold = true
      elseif num == 2 then
        attributes.dim = true
      elseif num == 3 then
        attributes.italic = true
      elseif num == 4 then
        attributes.underline = true
      elseif num == 5 then
        attributes.blink = true
      elseif num == 7 then
        attributes.reverse = true
      elseif num == 9 then
        attributes.strikethrough = true
      elseif num >= 30 and num <= 37 then
        attributes.fg = num - 30
      elseif num >= 40 and num <= 47 then
        attributes.bg = num - 40
      elseif num >= 90 and num <= 97 then
        attributes.fg = num - 90 + 8
      elseif num >= 100 and num <= 107 then
        attributes.bg = num - 100 + 8
      elseif num == 38 then
        attributes.fg_extended = true
      elseif num == 48 then
        attributes.bg_extended = true
      end
    end
  end

  return attributes
end


local function create_highlight_group(name, attrs)
  local hl_attrs = {}

  if attrs.fg ~= nil then
    hl_attrs.fg = highlights.get_color(attrs.fg)
    hl_attrs.ctermfg = attrs.fg
  end

  if attrs.bg ~= nil then
    hl_attrs.bg = highlights.get_color(attrs.bg)
    hl_attrs.ctermbg = attrs.bg
  end

  if attrs.bold then
    hl_attrs.bold = true
  end
  if attrs.italic then
    hl_attrs.italic = true
  end
  if attrs.underline then
    hl_attrs.underline = true
  end
  if attrs.reverse then
    hl_attrs.reverse = true
  end
  if attrs.strikethrough then
    hl_attrs.strikethrough = true
  end

  -- Handle unsupported attributes with warnings
  if attrs.dim and config.warn_on_unsupported then
    vim.notify(
      "ansillary.nvim: Dim attribute (ANSI code 2) is not supported by Neovim and will be ignored. "
      .. "Set warn_on_unsupported=false to silence this warning.",
      vim.log.levels.WARN
    )
  end
  if attrs.blink and config.warn_on_unsupported then
    vim.notify(
      "ansillary.nvim: Blink attribute (ANSI code 5) is not supported by Neovim and will be ignored. "
      .. "Set warn_on_unsupported=false to silence this warning.",
      vim.log.levels.WARN
    )
  end

  vim.api.nvim_set_hl(0, name, hl_attrs)
end

local function get_highlight_name(attrs)
  local parts = {}

  if attrs.fg ~= nil then
    table.insert(parts, "fg" .. attrs.fg)
  end
  if attrs.bg ~= nil then
    table.insert(parts, "bg" .. attrs.bg)
  end
  if attrs.bold then
    table.insert(parts, "bold")
  end
  -- NOTE: dim/blink attributes not supported by Neovim, skip them
  if attrs.italic then
    table.insert(parts, "italic")
  end
  if attrs.underline then
    table.insert(parts, "underline")
  end
  if attrs.reverse then
    table.insert(parts, "reverse")
  end
  if attrs.strikethrough then
    table.insert(parts, "strikethrough")
  end

  if #parts == 0 then
    return nil
  end

  return "Ansillary" .. table.concat(parts, "_")
end



local function highlight_buffer()
  if not M.enabled then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  vim.api.nvim_buf_clear_namespace(bufnr, hl_ns_id, 0, -1)

  -- Clear existing signs and initialize storage
  clear_signs(bufnr)

  -- Initialize extmarks storage for this buffer
  M.ansi_extmarks[bufnr] = {}

  for line_idx, line in ipairs(lines) do
    local col = 0
    local line_len = #line

    while col < line_len do
      local start_pos, end_pos, ansi_code = regex.find_ansi_sequence(line, col + 1)

      if not start_pos then
        break
      end

      -- Skip if we couldn't extract an ANSI code
      if not ansi_code then
        col = end_pos
        goto continue
      end

      local attrs = parse_ansi_code(ansi_code)

      -- Place signcolumn indicator for lines with ANSI codes
      place_sign(bufnr, line_idx)

      -- Handle text content highlighting (only for non-reset sequences)
      if not attrs.reset and config.text_highlights.enabled then
        local text_start = end_pos + 1
        local next_ansi = regex.find_next_ansi_position(line, text_start)
        local text_end = next_ansi and next_ansi - 1 or line_len

        if text_start <= text_end then
          -- Check if we should use auto inheritance (inherit ANSI codes)
          local use_auto_inheritance = (
            config.text_highlights.format.fg.color == "auto" and
            config.text_highlights.format.fg.style == "auto" and
            config.text_highlights.format.bg.color == "auto"
          )

          local text_hl_name
          if use_auto_inheritance then
            -- Auto mode: inherit ANSI codes and apply appropriate styling
            text_hl_name = get_highlight_name(attrs)
            if text_hl_name then
              create_highlight_group(text_hl_name, attrs)
            end
          else
            -- Custom mode: apply user-defined styling, ignoring ANSI codes
            local custom_attrs = highlights.create_text_highlight(attrs, config.text_highlights.format)
            text_hl_name = "AnsillaryText_Custom"
            vim.api.nvim_set_hl(0, text_hl_name, custom_attrs)
          end

          if text_hl_name then
            -- Use a separate namespace for highlights to avoid interfering with concealment extmarks
            vim.api.nvim_buf_add_highlight(bufnr, hl_ns_id, text_hl_name, line_idx - 1, text_start - 1, text_end)
          end
        end
      end

      -- Handle ANSI sequence highlighting (can apply to all sequences including reset)
      if config.ansi_highlights.enabled then
        -- Check if we should use auto inheritance (reuse existing highlight group)
        local use_auto_inheritance = (
          config.ansi_highlights.format.fg.color == "auto" and
          config.ansi_highlights.format.fg.style == "auto" and
          config.ansi_highlights.format.bg.color == "auto"
        )

        local ansi_hl_name
        if use_auto_inheritance then
          if not attrs.reset then
            -- For non-reset sequences with auto inheritance, reuse the text highlight group
            local hl_name = get_highlight_name(attrs)
            if hl_name then
              ansi_hl_name = hl_name
            end
          end
          -- For reset sequences with auto inheritance, don't highlight (ansi_hl_name stays nil)
        else
          -- Custom highlighting - apply to all sequences including reset
          local text_attrs = {
            fg = nil,
            bg = nil,
            bold = attrs.bold,
            italic = attrs.italic,
            underline = attrs.underline,
            reverse = attrs.reverse,
            strikethrough = attrs.strikethrough,
          }

          -- Add color information (for non-reset sequences)
          if not attrs.reset then
            if attrs.fg ~= nil then
              text_attrs.fg = highlights.get_color(attrs.fg)
            end
            if attrs.bg ~= nil then
              text_attrs.bg = highlights.get_color(attrs.bg)
            end
          end

          -- Create dynamic ANSI highlight
          local ansi_attrs = highlights.create_ansi_highlight(text_attrs, config.ansi_highlights.format)

          -- Create a unique highlight group name for this combination
          local hl_name = get_highlight_name(attrs)
          ansi_hl_name = "AnsillaryANSI_" .. (hl_name or "reset")
          vim.api.nvim_set_hl(0, ansi_hl_name, ansi_attrs)
        end

        -- Apply the highlight to the ANSI sequence if we have a highlight name
        if ansi_hl_name then
          vim.api.nvim_buf_add_highlight(bufnr, hl_ns_id, ansi_hl_name, line_idx - 1, start_pos - 1, end_pos)
        end
      end

      if config.conceal then
        local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
        if cursor_line == 0 then cursor_line = 1 end  -- Handle startup case
        local mark_line = line_idx

        local should_conceal = true
        if config.reveal_on_cursorline and mark_line == cursor_line then
          should_conceal = false
        end

        local extmark_opts = {
          end_col = math.min(end_pos, line_len),
        }

        if should_conceal then
          extmark_opts.conceal = ""
        end

        local mark_id = vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_idx - 1, start_pos - 1, extmark_opts)

        -- Store extmark info for cursor-aware concealment
        table.insert(M.ansi_extmarks[bufnr], {
          id = mark_id,
          line = line_idx - 1,
          start_col = start_pos - 1,
          end_col = math.min(end_pos, line_len),
        })
      end

      col = end_pos
      ::continue::
    end
  end
end

local function setup_autocmds()
  local group = vim.api.nvim_create_augroup("Ansillary", { clear = true })

  vim.api.nvim_create_autocmd({
    "BufRead", "BufNewFile", "BufEnter", "BufWinEnter",
    "StdinReadPost", "TextChanged", "TextChangedI"
  }, {
    group = group,
    pattern = "*",  -- Listen to all files, then filter in callback
    callback = function()
      local filetype = vim.bo.filetype
      if not should_process_filetype(filetype) then
        return
      end

      if config.conceal then
        vim.wo.conceallevel = 2
        vim.wo.concealcursor = config.reveal_on_cursorline and "" or "nvic"
      end
      vim.schedule(highlight_buffer)
    end,
  })

  -- Add VimEnter to handle cases where plugin loads after content is in buffer
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
      local filetype = vim.bo.filetype
      if should_process_filetype(filetype) then
        if config.conceal then
          vim.wo.conceallevel = 2
          vim.wo.concealcursor = config.reveal_on_cursorline and "" or "nvic"
        end
        vim.schedule(highlight_buffer)
      end
    end,
  })

  -- Add cursor movement handler for reveal_on_cursorline
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    pattern = "*",
    callback = function()
      if not M.enabled or not config.conceal or not config.reveal_on_cursorline then
        return
      end
      local filetype = vim.bo.filetype
      if not should_process_filetype(filetype) then
        return
      end
      vim.schedule(highlight_buffer)
    end,
  })

  -- Clean up extmarks when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      M.ansi_extmarks[bufnr] = nil
    end,
  })
end

function M.setup(opts)
  opts = opts or {}

  -- Deep extend with user configuration
  config = vim.tbl_deep_extend("force", config, opts)

  -- Validate filetype configuration
  validate_filetype_config()

  -- Create base highlight groups including concealment
  highlights.create_base_highlights()

  -- Setup signcolumn signs
  setup_sign_definition()

  setup_autocmds()
end

-- Toggle entire plugin on/off
function M.toggle()
  M.enabled = not M.enabled

  if M.enabled then
    -- Re-enable: highlight all buffers
    highlight_buffer()
  else
    -- Disable: clear all highlights and extmarks from all buffers
    for bufnr, _ in pairs(M.ansi_extmarks) do
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
        vim.api.nvim_buf_clear_namespace(bufnr, hl_ns_id, 0, -1)
        clear_signs(bufnr)
      end
    end
    -- Clear storage
    M.ansi_extmarks = {}
    M.ansi_signs = {}
  end
end

-- Toggle concealment only (keep highlighting)
function M.toggle_conceal()
  config.conceal = not config.conceal

  -- Update vim concealment settings
  if config.conceal then
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = config.reveal_on_cursorline and "" or "nvic"
  else
    vim.wo.conceallevel = 0  -- Disable concealment
  end

  if M.enabled then
    -- Re-run highlighting to apply/remove concealment
    highlight_buffer()
  end
end

-- Toggle reveal on cursorline option
function M.toggle_reveal()
  config.reveal_on_cursorline = not config.reveal_on_cursorline

  -- Update vim concealment settings
  if config.conceal then
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = config.reveal_on_cursorline and "" or "nvic"
  end

  -- Rebuild extmarks with new concealment logic
  if M.enabled and config.conceal then
    highlight_buffer()
  end
end

-- Toggle text highlighting
function M.toggle_text_highlights()
  config.text_highlights.enabled = not config.text_highlights.enabled

  if M.enabled then
    -- Re-run highlighting to apply/remove text highlighting
    highlight_buffer()
  end
end

-- Toggle ANSI highlighting
function M.toggle_ansi_highlights()
  config.ansi_highlights.enabled = not config.ansi_highlights.enabled

  if M.enabled then
    -- Re-run highlighting to apply/remove ANSI sequence highlighting
    highlight_buffer()
  end
end

-- Debug function to expose internal state
function M.get_state()
  return {
    enabled = M.enabled,
    config = config,
    ansi_extmarks = M.ansi_extmarks,
  }
end

-- Test helper function to manually trigger highlighting
function M._trigger_highlighting_for_tests()
  if M.enabled then
    highlight_buffer()
  end
end


return M
