#!/bin/bash
# tools/tests/integration/test_multipost.sh
# @tags: integration

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "logging"

tag "test_multipost.sh" "integration"

run_tests() {
    echo "# Test: Multi-post handling"
    
    local test_posts=()
    
    for i in 1 2 3; do
        local post_file=$(create_test_post "basic.md" "Test Post ${i}" "test-multipost-${i}")
        test_posts+=("$post_file")
    done
    
    local filenames=""
    for post in "${test_posts[@]}"; do
        filenames="$filenames $(basename "$post")"
    done
    filenames="${filenames# }"
    
    export DRY_RUN=true
    export MANUAL_FILENAMES="$filenames"
    export DEVTO_TOKEN="mock"
    export HASHNODE_TOKEN="mock"
    export HASHNODE_PUBLICATION_ID="mock"
    export MEDIUM_TOKEN="mock"
    
    output=$(./.github/scripts/main.sh 2>&1)
    exit_code=$?
    
    assert_equals "$exit_code" "0" "pipeline exit code"
    assert_contains "$output" "Found 3 file(s) to process" "multi-post detection"
}

run_tests
tap_exit_code