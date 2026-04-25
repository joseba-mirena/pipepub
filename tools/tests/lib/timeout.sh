#!/bin/bash
# tools/tests/lib/timeout.sh - Test timeout protection

run_with_timeout() {
    local timeout_sec="${1:-30}"
    local cmd="$2"
    local timeout_msg="${3:-Test exceeded ${timeout_sec}s timeout}"
    
    # Use timeout command if available
    if command -v timeout &>/dev/null; then
        timeout "$timeout_sec" bash -c "$cmd"
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            echo "TIMEOUT: $timeout_msg" >&2
        fi
        return $exit_code
    else
        # Fallback: direct execution
        eval "$cmd"
        return $?
    fi
}

run_test_with_timeout() {
    local test_func="$1"
    local timeout_sec="${2:-30}"
    run_with_timeout "$timeout_sec" "$test_func" "Test function $test_func"
}