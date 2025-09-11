local M = {}

local basic_colors = {
  [0] = "#000000",  -- Black
  [1] = "#cd0000",  -- Red
  [2] = "#00cd00",  -- Green
  [3] = "#cdcd00",  -- Yellow
  [4] = "#0000ee",  -- Blue
  [5] = "#cd00cd",  -- Magenta
  [6] = "#00cdcd",  -- Cyan
  [7] = "#e5e5e5",  -- White
}

local bright_colors = {
  [8] = "#7f7f7f",   -- Bright Black (Gray)
  [9] = "#ff0000",   -- Bright Red
  [10] = "#00ff00",  -- Bright Green
  [11] = "#ffff00",  -- Bright Yellow
  [12] = "#5c5cff",  -- Bright Blue
  [13] = "#ff00ff",  -- Bright Magenta
  [14] = "#00ffff",  -- Bright Cyan
  [15] = "#ffffff",  -- Bright White
}

function M.get_color(color_index)
  if color_index <= 7 then
    return basic_colors[color_index]
  elseif color_index <= 15 then
    return bright_colors[color_index]
  else
    return "#ffffff"
  end
end

function M.create_base_highlights()
  -- Create concealment highlight that hides text by making it transparent
  vim.api.nvim_set_hl(0, "AnsillaryConceal", {
    fg = "NONE",
    bg = "NONE",
    blend = 100
  })

  for i = 0, 15 do
    local color = M.get_color(i)
    vim.api.nvim_set_hl(0, "AnsillaryFg" .. i, { fg = color })
    vim.api.nvim_set_hl(0, "AnsillaryBg" .. i, { bg = color })
  end

  local style_combinations = {
    { name = "Bold", attrs = { bold = true } },
    { name = "Dim", attrs = { italic = true } },
    { name = "Italic", attrs = { italic = true } },
    { name = "Underline", attrs = { underline = true } },
    { name = "Reverse", attrs = { reverse = true } },
    { name = "Strikethrough", attrs = { strikethrough = true } },
  }

  for _, style in ipairs(style_combinations) do
    vim.api.nvim_set_hl(0, "Ansillary" .. style.name, style.attrs)
  end

end

-- Parse style string into individual styles
local function parse_styles(style_str)
  if style_str == "auto" then
    return nil -- Handled by caller
  end

  local styles = {}
  if style_str and style_str ~= "" then
    for style in style_str:gmatch("[^,]+") do
      style = style:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
      if style == "bold" then styles.bold = true
      elseif style == "italic" then styles.italic = true
      elseif style == "underline" then styles.underline = true
      elseif style == "reverse" then styles.reverse = true
      elseif style == "strikethrough" then styles.strikethrough = true
      end
    end
  end
  return styles
end

function M.create_ansi_highlight(text_attrs, ansi_config)
  local attrs = {}

  -- Handle foreground
  if ansi_config.fg.color == "auto" then
    attrs.fg = text_attrs.fg
  else
    attrs.fg = ansi_config.fg.color
  end

  -- Handle background
  if ansi_config.bg.color == "auto" then
    attrs.bg = text_attrs.bg
  else
    attrs.bg = ansi_config.bg.color
  end

  -- Handle foreground styles (not applicable for background)
  if ansi_config.fg.style == "auto" then
    -- Copy text styling attributes
    if text_attrs.bold then attrs.bold = true end
    if text_attrs.italic then attrs.italic = true end
    if text_attrs.underline then attrs.underline = true end
    if text_attrs.reverse then attrs.reverse = true end
    if text_attrs.strikethrough then attrs.strikethrough = true end
  else
    local fg_styles = parse_styles(ansi_config.fg.style)
    if fg_styles then
      for k, v in pairs(fg_styles) do
        attrs[k] = v
      end
    end
  end

  return attrs
end

-- Create text highlight attributes based on configuration
-- Similar to create_ansi_highlight but for text content
function M.create_text_highlight(parsed_attrs, text_config)
  local attrs = {}

  -- Handle foreground color
  if text_config.fg.color == "auto" then
    -- Auto mode: use color from ANSI attributes if present
    if parsed_attrs.fg ~= nil then
      attrs.fg = M.get_color(parsed_attrs.fg)
      attrs.ctermfg = parsed_attrs.fg
    end
  else
    -- Custom color specified
    attrs.fg = text_config.fg.color
  end

  -- Handle background color
  if text_config.bg.color == "auto" then
    -- Auto mode: use background from ANSI attributes if present
    if parsed_attrs.bg ~= nil then
      attrs.bg = M.get_color(parsed_attrs.bg)
      attrs.ctermbg = parsed_attrs.bg
    end
  else
    -- Custom background specified
    attrs.bg = text_config.bg.color
  end

  -- Handle foreground styles
  if text_config.fg.style == "auto" then
    -- Auto mode: use styling from ANSI attributes
    if parsed_attrs.bold then attrs.bold = true end
    if parsed_attrs.italic then attrs.italic = true end
    if parsed_attrs.underline then attrs.underline = true end
    if parsed_attrs.reverse then attrs.reverse = true end
    if parsed_attrs.strikethrough then attrs.strikethrough = true end
  else
    -- Custom styles specified
    local fg_styles = parse_styles(text_config.fg.style)
    if fg_styles then
      for k, v in pairs(fg_styles) do
        attrs[k] = v
      end
    end
  end

  return attrs
end

return M
