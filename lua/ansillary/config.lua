---@class AnsiForegroundStyle
---@field color '"auto"'|string  -- "auto" or any color string
---@field style '"auto"'|string  -- "auto" or style string (bold,italic,underline,reverse,strikethrough)

---@class AnsiBackgroundStyle
---@field color '"auto"'|string  -- "auto" or any color string

---@class AnsiFormat
---@field fg AnsiForegroundStyle
---@field bg AnsiBackgroundStyle

---@class AnsiHighlights
---@field enabled boolean    -- Enable ANSI escape sequence highlighting
---@field format AnsiFormat  -- Formatting options for ANSI sequences

---@class SignColumnFormat
---@field color string  -- Color for signcolumn icon
---@field style string  -- Style for signcolumn icon (bold,italic,underline,reverse,strikethrough)

---@class SignColumn
---@field enabled boolean         -- Enable signcolumn indicators for lines with ANSI codes
---@field icon string             -- Icon to display in signcolumn
---@field format SignColumnFormat -- Formatting options for signcolumn icon

---@class Config
---@field conceal boolean                 -- Hide ANSI escape sequences
---@field reveal_on_cursorline boolean    -- Reveal ANSI codes when cursor is on the line
---@field warn_on_unsupported boolean     -- Show warning when unsupported attributes are encountered
---@field text_highlights AnsiHighlights  -- Text content highlighting configuration
---@field ansi_highlights AnsiHighlights  -- ANSI escape sequence highlighting configuration
---@field signcolumn SignColumn           -- Signcolumn indicator configuration
---@field enabled_filetypes string[]      -- Filetypes to apply highlighting to
---@field disabled_filetypes string[]     -- Filetypes to exclude from highlighting

---@type Config
return {
  conceal = true,               -- Hide ANSI escape sequences
  reveal_on_cursorline = true,  -- Reveal ANSI codes when cursor is on the line
  warn_on_unsupported = true,   -- Show warning when unsupported attributes are encountered
  text_highlights = {           -- Text content highlighting configuration
    enabled = true,             -- Enable highlighting of text content based on ANSI codes
    format = {                  -- Formatting options for text content
      fg = {
        color = "auto",         -- Color for text (auto = inherit from ANSI codes)
        style = "auto",         -- Style for text (auto = inherit from ANSI codes, or comma-delimited styles)
                                   -- Valid styles: bold, italic, underline, reverse, strikethrough
                                   -- Examples: "bold", "italic,underline", "bold,reverse"
      },
      bg = {
        color = "auto",         -- Background color for text (auto = inherit from ANSI codes)
      },
    },
  },
  ansi_highlights = {           -- ANSI escape sequence highlighting configuration
    enabled = false,            -- Enable highlighting of ANSI escape sequences themselves
    format = {                  -- Formatting options for ANSI sequences
      fg = {
        color = "auto",         -- Color for ANSI sequences (auto = inherit from ANSI codes)
        style = "auto",         -- Style for ANSI sequences (auto = inherit from ANSI codes, or comma-delimited styles)
                                   -- Valid styles: bold, italic, underline, reverse, strikethrough
                                   -- Examples: "bold", "italic,underline", "bold,reverse"
      },
      bg = {
        color = "auto",         -- Background color for ANSI sequences (auto = inherit from ANSI codes)
      },
    },
  },
  signcolumn = {                -- Signcolumn indicator configuration
    enabled = false,            -- Enable signcolumn indicators for lines with ANSI codes
    icon = "𝒜",                 -- Icon to display in signcolumn
    format = {                  -- Formatting options for signcolumn icon
      color = "#6d8086",        -- Color for signcolumn icon (subtle gray-blue)
      style = "",               -- Style for signcolumn icon ("" = none, or comma-delimited styles)
    },
  },
  enabled_filetypes = { "*" },  -- Filetypes to apply highlighting to
  disabled_filetypes = {},      -- Filetypes to exclude from highlighting
}
