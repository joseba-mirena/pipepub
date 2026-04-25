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
    export DRY_RUN=true
    export DEVTO_TOKEN="mock"
    export HASHNODE_TOKEN="mock"
    export HASHNODE_PUBLICATION_ID="mock"
    export MEDIUM_TOKEN="mock"
    
    echo "# Test 1: Single publisher (devto only)"
    
    use_fixture "posts/single-publisher.md" "posts/test-devto-only.md"
    
    export MANUAL_FILENAMES="test-devto-only.md"
    
    output=$(./.github/scripts/main.sh 2>&1)
    exit_code=$?
    
    assert_equals "$exit_code" "0" "pipeline exit code"
    assert_contains "$output" "Publishing to Dev.to" "should publish to Dev.to"
    assert_not_contains "$output" "Publishing to Hashnode" "should NOT publish to Hashnode"
    assert_not_contains "$output" "Publishing to Medium" "should NOT publish to Medium"
    
    echo ""
    echo "# Test 2: Multiple publishers (devto, hashnode)"
    
    use_fixture "posts/multi-publisher.md" "posts/test-multi-publisher.md"
    
    export MANUAL_FILENAMES="test-multi-publisher.md"
    
    output=$(./.github/scripts/main.sh 2>&1)
    exit_code=$?
    
    assert_equals "$exit_code" "0" "pipeline exit code"
    assert_contains "$output" "Publishing to Dev.to" "should publish to Dev.to"
    assert_contains "$output" "Publishing to Hashnode" "should publish to Hashnode"
    assert_not_contains "$output" "Publishing to Medium" "should NOT publish to Medium"
    
    echo ""
    echo "# Test 3: Gist disabled (no table conversion)"
    
    use_fixture "posts/gist-false.md" "posts/test-gist-disabled.md"
    
    export MANUAL_FILENAMES="test-gist-disabled.md"
    
    output=$(./.github/scripts/main.sh 2>&1)
    exit_code=$?
    
    assert_equals "$exit_code" "0" "pipeline exit code"
    assert_contains "$output" "Gist tables disabled" "gist tables should be disabled"
}

run_tests
tap_exit_code