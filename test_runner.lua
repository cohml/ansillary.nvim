#!/usr/bin/env lua

-- Simple test runner for ansillary.nvim tests
-- Add the project root to the Lua path
local project_root = arg[0]:match("(.*/)")
if project_root then
    package.path = project_root .. "?.lua;" .. project_root .. "lua/?.lua;" .. package.path
else
    package.path = "./?.lua;./lua/?.lua;" .. package.path
end

-- Try to run busted
local busted = require('busted')

-- Set up busted configuration
local busted_runner = require('busted.runner')

-- Run the tests
local success, result = pcall(busted_runner, {
    pattern = "tests/.*%.lua$",
    recursive = true,
    ROOT = {"."},
    lpath = ".",
    verbose = true,
    output = "utfTerminal"
})

if success then
    print("Tests completed")
    os.exit(result and 0 or 1)
else
    print("Error running tests:", result)
    os.exit(1)
end
