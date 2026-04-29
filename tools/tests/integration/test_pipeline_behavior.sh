#!/bin/bash
# tools/tests/integration/test_pipeline_behavior.sh
# @tags: integration

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "logging"
load_pipeline_lib "tags"

tag "test_pipeline_behavior.sh" "integration"

run_tests() {
    # Setup test environment with all mocks
    setup_test_environment
    
    tlog_section "Test 1: Single publisher (devto only)"
    
    use_fixture "posts/single-publisher.md" "posts/test-devto-only.md"
    
    export MANUAL_FILENAMES="test-devto-only.md"
    
    output=$(./.github/scripts/main.sh 2>&1)
    exit_code=$?
    
    # Assertions using assert_* functions
    assert_equals "$exit_code" "0" "pipeline exit code"
    assert_contains "$output" "Publishing to DEV.to" "should publish to DEV.to"
    assert_not_contains "$output" "Publishing to Hashnode" "should NOT publish to Hashnode"
    assert_not_contains "$output" "Publishing to Medium" "should NOT publish to Medium"
    
    tlog_section "Test 2: Multiple publishers (devto, hashnode)"
    
    use_fixture "posts/multi-publisher.md" "posts/test-multi-publisher.md"
    
    export MANUAL_FILENAMES="test-multi-publisher.md"
    
    output=$(./.github/scripts/main.sh 2>&1)
    exit_code=$?
    
    assert_equals "$exit_code" "0" "pipeline exit code"
    assert_contains "$output" "Publishing to DEV.to" "should publish to DEV.to"
    assert_contains "$output" "Publishing to Hashnode" "should publish to Hashnode"
    assert_not_contains "$output" "Publishing to Medium" "should NOT publish to Medium"
    
    tlog_section "Test 3: Gist disabled (no table conversion)"
    
    use_fixture "posts/gist-false.md" "posts/test-gist-disabled.md"
    
    export MANUAL_FILENAMES="test-gist-disabled.md"
    
    output=$(./.github/scripts/main.sh 2>&1)
    exit_code=$?
    
    assert_equals "$exit_code" "0" "pipeline exit code"
    assert_contains "$output" "Gist tables disabled" "gist tables should be disabled"
}

# Run in subshell to prevent environment pollution
(
    run_tests
)