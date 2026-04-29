#!/bin/bash
# tools/tests/integration/test_gist_integration.sh
# @tags: integration

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "logging"
load_pipeline_lib "tags"

tag "test_gist_integration.sh" "integration"

run_tests() {
    tlog_section "Test: Gist Integration"
    
    # Setup test environment with all mocks
    setup_test_environment
    
    # Create test post from fixture with gist enabled
    use_fixture "posts/with-multiple-tables.md" "posts/.test-gist.md"
    
    export MANUAL_FILENAMES=".test-gist.md"
    
    output=$(./.github/scripts/main.sh 2>&1)
    exit_code=$?
    
    # Assertion using assert_equals
    assert_equals "$exit_code" "0" "pipeline exit code"
}

# Run in subshell to prevent environment pollution
(
    run_tests
)