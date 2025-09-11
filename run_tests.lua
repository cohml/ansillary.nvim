#!/usr/bin/env lua

-- Simple test runner
package.path = "./?.lua;./lua/?.lua;./lua/ansillary/?.lua;./tests/?.lua;" .. package.path

-- Load test helper and set up mocks
local helper = require("tests.test_helper")
helper.setup_vim_mock()

-- Simple test framework
local tests_passed = 0
local tests_failed = 0
local current_describe = ""

local function describe(name, fn)
  current_describe = name
  print("\n" .. name)
  fn()
end

local function it(name, fn)
  local success, err = pcall(fn)
  if success then
    print("  ✓ " .. name)
    tests_passed = tests_passed + 1
  else
    print("  ✗ " .. name .. ": " .. tostring(err))
    tests_failed = tests_failed + 1
  end
end

-- Mock assert functions
local assert = {}
assert.are = {}
assert.are.equal = function(expected, actual, message)
  if expected ~= actual then
    error((message or "") .. " Expected: " .. tostring(expected) .. ", got: " .. tostring(actual))
  end
end
assert.is_true = function(value, message)
  if not value then
    error((message or "") .. " Expected true, got: " .. tostring(value))
  end
end
assert.is_false = function(value, message)
  if value then
    error((message or "") .. " Expected false, got: " .. tostring(value))
  end
end
assert.is_nil = function(value, message)
  if value ~= nil then
    error((message or "") .. " Expected nil, got: " .. tostring(value))
  end
end
assert.is_not_nil = function(value, message)
  if value == nil then
    error((message or "") .. " Expected not nil, got nil")
  end
end
assert.is_table = function(value, message)
  if type(value) ~= "table" then
    error((message or "") .. " Expected table, got: " .. type(value))
  end
end
assert.is_string = function(value, message)
  if type(value) ~= "string" then
    error((message or "") .. " Expected string, got: " .. type(value))
  end
end
assert.is_boolean = function(value, message)
  if type(value) ~= "boolean" then
    error((message or "") .. " Expected boolean, got: " .. type(value))
  end
end
assert.are.same = function(expected, actual, message)
  -- Simple table comparison
  if type(expected) ~= type(actual) then
    error((message or "") .. " Type mismatch")
  end
  if type(expected) == "table" then
    for k, v in pairs(expected) do
      if actual[k] ~= v then
        error((message or "") .. " Table mismatch at key " .. tostring(k))
      end
    end
    for k, v in pairs(actual) do
      if expected[k] == nil then
        error((message or "") .. " Unexpected key " .. tostring(k))
      end
    end
  else
    if expected ~= actual then
      error((message or "") .. " Expected: " .. tostring(expected) .. ", got: " .. tostring(actual))
    end
  end
end

assert.has_no = {}
assert.has_no.errors = function(fn, message)
  local success, err = pcall(fn)
  if not success then
    error((message or "") .. " Unexpected error: " .. tostring(err))
  end
end

-- Make assert global
_G.assert = assert
_G.describe = describe
_G.it = it

-- Test basic functionality
describe("Basic functionality test", function()
  it("should load regex module", function()
    local regex = require("ansillary.regex")
    assert.is_table(regex)
  end)

  it("should load config module", function()
    local config = require("ansillary.config")
    assert.is_table(config)
    assert.is_boolean(config.conceal)
  end)

  it("should load highlights module", function()
    local highlights = require("ansillary.highlights")
    assert.is_table(highlights)
  end)

  it("should load main module", function()
    local ansillary = require("ansillary.init")
    assert.is_table(ansillary)
  end)
end)

-- Test ANSI parsing with literal escape characters
describe("ANSI parsing", function()
  it("should parse literal ESC sequences", function()
    local regex = require("ansillary.regex")
    -- Test with actual ESC character (ASCII 27)
    local line = string.char(27) .. "[31mred" .. string.char(27) .. "[0m"
    local start_pos, end_pos, code = regex.find_ansi_sequence(line, 1)
    assert.is_not_nil(start_pos, "Should find ANSI sequence")
    assert.are.equal("31", code)
  end)
end)

-- Print results summary
print(string.format("\n\nTest Results: %d passed, %d failed", tests_passed, tests_failed))
if tests_failed > 0 then
  os.exit(1)
else
  print("All tests passed!")
  os.exit(0)
end
