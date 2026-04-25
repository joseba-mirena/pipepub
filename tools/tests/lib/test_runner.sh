#!/bin/bash
# tools/tests/lib/test_runner.sh - Main test runner with TAP output

# Source all test libraries
TEST_RUNNER_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${_TAP_SH_LOADED:-}" ]] && [[ -f "$TEST_RUNNER_LIB_DIR/tap.sh" ]]; then
    source "$TEST_RUNNER_LIB_DIR/tap.sh"
fi

if [[ -z "${_ASSERTIONS_SH_LOADED:-}" ]] && [[ -f "$TEST_RUNNER_LIB_DIR/assertions.sh" ]]; then
    source "$TEST_RUNNER_LIB_DIR/assertions.sh"
fi

if [[ -z "${_TIMEOUT_SH_LOADED:-}" ]] && [[ -f "$TEST_RUNNER_LIB_DIR/timeout.sh" ]]; then
    source "$TEST_RUNNER_LIB_DIR/timeout.sh"
fi

if [[ -z "${_DEPS_SH_LOADED:-}" ]] && [[ -f "$TEST_RUNNER_LIB_DIR/deps.sh" ]]; then
    source "$TEST_RUNNER_LIB_DIR/deps.sh"
fi

if [[ -z "${_TAGS_SH_LOADED:-}" ]] && [[ -f "$TEST_RUNNER_LIB_DIR/tags.sh" ]]; then
    source "$TEST_RUNNER_LIB_DIR/tags.sh"
fi

if [[ -z "${_FIXTURES_SH_LOADED:-}" ]] && [[ -f "$TEST_RUNNER_LIB_DIR/fixtures.sh" ]]; then
    source "$TEST_RUNNER_LIB_DIR/fixtures.sh"
fi

# Global test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

reset_test_state() {
    TOTAL_TESTS=0
    PASSED_TESTS=0
    FAILED_TESTS=0
    SKIPPED_TESTS=0
    clear_dependencies
}

# Run a test file and count its tests by parsing TAP output
run_test_file() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .sh)
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "# Test File: $test_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Run test file in subshell to capture output
    local output
    output=$(source "$test_file" 2>&1)
    local test_exit_code=$?
    
    # Parse TAP output to count tests
    local file_total=0
    local file_passed=0
    local file_failed=0
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^ok\ ([0-9]+) ]]; then
            ((file_total++))
            ((file_passed++))
        elif [[ "$line" =~ ^not\ ok\ ([0-9]+) ]]; then
            ((file_total++))
            ((file_failed++))
        fi
    done <<< "$output"
    
    # Update global counters
    TOTAL_TESTS=$((TOTAL_TESTS + file_total))
    PASSED_TESTS=$((PASSED_TESTS + file_passed))
    FAILED_TESTS=$((FAILED_TESTS + file_failed))
    
    # Print the output
    echo "$output"
    
    if [[ $test_exit_code -eq 0 ]]; then
        echo "# ✅ $test_name PASSED ($file_passed/$file_total tests)"
        return 0
    else
        echo "# ❌ $test_name FAILED ($file_failed/$file_total tests failed)"
        return 1
    fi
}

# Run a test suite (directory)
run_test_suite() {
    local suite_name="$1"
    local suite_dir="$2"
    local filter="${3:-}"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "# Suite: $suite_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ ! -d "$suite_dir" ]]; then
        echo "# WARNING: Suite directory not found: $suite_dir"
        return 0
    fi
    
    local test_files=()
    
    if [[ -n "$filter" ]]; then
        local specific_file="$suite_dir/$filter"
        if [[ -f "$specific_file" ]]; then
            test_files+=("$specific_file")
        else
            echo "# WARNING: Test file not found: $specific_file"
            return 0
        fi
    else
        while IFS= read -r file; do
            local base_name=$(basename "$file")
            if [[ "$base_name" != "run_all_tests.sh" ]] && [[ "$base_name" != "setup.sh" ]]; then
                test_files+=("$file")
            fi
        done < <(find "$suite_dir" -maxdepth 1 -type f -name "*.sh" | sort)
    fi
    
    echo "# Found ${#test_files[@]} test file(s):"
    for f in "${test_files[@]}"; do
        echo "#   - $(basename "$f")"
    done
    echo ""
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        echo "# No test files found in $suite_dir"
        return 0
    fi
    
    local suite_passed=0
    local suite_failed=0
    
    for test_file in "${test_files[@]}"; do
        if run_test_file "$test_file"; then
            ((suite_passed++))
        else
            ((suite_failed++))
        fi
        echo ""
    done
    
    echo "# Suite $suite_name: $suite_passed passed, $suite_failed failed"
    
    return 0
}

# Run all test suites
run_all_suites() {
    local tests_base_dir="${1:-$TEST_RUNNER_LIB_DIR/..}"
    
    local suites_passed=0
    local suites_failed=0
    
    local grand_total=0
    local grand_passed=0
    local grand_failed=0
    local grand_skipped=0
    
    if [[ ! -d "$tests_base_dir" ]]; then
        echo "# ERROR: Test base directory not found: $tests_base_dir"
        return 1
    fi
    
    echo "# Test base directory: $tests_base_dir"
    
    # Run unit tests
    local unit_dir="$tests_base_dir/unit"
    if [[ -d "$unit_dir" ]]; then
        local before_total=$TOTAL_TESTS
        local before_passed=$PASSED_TESTS
        local before_failed=$FAILED_TESTS
        local before_skipped=$SKIPPED_TESTS
        
        run_test_suite "Unit Tests" "$unit_dir" "${TEST_FILTER:-}"
        
        if [[ $? -eq 0 ]]; then
            ((suites_passed++))
        else
            ((suites_failed++))
        fi
        
        grand_total=$((grand_total + (TOTAL_TESTS - before_total)))
        grand_passed=$((grand_passed + (PASSED_TESTS - before_passed)))
        grand_failed=$((grand_failed + (FAILED_TESTS - before_failed)))
        grand_skipped=$((grand_skipped + (SKIPPED_TESTS - before_skipped)))
    fi
    
    # Run integration tests
    local integration_dir="$tests_base_dir/integration"
    if [[ -d "$integration_dir" ]]; then
        local before_total=$TOTAL_TESTS
        local before_passed=$PASSED_TESTS
        local before_failed=$FAILED_TESTS
        local before_skipped=$SKIPPED_TESTS
        
        run_test_suite "Integration Tests" "$integration_dir" "${TEST_FILTER:-}"
        
        if [[ $? -eq 0 ]]; then
            ((suites_passed++))
        else
            ((suites_failed++))
        fi
        
        grand_total=$((grand_total + (TOTAL_TESTS - before_total)))
        grand_passed=$((grand_passed + (PASSED_TESTS - before_passed)))
        grand_failed=$((grand_failed + (FAILED_TESTS - before_failed)))
        grand_skipped=$((grand_skipped + (SKIPPED_TESTS - before_skipped)))
    fi
    
    # Run E2E tests
    local e2e_dir="$tests_base_dir/e2e"
    if [[ -d "$e2e_dir" ]]; then
        local before_total=$TOTAL_TESTS
        local before_passed=$PASSED_TESTS
        local before_failed=$FAILED_TESTS
        local before_skipped=$SKIPPED_TESTS
        
        run_test_suite "E2E Tests" "$e2e_dir" "${TEST_FILTER:-}"
        
        if [[ $? -eq 0 ]]; then
            ((suites_passed++))
        else
            ((suites_failed++))
        fi
        
        grand_total=$((grand_total + (TOTAL_TESTS - before_total)))
        grand_passed=$((grand_passed + (PASSED_TESTS - before_passed)))
        grand_failed=$((grand_failed + (FAILED_TESTS - before_failed)))
        grand_skipped=$((grand_skipped + (SKIPPED_TESTS - before_skipped)))
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "# Final Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "# Suites: $suites_passed passed, $suites_failed failed"
    echo "# Tests:  $grand_passed passed, $grand_failed failed, $grand_skipped skipped"
    echo "# Total:  $grand_total tests run"
    
    if [[ $grand_failed -eq 0 ]]; then
        echo "# ✅ All tests passed!"
        return 0
    else
        echo "# ❌ $grand_failed test(s) failed"
        return 1
    fi
}

# Export functions for use in test files
export -f reset_test_state run_test_file run_test_suite run_all_suites