#!/bin/bash
# tools/tests/lib/tap.sh - TAP output and test counting

# Global counters (use declare -g for global scope)
declare -g TOTAL_TESTS=0
declare -g PASSED_TESTS=0
declare -g FAILED_TESTS=0
declare -g SKIPPED_TESTS=0

# Start TAP plan
tap_plan() {
    local total="$1"
    echo "TAP version 13"
    echo "1..$total"
}

# End TAP and print summary
tap_finish() {
    echo ""
    echo "# =================================="
    echo "# Test Summary"
    echo "# =================================="
    echo "# Total:  $TOTAL_TESTS"
    echo "# Passed: $PASSED_TESTS"
    echo "# Failed: $FAILED_TESTS"
    echo "# Skipped: $SKIPPED_TESTS"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo "# ✅ All tests passed!"
    else
        echo "# ❌ $FAILED_TESTS test(s) failed"
    fi
}

# Get final exit code (0 if all passed, 1 otherwise)
tap_exit_code() {
    if [[ $FAILED_TESTS -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Reset counters (for test suites)
tap_reset() {
    TOTAL_TESTS=0
    PASSED_TESTS=0
    FAILED_TESTS=0
    SKIPPED_TESTS=0
}

# Export counters for use in assertions
export TOTAL_TESTS
export PASSED_TESTS
export FAILED_TESTS
export SKIPPED_TESTS