#!/usr/bin/env lua

-- Comprehensive test runner that actually runs all the spec files
package.path = "./?.lua;./lua/?.lua;./lua/ansillary/?.lua;./tests/?.lua;" .. package.path

-- Global test state
local total_tests_passed = 0
local total_tests_failed = 0
local current_describe = ""
local current_suite = ""
local failed_tests = {}

-- Test framework functions
local function describe(name, fn)
  current_describe = name
  print("\n📁 " .. current_suite .. " > " .. name)
  fn()
end

-- Store before_each functions
local before_each_functions = {}

local function before_each(fn)
  table.insert(before_each_functions, fn)
end

local function reset_before_each()
  before_each_functions = {}
end

local function run_before_each()
  for _, fn in ipairs(before_each_functions) do
    fn()
  end
end

local function it(name, fn)
  -- Run before_each functions before each test
  run_before_each()

  local success, err = pcall(fn)
  if success then
    print("  ✅ " .. name)
    total_tests_passed = total_tests_passed + 1
  else
    local full_test_name = current_suite .. " > " .. current_describe .. " > " .. name
    print("  ❌ " .. name)
    print("     💥 " .. tostring(err))
    table.insert(failed_tests, {
      name = full_test_name,
      error = tostring(err)
    })
    total_tests_failed = total_tests_failed + 1
  end
end

-- Comprehensive assert library
local assert = {}
assert.are = {}
assert.are.equal = function(expected, actual, message)
  if expected ~= actual then
    local msg = (message or "") .. " Expected: " .. tostring(expected) .. ", got: " .. tostring(actual)
    error(msg)
  end
end

assert.are.same = function(expected, actual, message)
  -- Deep table comparison
  local function deep_equal(t1, t2)
    if type(t1) ~= type(t2) then return false end
    if type(t1) ~= "table" then return t1 == t2 end

    for k, v in pairs(t1) do
      if not deep_equal(v, t2[k]) then return false end
    end

    for k, v in pairs(t2) do
      if not deep_equal(v, t1[k]) then return false end
    end

    return true
  end

  if not deep_equal(expected, actual) then
    local msg = (message or "") .. " Tables are not equal"
    error(msg)
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

assert.has_no = {}
assert.has_no.errors = function(fn, message)
  local success, err = pcall(fn)
  if not success then
    error((message or "") .. " Unexpected error: " .. tostring(err))
  end
end

assert.has = {}
assert.has.errors = function(fn, message)
  local success, err = pcall(fn)
  if success then
    error((message or "") .. " Expected an error but none occurred")
  end
end

-- Make globals available to spec files
_G.describe = describe
_G.it = it
_G.before_each = before_each
_G.assert = assert

-- Function to run a spec file
local function run_spec_file(filepath)
  current_suite = filepath:match("([^/]+)_spec%.lua$") or filepath

  print("\n🧪 Running " .. filepath)

  -- Reset before_each functions for each spec file
  reset_before_each()

  -- Set up fresh environment for each spec file
  local helper = require("tests.test_helper")
  helper.setup_vim_mock()

  -- Clear module cache before each spec file
  for module_name, _ in pairs(package.loaded) do
    if module_name:match("^ansillary") then
      package.loaded[module_name] = nil
    end
  end

  local success, err = pcall(dofile, filepath)
  if not success then
    print("❌ Failed to load spec file " .. filepath .. ": " .. tostring(err))
    table.insert(failed_tests, {
      name = current_suite .. " > SPEC FILE LOAD ERROR",
      error = tostring(err)
    })
    total_tests_failed = total_tests_failed + 1
  end
end

-- List of spec files to run
local spec_files = {
  "tests/unit/regex_spec.lua",
  "tests/unit/config_spec.lua",
  "tests/unit/highlights_spec.lua",
  "tests/unit/init_spec.lua",
  "tests/integration/full_integration_spec.lua",
}

print("🚀 Running comprehensive test suite for ansillary.nvim")
print("=" .. string.rep("=", 50))

-- Run all spec files
for _, spec_file in ipairs(spec_files) do
  local file = io.open(spec_file, "r")
  if file then
    file:close()
    run_spec_file(spec_file)
  else
    print("❌ Spec file not found: " .. spec_file)
    total_tests_failed = total_tests_failed + 1
  end
end

-- Print results summary
print("\n" .. "=" .. string.rep("=", 50))
print(string.format("📊 Final Results: %d passed, %d failed", total_tests_passed, total_tests_failed))

if total_tests_failed > 0 then
  print("\n❌ Failed tests:")
  for i, failed_test in ipairs(failed_tests) do
    print(string.format("   %d. %s", i, failed_test.name))
    -- Optionally show the error in a shortened format
    local short_error = failed_test.error:match("^[^:]*:[^:]*: (.*)") or failed_test.error
    if #short_error > 80 then
      short_error = short_error:sub(1, 77) .. "..."
    end
    print(string.format("      → %s", short_error))
  end
  os.exit(1)
else
  print("✅ All tests passed!")
  os.exit(0)
end
