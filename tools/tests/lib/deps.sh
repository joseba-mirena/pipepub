#!/bin/bash
# tools/tests/lib/deps.sh - Test dependency management

# Track test dependencies
declare -A TEST_DEPENDENCIES
declare -A TEST_STATUS  # "passed", "failed", "skipped"

# Register dependency
depends_on() {
    local test_name="$1"
    local dependency="$2"
    TEST_DEPENDENCIES["$test_name"]="$dependency"
}

# Check if dependency passed
check_dependency() {
    local test_name="$1"
    local dep="${TEST_DEPENDENCIES[$test_name]}"
    
    if [[ -z "$dep" ]]; then
        return 0  # No dependency
    fi
    
    if [[ "${TEST_STATUS[$dep]}" == "passed" ]]; then
        return 0
    elif [[ "${TEST_STATUS[$dep]}" == "failed" ]]; then
        echo "# Dependency '$dep' failed, skipping '$test_name'" >&2
        return 1
    elif [[ "${TEST_STATUS[$dep]}" == "skipped" ]]; then
        echo "# Dependency '$dep' was skipped, skipping '$test_name'" >&2
        return 1
    fi
    
    return 1
}

# Mark test result
mark_test_result() {
    local test_name="$1"
    local result="$2"  # "passed", "failed", "skipped"
    TEST_STATUS["$test_name"]="$result"
}

# Run test with dependency check
run_with_deps() {
    local test_name="$1"
    local test_func="$2"
    
    if ! check_dependency "$test_name"; then
        echo "ok $TOTAL_TESTS - SKIP: $test_name (dependency failed)"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
        mark_test_result "$test_name" "skipped"
        return 0
    fi
    
    if "$test_func"; then
        mark_test_result "$test_name" "passed"
        return 0
    else
        mark_test_result "$test_name" "failed"
        return 1
    fi
}

# Clear dependencies (for test isolation)
clear_dependencies() {
    TEST_DEPENDENCIES=()
    TEST_STATUS=()
}