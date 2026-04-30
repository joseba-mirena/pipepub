#!/bin/bash
# tools/tests/dev/test_ghost_dev.sh
# @tags: dev ghost

# Source common setup
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "logging"
load_pipeline_lib "tags"

run_tests() {
    tlog_section "Test: Ghost Dev Service Integration"
    
    # Setup test environment with all mocks
    setup_test_environment
    
    # Create test post with ghost in publisher list
    cat > posts/test-ghost.md << 'EOF'
---
title: Ghost Dev Test
publisher: ghost
status: draft
gist: false
tags: test, ghost, dev
---

## Test Content

This is a test for Ghost dev service.

- Markdown works
- Tags are processed
- Draft mode
EOF
    
    export MANUAL_FILENAMES="test-ghost.md"
    
    output=$(./.github/scripts/main.sh 2>&1)
    exit_code=$?
    
    assert_equals "$exit_code" "0" "pipeline exit code"
    assert_contains "$output" "Ghost" "should mention Ghost service"
}

# Run in subshell to prevent environment pollution
(
    run_tests
)