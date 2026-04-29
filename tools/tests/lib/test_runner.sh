#!/bin/bash
# tools/tests/lib/test_runner.sh - Test execution functions

# Global counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

# Run a single test file
run_test_file() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .sh)
    
    tlog_separator
    tlog_info "Test File: $test_name"
    tlog_separator
    
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
    SKIPPED_TESTS=$((SKIPPED_TESTS + (file_total - file_passed - file_failed)))
    
    # Print the output (TAP lines go to stdout)
    echo "$output"
    
    if [[ $file_failed -eq 0 ]]; then
        tlog_success "$test_name PASSED ($file_passed/$file_total tests)"
        return 0
    else
        tlog_error "$test_name FAILED ($file_failed/$file_total tests failed)"
        return 1
    fi
}

# Run a test suite (directory)
run_suite() {
    local suite_name="$1"
    local suite_dir="$2"
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    tlog_info "Suite: $suite_name"
    tlog_separator
    
    if [[ ! -d "$suite_dir" ]]; then
        tlog_warning "Suite directory not found: $suite_dir"
        ((FAILED_SUITES++))
        return 1
    fi
    
    local test_files=()
    
    if [[ -n "$TEST_FILTER" ]]; then
        local specific_file="$suite_dir/$TEST_FILTER"
        if [[ -f "$specific_file" ]]; then
            test_files+=("$specific_file")
        else
            tlog_warning "Test file not found: $specific_file"
            ((FAILED_SUITES++))
            return 1
        fi
    else
        while IFS= read -r file; do
            local base_name=$(basename "$file")
            if [[ "$base_name" != "run.sh" ]] && [[ "$base_name" != "setup.sh" ]]; then
                test_files+=("$file")
            fi
        done < <(find "$suite_dir" -maxdepth 1 -type f -name "*.sh" | sort)
    fi
    
    tlog_info "Found ${#test_files[@]} test file(s):"
    for f in "${test_files[@]}"; do
        tlog_info "  - $(basename "$f")"
    done
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        tlog_warning "No test files found in $suite_dir"
        ((FAILED_SUITES++))
        return 1
    fi
    
    local suite_passed=0
    local suite_failed=0
    
    for test_file in "${test_files[@]}"; do
        if run_test_file "$test_file"; then
            ((suite_passed++))
        else
            ((suite_failed++))
        fi
        tlog_blank
    done
    
    tlog_info "Suite $suite_name: $suite_passed passed, $suite_failed failed"
    
    if [[ $suite_failed -gt 0 ]]; then
        ((FAILED_SUITES++))
        return 1
    else
        ((PASSED_SUITES++))
        return 0
    fi
}

# Print final summary
print_summary() {
    tlog_blank
    tlog_decoration
    tlog_info " Final Summary"
    tlog_decoration
    tlog_info "Suites: $PASSED_SUITES passed, $FAILED_SUITES failed"
    tlog_info "Tests:  $PASSED_TESTS passed, $FAILED_TESTS failed, $SKIPPED_TESTS skipped"
    tlog_info "Total:  $TOTAL_TESTS tests run"
    tlog_blank
    
    if [[ $FAILED_TESTS -eq 0 ]] && [[ $FAILED_SUITES -eq 0 ]]; then
        tlog_success "All tests passed!"
    else
        if [[ $FAILED_SUITES -gt 0 ]]; then
            tlog_error "$FAILED_SUITES suite(s) failed"
        fi
        if [[ $FAILED_TESTS -gt 0 ]]; then
            tlog_error "$FAILED_TESTS test(s) failed"
        fi
    fi
}