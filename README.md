# ansillary.nvim

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A simple Neovim plugin that highlights text surrounded by ANSI color codes with the colors and
styles, while hiding literal escape sequences from view with intelligent cursor-aware concealment.

## ✨ Features

- 🎨 **Universal ANSI Support** - Recognizes many different ANSI escape sequence formats
- 🎭 **Comprehensive Style Support** - Bold, italic, underline, reverse, strikethrough
- 👁️ **Cursor-Aware Concealment** - ANSI codes hidden except on cursorline
- ⚡ **Real-Time Updates** - Highlights update as you type and move cursor
- 🔧 **Flexible Control** - Separate toggles for highlighting and concealment
- 🌈 **True Color Support** - Works with modern 24-bit color terminals
- 🎯 **Smart Detection** - Handles mixed ANSI formats in the same file and line

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

<details>
<summary>Code</summary>

```lua
{
  "cohml/ansillary.nvim",
  config = function()
    require("ansillary").setup()
  end,
}
```

</details>

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

<details>
<summary>Code</summary>

```lua
use {
  "cohml/ansillary.nvim",
  config = function()
    require("ansillary").setup()
  end,
}
```

</details>

### [vim-plug](https://github.com/junegunn/vim-plug)

<details>
<summary>Code</summary>

```vim
Plug 'cohml/ansillary.nvim'
```

</details>

Then add to your `init.lua`.

<details>
<summary>Code</summary>

```lua
require("ansillary").setup()
```

</details>

## ⚙️ Configuration

### Default Settings

<details>
<summary>Code</summary>

```lua
require("ansillary").setup({
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
        style = "auto",         -- Background style for ANSI sequences (auto = inherit from ANSI codes, or comma-delimited styles)
                                   -- Valid styles: bold, italic, underline, reverse, strikethrough
                                   -- Examples: "bold", "italic,underline", "bold,reverse"
      },
    },
  },
  signcolumn = {                -- Signcolumn indicator configuration
    enabled = false,            -- Enable signcolumn indicators for lines with ANSI codes
    icon = "𝒜",                 -- Icon to display in signcolumn
    format = {                  -- Formatting options for signcolumn icon
      color = "#6d8086",        -- Color for signcolumn icon (subtle gray-blue)
      style = "",               -- Style for signcolumn icon ("" = none, or comma-delimited styles)
                                   -- Valid styles: bold, italic, underline, reverse, strikethrough
                                   -- Examples: "bold", "italic,underline", "bold,reverse"
    },
  },
  enabled_filetypes = { "*" },  -- Filetypes to apply highlighting to
  disabled_filetypes = {},      -- Filetypes to exclude from highlighting
})
```

</details>

### Configuration Options

<details>
<summary>Table</summary>


| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `conceal` | `boolean` | `true` | Enable concealment of ANSI codes |
| `reveal_on_cursorline` | `boolean` | `true` | Reveal ANSI codes when cursor is on the line (no effect when `conceal = false`) |
| `warn_on_unsupported` | `boolean` | `true` | Show warning when unsupported attributes (dim, blink) are encountered |
| `text_highlights.enabled` | `boolean` | `true` | Enable highlighting of text content based on ANSI codes |
| `text_highlights.format.fg.color` | `string` | `"auto"` | Foreground color for text content - use `"auto"` to inherit from ANSI codes, or specify custom colors (hex codes/highlight groups) |
| `text_highlights.format.fg.style` | `string` | `"auto"` | Foreground style for text content - use `"auto"` to inherit from ANSI codes, or specify custom styles (`"bold,italic"` etc.) |
| `text_highlights.format.bg.color` | `string` | `"auto"` | Background color for text content - use `"auto"` to inherit from ANSI codes, or specify custom colors (hex codes/highlight groups) |
| `ansi_highlights.enabled` | `boolean` | `false` | Enable highlighting of ANSI escape sequences themselves |
| `ansi_highlights.format.fg.color` | `string` | `"auto"` | Foreground color for ANSI sequences - use `"auto"` to inherit from ANSI codes, or specify custom colors (hex codes/highlight groups) |
| `ansi_highlights.format.fg.style` | `string` | `"auto"` | Foreground style for ANSI sequences - use `"auto"` to inherit from ANSI codes, or specify custom styles (`"bold,italic"` etc.) |
| `ansi_highlights.format.bg.color` | `string` | `"auto"` | Background color for ANSI sequences - use `"auto"` to inherit from ANSI codes, or specify custom colors (hex codes/highlight groups) |
| `ansi_highlights.format.bg.style` | `string` | `"auto"` | Background style for ANSI sequences - use `"auto"` to inherit from ANSI codes, or specify custom styles (`"bold,italic"` etc.) |
| `signcolumn.enabled` | `boolean` | `false` | Enable signcolumn indicators for lines with ANSI codes |
| `signcolumn.icon` | `string` | `"𝒜"` | Icon to display in signcolumn for lines with ANSI codes |
| `signcolumn.format.color` | `string` | `"#6d8086"` | Color for signcolumn icon (highlight group name or hex color) |
| `signcolumn.format.style` | `string` | `""` | Style for signcolumn icon - specify custom styles (`"bold,italic"` etc.) |
| `enabled_filetypes` | `table<string>` | `{"*"}` | Filetypes to apply highlighting to (e.g., `{"log", "txt", "*.log"}`) |
| `disabled_filetypes` | `table<string>` | `{}` | Filetypes to exclude from highlighting (overrides `enabled_filetypes`, error if overlaps) |


</details>

### Examples

<details>
<summary>Show ANSI codes always (no concealment)</summary>

```lua
require("ansillary").setup({
  conceal = false,
})
```

</details>

<details>
<summary>Apply only to specific file types</summary>

```lua
require("ansillary").setup({
  enabled_filetypes = { "log", "txt", "*.log", "gitcommit" },
})
```

</details>

<details>
<summary>Apply to all files except specific types</summary>

```lua
require("ansillary").setup({
  enabled_filetypes = { "*" },
  disabled_filetypes = { "markdown", "help" },
})
```

</details>

<details>
<summary>Disable unsupported attribute warnings</summary>

```lua
require("ansillary").setup({
  warn_on_unsupported = false,
})
```

</details>

<details>
<summary>Always keep ANSI codes hidden (no cursor reveal)</summary>

```lua
require("ansillary").setup({
  conceal = true,
  reveal_on_cursorline = false,
})
```

</details>

<details>
<summary>Enable ANSI highlighting with auto-inheritance</summary>

```lua
require("ansillary").setup({
  ansi_highlights = {
    enabled = true,
    format = {
      fg = { color = "auto", style = "auto" }, -- ANSI codes inherit text formatting
      bg = { color = "auto", style = "auto" },
    },
  },
})
```

</details>

<details>
<summary>Custom ANSI highlighting (gray with bold)</summary>

```lua
require("ansillary").setup({
  ansi_highlights = {
    enabled = true,
    format = {
      fg = { color = "#666666", style = "bold" },
      bg = { color = "auto", style = "auto" },
    },
  },
})
```

</details>

<details>
<summary>Mixed auto and custom highlighting</summary>

```lua
require("ansillary").setup({
  ansi_highlights = {
    enabled = true,
    format = {
      fg = { color = "auto", style = "bold,italic" }, -- Auto color, custom style
      bg = { color = "#1e1e1e", style = "auto" },     -- Custom background, auto style
    },
  },
})
```

</details>

<details>
<summary>Disable text highlighting (only show raw text, no ANSI styling)</summary>

```lua
require("ansillary").setup({
  text_highlights = {
    enabled = false,
  },
})
```

</details>

<details>
<summary>Custom text highlighting (override ANSI codes with fixed styling)</summary>

```lua
require("ansillary").setup({
  text_highlights = {
    enabled = true,
    format = {
      fg = { color = "#00ff00", style = "bold" }, -- All text green and bold
      bg = { color = "auto" },                    -- Keep ANSI background colors
    },
  },
})
```

</details>

<details>
<summary>Mixed text highlighting (custom color, auto styling from ANSI)</summary>

```lua
require("ansillary").setup({
  text_highlights = {
    enabled = true,
    format = {
      fg = { color = "#ffaa00", style = "auto" }, -- Custom orange, ANSI syling
      bg = { color = "auto" },                    -- ANSI background colors
    },
  },
})
```

</details>

<details>
<summary>Enable signcolumn indicators with default settings</summary>

```lua
require("ansillary").setup({
  signcolumn = {
    enabled = true,
  },
})
```

</details>

<details>
<summary>Enable signcolumn with custom icon</summary>

```lua
require("ansillary").setup({
  signcolumn = {
    enabled = true,
    icon = "🌈",
  },
})
```

</details>

<details>
<summary>Enable signcolumn with red color and bold style</summary>

```lua
require("ansillary").setup({
  signcolumn = {
    enabled = true,
    icon = "A",
    format = {
      color = "#f38ba8",
      style = "bold",
    },
  },
})
```

</details>

## 🎮 Commands

| Command | Description |
|---------|-------------|
| `:AnsillaryToggle` | Toggle entire plugin on/off |
| `:AnsillaryToggleConceal` | Toggle ANSI code concealment only |
| `:AnsillaryToggleReveal` | Toggle revealing ANSI codes under cursor |
| `:AnsillaryToggleText` | Toggle highlighting of text content based on ANSI codes |
| `:AnsillaryToggleANSI` | Toggle highlighting of ANSI escape sequences |

## 🔗 API

```lua
local ansillary = require("ansillary")

-- Toggle plugin functionality completely
ansillary.toggle()

-- Toggle concealment only (keep highlighting)
ansillary.toggle_conceal()

-- Toggle revealing ANSI codes under cursor
ansillary.toggle_reveal()

-- Toggle highlighting text content
ansillary.toggle_text_highlights()

-- Toggle highlighting ANSI escape sequences
ansillary.toggle_ansi_highlights()
```

## 🌈 Supported ANSI Formats

ansillary.nvim supports **many different ANSI escape sequence formats**:

### Basic Formats
```shell
\033[1;34;46mLorem ipsum\033[0m  # Octal escape
\e[1;34;46mLorem ipsum\e[0m      # Short escape
\x1b[1;34;46mLorem ipsum\x1b[0m  # Hex escape (lowercase)
\x1B[1;34;46mLorem ipsum\x1B[0m  # Hex escape (uppercase)
```

### Unicode Formats
```shell
\u001b[1;34;46mLorem ipsum\u001b[0m          # 4-digit Unicode
\U0000001b[1;34;46mLorem ipsum\U0000001b[0m  # 8-digit Unicode
```

### Bash Quoted Formats
```bash
$'\033[1;34;46mLorem ipsum\033[0m'              # Quoted octal
$'\e[1;34;46mLorem ipsum\e[0m'                  # Quoted short
$'\x1b[1;34;46mLorem ipsum\x1b[0m'              # Quoted hex (lowercase)
$'\x1B[1;34;46mLorem ipsum\x1B[0m'              # Quoted hex (uppercase)
$'\u001b[1;34;46mLorem ipsum\u001b[0m'          # Quoted Unicode (4-digit)
$'\U0000001b[1;34;46mLorem ipsum\U0000001b[0m'  # Quoted Unicode (8-digit)
```

### Other Formats
```shell
^[[1;34;46mLorem ipsum^[[0m  # Literal ESC character
```

## 🎨 ANSI Code Support

### Colors
- **Foreground**: `30-37` (standard), `90-97` (bright)
- **Background**: `40-47` (standard), `100-107` (bright)

### Text Styles
- `0`: Reset all formatting
- `1`: Bold
- `2`: Dim *(not supported by Neovim - ignored with optional warning)*
- `3`: Italic
- `4`: Underline
- `5`: Blink *(not supported by Neovim - ignored with optional warning)*
- `7`: Reverse video
- `9`: Strikethrough

## 💡 Usage Examples

### Basic Text Styling
```
Regular text with \033[32mgreen\033[0m and \033[31mred\033[0m words.
Fancy formats: \033[1;3;4;35mbold italic underlined magenta\033[0m
Background: \033[43;30myellow bg, black text\033[0m
```

### Grep Integration
```bash
grep --color=always "pattern" *.log | nvim
```

### Shell Scripts
```bash
echo -e "\e[1;32m✓ SUCCESS:\e[0m Operation completed"
echo -e "\x1b[1;31m✗ ERROR:\x1b[0m Operation failed"
```

### Mixed Formats
```shell
\033[31mRed\033[0m \u001b[32mGreen\u001b[0m ^[[34mBlue^[[0m text
```

## 🔧 How It Works

1. **Pattern Detection**: Scans for ANSI sequences using regex
2. **Code Parsing**: Extracts numeric codes and converts to color/style attributes
3. **Highlight Application**: Creates Neovim highlight groups and applies them to text
4. **Smart Concealment**: Uses extmarks to hide ANSI codes except on cursor line
5. **Real-Time Updates**: Responds immediately to cursor movement and text edits

## 📋 Requirements

- **Neovim** ≥ 0.7.0
- **Terminal** with true color support (recommended)

## 🧪 Testing

This plugin includes comprehensive tests to ensure reliability and prevent regressions during development.

### Test Structure

The test suite is organized as follows:

```
tests/
├── test_helper.lua           # Test utilities and vim API mocking
├── fixtures/
│   └── ansi_samples.lua      # Sample ANSI sequences for testing
├── unit/                     # Unit tests for individual modules
│   ├── regex_spec.lua        # Tests for ANSI pattern matching
│   ├── config_spec.lua       # Tests for configuration handling
│   ├── highlights_spec.lua   # Tests for highlight creation
│   └── init_spec.lua         # Tests for main plugin logic
└── integration/              # Integration tests
    └── full_integration_spec.lua # End-to-end workflow tests
```

### Running Tests

#### Prerequisites

- **Lua** ≥ 5.1 (5.4 recommended)
- **Busted** testing framework (optional, basic runner included)

#### Quick Start

```bash
# Run all unit tests
make test

# Or run directly with lua
lua run_all_tests.lua
```

#### Available Test Commands

```bash
# Run all unit tests (default)
make test

# Run all tests including integration
make test-all

# Run tests for specific modules
make test-regex      # Test ANSI pattern matching
make test-config     # Test configuration handling
make test-highlights # Test highlight creation
make test-init       # Test main plugin logic

# Clean test artifacts
make clean

# Show help
make help
```

### Test Coverage

The test suite covers:

**Core Functionality:**
- ✅ ANSI escape sequence detection and parsing
- ✅ All supported ANSI color codes (0-15)
- ✅ Text styling (bold, italic, underline, reverse, strikethrough)
- ✅ Highlight group creation and management
- ✅ Configuration validation and merging

**ANSI Format Support:**
- ✅ Octal sequences (`\033[31m`)
- ✅ Short sequences (`\e[31m`)
- ✅ Hex sequences (`\x1b[31m`, `\x1B[31m`)
- ✅ Unicode sequences (`\u001b[31m`, `\U0000001b[31m`)
- ✅ Bash quoted formats (`$'\033[31m'`)
- ✅ Literal ESC characters (`^[[31m`)
- ✅ CSI sequences (`\x9b31m`)

**Edge Cases:**
- ✅ Empty ANSI codes (reset sequences)
- ✅ Malformed sequences
- ✅ Consecutive ANSI codes
- ✅ Very long attribute lists
- ✅ Mixed formats in single line
- ✅ Multiline content processing

**Plugin Features:**
- ✅ Concealment with cursor reveal
- ✅ ANSI sequence highlighting
- ✅ Filetype filtering
- ✅ Toggle operations
- ✅ Configuration options
- ✅ Real-world format compatibility

### Adding Tests

When contributing new features:

1. **Unit Tests**: Add tests to appropriate `*_spec.lua` file
2. **Integration Tests**: Add end-to-end scenarios to `full_integration_spec.lua`
3. **Fixtures**: Add new ANSI samples to `ansi_samples.lua`
4. **Edge Cases**: Ensure error conditions are tested

Example test:
```lua
describe("new feature", function()
  it("should handle specific case", function()
    helper.create_test_buffer({"test content"})
    ansillary.setup({option = true})

    assert.has_no.errors(function()
      ansillary._trigger_highlighting_for_tests()
    end)
  end)
end)
```

### Test Development

The test suite uses a custom vim API mock that simulates Neovim's behavior without requiring a full Neovim instance. This allows for:

- **Fast execution** - Tests run in milliseconds
- **Reliable isolation** - Each test starts with clean state
- **Comprehensive mocking** - All vim API functions used by the plugin
- **Easy debugging** - Pure Lua environment with standard debugging tools

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Report bugs or request features via [issues]
- Submit pull requests
- Improve documentation
- Add test cases

**Before submitting pull requests:**
1. Run the test suite: `make test`
2. Ensure all tests pass
3. Add tests for new functionality
4. Update documentation as needed

## 📄 License

MIT License. See [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for the Neovim community**
