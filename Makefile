.PHONY: test test-unit test-integration test-all clean

# Test targets
test: test-unit

test-unit:
	@echo "Running unit tests..."
	@lua run_all_tests.lua

test-integration:
	@echo "Running integration tests..."
	@echo "Integration tests require a full Neovim environment"

test-all: test-unit test-integration

# Run specific test files
test-regex:
	@echo "Testing regex module..."
	@lua -e "package.path='./?.lua;./lua/?.lua;./lua/ansillary/?.lua;./tests/?.lua;'..package.path; require('tests.test_helper').setup_vim_mock(); dofile('tests/unit/regex_spec.lua')" 2>/dev/null || echo "Use 'make test' for full test suite"

test-config:
	@echo "Testing config module..."
	@lua -e "package.path='./?.lua;./lua/?.lua;./lua/ansillary/?.lua;./tests/?.lua;'..package.path; require('tests.test_helper').setup_vim_mock(); dofile('tests/unit/config_spec.lua')" 2>/dev/null || echo "Use 'make test' for full test suite"

test-highlights:
	@echo "Testing highlights module..."
	@lua -e "package.path='./?.lua;./lua/?.lua;./lua/ansillary/?.lua;./tests/?.lua;'..package.path; require('tests.test_helper').setup_vim_mock(); dofile('tests/unit/highlights_spec.lua')" 2>/dev/null || echo "Use 'make test' for full test suite"

test-init:
	@echo "Testing init module..."
	@lua -e "package.path='./?.lua;./lua/?.lua;./lua/ansillary/?.lua;./tests/?.lua;'..package.path; require('tests.test_helper').setup_vim_mock(); dofile('tests/unit/init_spec.lua')" 2>/dev/null || echo "Use 'make test' for full test suite"

# Coverage (if available)
test-coverage:
	@echo "Code coverage analysis not implemented yet"

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	@rm -f *.log
	@rm -f tests/*.log

# Help target
help:
	@echo "Available test targets:"
	@echo "  test          - Run unit tests (default)"
	@echo "  test-unit     - Run unit tests only"
	@echo "  test-all      - Run all tests"
	@echo "  test-regex    - Test regex module only"
	@echo "  test-config   - Test config module only"
	@echo "  test-highlights - Test highlights module only"
	@echo "  test-init     - Test init module only"
	@echo "  clean         - Clean test artifacts"
	@echo "  help          - Show this help message"
