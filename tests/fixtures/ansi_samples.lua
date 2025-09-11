-- Sample ANSI escape sequences for testing
local M = {}

-- Basic color samples
M.basic_colors = {
  {text = "\\033[30mBlack\\033[0m", expected_fg = 0, description = "Black foreground"},
  {text = "\\033[31mRed\\033[0m", expected_fg = 1, description = "Red foreground"},
  {text = "\\033[32mGreen\\033[0m", expected_fg = 2, description = "Green foreground"},
  {text = "\\033[33mYellow\\033[0m", expected_fg = 3, description = "Yellow foreground"},
  {text = "\\033[34mBlue\\033[0m", expected_fg = 4, description = "Blue foreground"},
  {text = "\\033[35mMagenta\\033[0m", expected_fg = 5, description = "Magenta foreground"},
  {text = "\\033[36mCyan\\033[0m", expected_fg = 6, description = "Cyan foreground"},
  {text = "\\033[37mWhite\\033[0m", expected_fg = 7, description = "White foreground"},
}

-- Bright color samples
M.bright_colors = {
  {text = "\\033[90mBright Black\\033[0m", expected_fg = 8, description = "Bright black foreground"},
  {text = "\\033[91mBright Red\\033[0m", expected_fg = 9, description = "Bright red foreground"},
  {text = "\\033[92mBright Green\\033[0m", expected_fg = 10, description = "Bright green foreground"},
  {text = "\\033[93mBright Yellow\\033[0m", expected_fg = 11, description = "Bright yellow foreground"},
  {text = "\\033[94mBright Blue\\033[0m", expected_fg = 12, description = "Bright blue foreground"},
  {text = "\\033[95mBright Magenta\\033[0m", expected_fg = 13, description = "Bright magenta foreground"},
  {text = "\\033[96mBright Cyan\\033[0m", expected_fg = 14, description = "Bright cyan foreground"},
  {text = "\\033[97mBright White\\033[0m", expected_fg = 15, description = "Bright white foreground"},
}

-- Background color samples
M.background_colors = {
  {text = "\\033[40mBlack BG\\033[0m", expected_bg = 0, description = "Black background"},
  {text = "\\033[41mRed BG\\033[0m", expected_bg = 1, description = "Red background"},
  {text = "\\033[42mGreen BG\\033[0m", expected_bg = 2, description = "Green background"},
  {text = "\\033[43mYellow BG\\033[0m", expected_bg = 3, description = "Yellow background"},
  {text = "\\033[44mBlue BG\\033[0m", expected_bg = 4, description = "Blue background"},
  {text = "\\033[45mMagenta BG\\033[0m", expected_bg = 5, description = "Magenta background"},
  {text = "\\033[46mCyan BG\\033[0m", expected_bg = 6, description = "Cyan background"},
  {text = "\\033[47mWhite BG\\033[0m", expected_bg = 7, description = "White background"},
}

-- Style samples
M.text_styles = {
  {text = "\\033[1mBold\\033[0m", expected_attrs = {bold = true}, description = "Bold text"},
  {text = "\\033[2mDim\\033[0m", expected_attrs = {dim = true}, description = "Dim text (unsupported)"},
  {text = "\\033[3mItalic\\033[0m", expected_attrs = {italic = true}, description = "Italic text"},
  {text = "\\033[4mUnderline\\033[0m", expected_attrs = {underline = true}, description = "Underlined text"},
  {text = "\\033[5mBlink\\033[0m", expected_attrs = {blink = true}, description = "Blinking text (unsupported)"},
  {text = "\\033[7mReverse\\033[0m", expected_attrs = {reverse = true}, description = "Reverse video"},
  {text = "\\033[9mStrikethrough\\033[0m", expected_attrs = {strikethrough = true}, description = "Strikethrough text"},
}

-- Combined style and color samples
M.combined_styles = {
  {text = "\\033[1;31mBold Red\\033[0m", expected_attrs = {bold = true, fg = 1}, description = "Bold red text"},
  {text = "\\033[3;4;32mItalic Underlined Green\\033[0m", expected_attrs = {italic = true, underline = true, fg = 2}, description = "Italic underlined green"},
  {text = "\\033[1;4;7;35mBold Underlined Reverse Magenta\\033[0m", expected_attrs = {bold = true, underline = true, reverse = true, fg = 5}, description = "Multiple styles with magenta"},
  {text = "\\033[31;42mRed on Green\\033[0m", expected_attrs = {fg = 1, bg = 2}, description = "Red text on green background"},
  {text = "\\033[1;37;44mBold White on Blue\\033[0m", expected_attrs = {bold = true, fg = 7, bg = 4}, description = "Bold white on blue background"},
}

-- Different escape sequence formats
M.escape_formats = {
  {text = "\\033[31mOctal\\033[0m", description = "Octal escape sequence"},
  {text = "\\e[32mShort\\e[0m", description = "Short escape sequence"},
  {text = "\\x1b[33mHex lowercase\\x1b[0m", description = "Hex escape (lowercase)"},
  {text = "\\x1B[34mHex uppercase\\x1B[0m", description = "Hex escape (uppercase)"},
  {text = "\\u001b[35mUnicode 4-digit\\u001b[0m", description = "Unicode 4-digit escape"},
  {text = "\\U0000001b[36mUnicode 8-digit\\U0000001b[0m", description = "Unicode 8-digit escape"},
  {text = "\027[37mLiteral ESC\027[0m", description = "Literal ESC character"},
  {text = "^[[31mCaret notation^[[0m", description = "Caret notation"},
}

-- Bash quoted formats
M.bash_quoted = {
  {text = "$'\\033[31m'Red$'\\033[0m'", description = "Bash quoted octal"},
  {text = "$'\\e[32m'Green$'\\e[0m'", description = "Bash quoted short"},
  {text = "$'\\x1b[33m'Yellow$'\\x1b[0m'", description = "Bash quoted hex lowercase"},
  {text = "$'\\x1B[34m'Blue$'\\x1B[0m'", description = "Bash quoted hex uppercase"},
  {text = "$'\\u001b[35m'Magenta$'\\u001b[0m'", description = "Bash quoted Unicode 4-digit"},
  {text = "$'\\U0000001b[36m'Cyan$'\\U0000001b[0m'", description = "Bash quoted Unicode 8-digit"},
}

-- Edge cases
M.edge_cases = {
  {text = "\\033[mEmpty reset\\033[0m", description = "Empty ANSI code (should reset)"},
  {text = "\\033[0mExplicit reset", description = "Explicit reset code"},
  {text = "\\033[1;2;3;4;5;7;9;31;42mMany attributes\\033[0m", description = "Many attributes in one sequence"},
  {text = "\\033[31m\\033[32m\\033[0mConsecutive codes", description = "Consecutive ANSI codes"},
  {text = "Normal \\033[31mred\\033[0m normal \\033[32mgreen\\033[0m normal", description = "Interspersed normal text"},
  {text = "\\033[31m", description = "Unclosed ANSI sequence"},
  {text = "\\033[999mInvalid code\\033[0m", description = "Invalid ANSI code number"},
}

-- Real-world samples (from actual tools)
M.real_world = {
  {text = "grep: \\033[01;31m\\033[Kpattern\\033[m\\033[K matched", description = "grep --color output"},
  {text = "ls: \\033[0m\\033[01;34mfolder\\033[0m", description = "ls --color directory"},
  {text = "git: \\033[32m+added line\\033[0m", description = "git diff added line"},
  {text = "git: \\033[31m-removed line\\033[0m", description = "git diff removed line"},
  {text = "make: \\033[01;31mError:\\033[0m compilation failed", description = "make error output"},
  {text = "gcc: \\033[01;35mwarning:\\033[0m deprecated function", description = "gcc warning"},
}

-- Complex multi-line samples
M.multiline_samples = {
  {
    lines = {
      "\\033[1;34m=== Build Log ===\\033[0m",
      "\\033[32m✓ Step 1 completed\\033[0m",
      "\\033[33m⚠ Step 2 warning\\033[0m",
      "\\033[31m✗ Step 3 failed\\033[0m",
      "\\033[1;37mTotal: \\033[32m1 passed\\033[0m, \\033[33m1 warning\\033[0m, \\033[31m1 failed\\033[0m"
    },
    description = "Build log with status indicators"
  },
  {
    lines = {
      "\\033[36mINFO\\033[0m: Starting application",
      "\\033[33mWARN\\033[0m: Configuration file not found, using defaults",
      "\\033[31mERROR\\033[0m: Failed to connect to database",
      "\\033[35mDEBUG\\033[0m: Retrying connection in 5 seconds",
    },
    description = "Application log with different levels",
  },
}

return M
