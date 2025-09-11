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

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "cohml/ansillary.nvim",
  config = function()
    require("ansillary").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "cohml/ansillary.nvim",
  config = function()
    require("ansillary").setup()
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'cohml/ansillary.nvim'
```

Then add to your `init.lua`:

```lua
require("ansillary").setup()
```

## ⚙️ Configuration

### Default Settings

```lua
require("ansillary").setup({
  conceal = true,              -- Hide ANSI escape sequences
  reveal_under_cursor = true,  -- Reveal ANSI codes when cursor is on the line
  warn_on_unsupported = true,  -- Show warning when unsupported attributes are encountered
  ansi_highlights = {          -- ANSI escape sequence highlighting configuration
    enabled = false,           -- Enable highlighting of ANSI escape sequences themselves
    format = {                 -- Formatting options for ANSI sequences
      fg = {
        color = "auto",        -- Color for ANSI sequences (auto = inherit from styled text)
        style = "auto"         -- Style for ANSI sequences (auto = inherit from styled text)
      },
      bg = {
        color = "auto",        -- Background color for ANSI sequences (auto = inherit from styled text)
        style = "auto",        -- Background style for ANSI sequences (auto = inherit from styled text)
      },
    },
  },
  enabled_filetypes = { "*" }, -- Filetypes to apply highlighting to
  disabled_filetypes = {},     -- Filetypes to exclude from highlighting
})
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `conceal` | `boolean` | `true` | Enable concealment of ANSI codes |
| `reveal_under_cursor` | `boolean` | `true` | Reveal ANSI codes when cursor is on the line (no effect when `conceal = false`) |
| `warn_on_unsupported` | `boolean` | `true` | Show warning when unsupported attributes (dim, blink) are encountered |
| `ansi_highlights.enabled` | `boolean` | `false` | Enable highlighting of ANSI escape sequences themselves |
| `ansi_highlights.format.fg.color` | `string` | `"auto"` | Foreground color for ANSI sequences - use `"auto"` to inherit from styled text, or specify custom colors (hex codes/highlight groups) |
| `ansi_highlights.format.fg.style` | `string` | `"auto"` | Foreground style for ANSI sequences - use `"auto"` to inherit from styled text, or specify custom styles (`"bold,italic"` etc.) |
| `ansi_highlights.format.bg.color` | `string` | `"auto"` | Background color for ANSI sequences - use `"auto"` to inherit from styled text, or specify custom colors (hex codes/highlight groups) |
| `ansi_highlights.format.bg.style` | `string` | `"auto"` | Background style for ANSI sequences - use `"auto"` to inherit from styled text, or specify custom styles (`"bold,italic"` etc.) |
| `enabled_filetypes` | `table<string>` | `{"*"}` | Filetypes to apply highlighting to (e.g., `{"log", "txt", "*.log"}`) |
| `disabled_filetypes` | `table<string>` | `{}` | Filetypes to exclude from highlighting (overrides `enabled_filetypes`, error if overlaps) |

### Examples

```lua
-- Show ANSI codes always (no concealment)
require("ansillary").setup({
  conceal = false,
})

-- Apply only to specific file types
require("ansillary").setup({
  enabled_filetypes = { "log", "txt", "*.log", "gitcommit" },
})

-- Apply to all files except specific types
require("ansillary").setup({
  enabled_filetypes = { "*" },
  disabled_filetypes = { "markdown", "help" },
})

-- Disable unsupported attribute warnings
require("ansillary").setup({
  warn_on_unsupported = false,
})

-- Always keep ANSI codes hidden (no cursor reveal)
require("ansillary").setup({
  conceal = true,
  reveal_under_cursor = false,
})

-- Enable ANSI highlighting with auto-inheritance
require("ansillary").setup({
  ansi_highlights = {
    enabled = true,
    format = {
      fg = { color = "auto", style = "auto" }, -- ANSI codes inherit text formatting
      bg = { color = "auto", style = "auto" },
    },
  },
})

-- Custom ANSI highlighting (gray with bold)
require("ansillary").setup({
  ansi_highlights = {
    enabled = true,
    format = {
      fg = { color = "#666666", style = "bold" },
      bg = { color = "auto", style = "auto" },
    },
  },
})

-- Mixed auto and custom highlighting
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

## 🎮 Commands

| Command | Description |
|---------|-------------|
| `:AnsillaryToggle` | Toggle entire plugin on/off |
| `:AnsillaryToggleConceal` | Toggle ANSI code concealment only |
| `:AnsillaryToggleReveal` | Toggle revealing ANSI codes under cursor |
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
