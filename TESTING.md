# Testing Guide for ansillary.nvim

This document provides detailed information about the testing infrastructure for ansillary.nvim.

## Overview

The testing suite is designed to ensure the plugin works reliably across different ANSI escape sequence formats and edge cases. Tests run without requiring a full Neovim instance by using a comprehensive vim API mock.

## Test Structure

### Unit Tests (`tests/unit/`)

- **`regex_spec.lua`** - Tests ANSI pattern matching and extraction
- **`config_spec.lua`** - Tests configuration loading and validation
- **`highlights_spec.lua`** - Tests highlight group creation and color mapping
- **`init_spec.lua`** - Tests main plugin logic, integration, and user commands

### Integration Tests (`tests/integration/`)

- **`full_integration_spec.lua`** - End-to-end testing with real-world ANSI samples

### Test Fixtures (`tests/fixtures/`)

- **`ansi_samples.lua`** - Comprehensive collection of ANSI escape sequence samples for testing

### Test Utilities (`tests/`)

- **`test_helper.lua`** - Vim API mocking and test utility functions

## Running Tests

### Prerequisites

Ensure you have Lua installed (version 5.1 or higher, 5.4 recommended):

```bash
lua -v  # Check if Lua is installed
```

### Running All Tests

```bash
# Using Make (recommended)
make test

# Or directly with Lua
lua run_tests.lua
```

### Running Specific Test Modules

```bash
# Test individual modules
make test-regex      # ANSI pattern matching tests
make test-config     # Configuration tests
make test-highlights # Highlight creation tests
make test-init       # Main plugin logic tests
```

### Test Output

Successful test run:
```
Basic functionality test
  ✓ should load regex module
  ✓ should load config module
  ✓ should load highlights module
  ✓ should load main module

ANSI parsing
  ✓ should parse literal ESC sequences

Test Results: 5 passed, 0 failed
All tests passed!
```

Failed test run:
```
📊 Final Results: 107 passed, 1 failed

❌ Failed tests:
   1. config > configuration structure > should have correct default values
      → Expected boolean, got: string
```

## Test Development

### Adding New Tests

1. **Choose the appropriate test file** based on what you're testing:
   - Regex pattern matching → `tests/unit/regex_spec.lua`
   - Configuration → `tests/unit/config_spec.lua`
   - Highlight creation → `tests/unit/highlights_spec.lua`
   - Main plugin logic → `tests/unit/init_spec.lua`
   - End-to-end workflows → `tests/integration/full_integration_spec.lua`

2. **Follow the test structure**:
   ```lua
   describe("feature being tested", function()
     before_each(function()
       -- Setup code (reset state, etc.)
     end)

     it("should do something specific", function()
       -- Test implementation
       assert.are.equal(expected, actual)
     end)
   end)
   ```

3. **Use the test helper functions**:
   ```lua
   local helper = require("tests.test_helper")
   helper.setup_vim_mock()  -- Set up vim API mocks
   helper.create_test_buffer({"line1", "line2"})  -- Create test buffer content
   ```

### Available Assertions

The test framework provides these assertion functions:

- `assert.are.equal(expected, actual, message)`
- `assert.are.same(expected_table, actual_table, message)`
- `assert.is_true(value, message)`
- `assert.is_false(value, message)`
- `assert.is_nil(value, message)`
- `assert.is_not_nil(value, message)`
- `assert.is_table(value, message)`
- `assert.is_string(value, message)`
- `assert.is_boolean(value, message)`
- `assert.has_no.errors(function, message)`

### Test Fixtures

Add new ANSI samples to `tests/fixtures/ansi_samples.lua`:

```lua
-- Add to appropriate category
M.new_category = {
  {
    text = "\\033[38;5;196mBright red\\033[0m",
    expected_attrs = {fg_extended = true},
    description = "256-color foreground",
  },
}
```

### Mocking Vim API

The test helper provides comprehensive vim API mocking:

```lua
-- Mock vim functions are automatically set up
vim.api.nvim_set_hl(0, "TestGroup", {fg = "#ff0000"})
vim.notify("Test message", vim.log.levels.WARN)
vim.tbl_deep_extend("force", {}, {key = "value"})
```

You can extend mocking as needed:

```lua
-- Custom mock function
vim.api.custom_function = function(arg)
  return "mocked_result"
end
```

## Testing Best Practices

### 1. Test Isolation

Each test should be independent and not rely on state from other tests:

```lua
before_each(function()
  helper.reset_vim_mock()  -- Reset all mocks to clean state
  package.loaded["ansillary.init"] = nil  -- Clear module cache
end)
```

### 2. Descriptive Test Names

Use clear, descriptive test names:

```lua
-- Good
it("should parse multiple ANSI attributes in single sequence", function()

-- Bad
it("should work", function()
```

### 3. Test Edge Cases

Always test boundary conditions and error cases:

```lua
it("should handle empty ANSI codes gracefully", function()
  local line = "\\033[m"  -- Empty code
  -- Test that it doesn't crash
end)

it("should handle malformed sequences", function()
  local line = "\\033[incomplete"
  -- Test graceful degradation
end)
```

### 4. Use Fixtures for Complex Data

For complex test data, use the fixtures system:

```lua
local fixtures = require("tests.fixtures.ansi_samples")

for _, sample in ipairs(fixtures.basic_colors) do
  it("should handle " .. sample.description, function()
    -- Test with sample.text
  end)
end
```

## Debugging Tests

### Common Issues

1. **Module not found errors**: Check that `package.path` includes the correct directories
2. **Vim API errors**: Ensure `helper.setup_vim_mock()` is called before requiring modules
3. **State pollution**: Use `before_each` to reset state between tests

### Debug Output

Add debug prints to understand test behavior:

```lua
it("should debug something", function()
  local result = some_function()
  print("Debug result:", vim.inspect(result))  -- Use vim.inspect for tables
  assert.are.equal(expected, result)
end)
```

### Running Single Tests

To run a specific test, modify the test file temporarily:

```lua
-- Add 'only' to focus on specific test
it.only("should run only this test", function()
  -- Test code
end)
```

## Continuous Integration

When setting up CI, ensure the test environment has:

- Lua 5.1+ installed
- Make utility (for Makefile commands)
- Access to the project directory

Example CI command:
```bash
make test
```

The tests are designed to run in any Unix-like environment and return appropriate exit codes for CI systems.
