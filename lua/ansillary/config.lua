---@class AnsiForegroundStyle
---@field color '"auto"'|string   -- "auto" or any color string
---@field style '"auto"'|string   -- "auto" or style string (bold,italic,underline,reverse,strikethrough)

---@class AnsiBackgroundStyle
---@field color '"auto"'|string   -- "auto" or any color string

---@class AnsiFormat
---@field fg AnsiForegroundStyle
---@field bg AnsiBackgroundStyle

---@class AnsiHighlights
---@field enabled boolean      -- Enable ANSI escape sequence highlighting
---@field format AnsiFormat

---@class Config
---@field conceal boolean
---@field reveal_under_cursor boolean
---@field warn_on_unsupported boolean
---@field ansi_highlights AnsiHighlights
---@field enabled_filetypes string[]   -- array of strings
---@field disabled_filetypes string[]  -- array of strings

---@type Config
return {
  conceal = true,              -- Hide ANSI escape sequences
  reveal_under_cursor = true,  -- Reveal ANSI codes when cursor is on the line
  warn_on_unsupported = true,  -- Show warning when unsupported attributes are encountered
  ansi_highlights = {          -- ANSI escape sequence highlighting configuration
    enabled = false,           -- Enable highlighting of ANSI escape sequences themselves
    format = {                 -- Formatting options for ANSI sequences
      fg = {
        color = "auto",        -- Color for ANSI sequences (auto = inherit from styled text)
        style = "auto",        -- Style for ANSI sequences: "auto" (inherit) or comma-delimited styles
                              -- Valid styles: bold, italic, underline, reverse, strikethrough
                              -- Examples: "bold", "italic,underline", "bold,reverse"
      },
      bg = {
        color = "auto",        -- Background color for ANSI sequences (auto = inherit from styled text)
      },
    },
  },
  enabled_filetypes = { "*" }, -- Filetypes to apply highlighting to
  disabled_filetypes = {},     -- Filetypes to exclude from highlighting
}
