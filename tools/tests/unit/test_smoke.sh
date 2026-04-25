#!/bin/bash
# tools/tests/unit/test_smoke.sh
# @tags: unit fast smoke

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

tag "test_smoke.sh" "unit fast smoke"

run_tests() {
    echo "# Test: Framework smoke test"
    
    assert_equals "1" "1" "basic equality works"
    assert_contains "hello world" "world" "contains works"
    assert_success "true" "true command succeeds"
    
    echo ""
    echo "# Test: Test environment is correct"
    echo "Logger is enabled"

    # Note: In isolation, PROJECT_ROOT is the temp directory
    # So this assertion will fail because logging.sh is in PROJECT_ROOT/.github/
    # But the temp directory has a copy of .github, so it should work
    assert_file_exists ".github/scripts/lib/logging.sh" "logging.sh exists"
    
    echo ""
    echo "# Test: Helper functions work"
    
    if load_pipeline_lib "logging" 2>/dev/null; then
        assert_success "true" "load_pipeline_lib works"
    else
        assert_equals "loaded" "failed" "load_pipeline_lib should load logging"
    fi
}

run_tests
tap_exit_code