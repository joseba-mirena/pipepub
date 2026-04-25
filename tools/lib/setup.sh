#!/bin/bash
# tools/tests/lib/setup.sh - Common test environment setup
# Source this at the beginning of every test file

# Get the test file's directory (where the test is located)
TEST_FILE_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"

# Calculate project root (3 levels up from tools/tests/lib/)
# tools/tests/lib/setup.sh -> tools/tests/ -> tools/ -> project-root/
PROJECT_ROOT="$(cd "$TEST_FILE_DIR/../../.." && pwd)"

# Change to project root
cd "$PROJECT_ROOT"

# Source pipeline libraries (from project root)
source .github/scripts/lib/logging.sh

# Source test libraries (using TEST_FILE_DIR to find lib)
source "$TEST_FILE_DIR/../lib/test_runner.sh"
source "$TEST_FILE_DIR/../lib/assertions.sh"
source "$TEST_FILE_DIR/../lib/timeout.sh"
source "$TEST_FILE_DIR/../lib/hooks.sh"
source "$TEST_FILE_DIR/../lib/isolation.sh"
source "$TEST_FILE_DIR/../lib/deps.sh"
source "$TEST_FILE_DIR/../lib/tags.sh"
source "$TEST_FILE_DIR/../lib/fixtures.sh"

# Export for use in tests
export PROJECT_ROOT
export TEST_FILE_DIR

# Optional: Set default test timeout
export TEST_TIMEOUT_SECONDS="${TEST_TIMEOUT_SECONDS:-30}"