#!/bin/bash
# tools/tests/lib/assertions.sh - Assertion functions with TAP output

# Global counters (will be managed by tap.sh)
[[ -z "$TOTAL_TESTS" ]] && TOTAL_TESTS=0
[[ -z "$PASSED_TESTS" ]] && PASSED_TESTS=0
[[ -z "$FAILED_TESTS" ]] && FAILED_TESTS=0
[[ -z "$SKIPPED_TESTS" ]] && SKIPPED_TESTS=0

# Assert two values are equal
assert_equals() {
    local actual="$1"
    local expected="$2"
    local message="${3:-should equal}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "$actual" == "$expected" ]]; then
        echo "ok $TOTAL_TESTS - $message"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo "not ok $TOTAL_TESTS - $message"
        echo "#   expected: '$expected'"
        echo "#   got:      '$actual'"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Assert string contains substring
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-should contain '$needle'}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "ok $TOTAL_TESTS - $message"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo "not ok $TOTAL_TESTS - $message"
        echo "#   expected to contain: '$needle'"
        echo "#   got: '$haystack'"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Assert string does NOT contain substring
assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-should not contain '$needle'}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "$haystack" != *"$needle"* ]]; then
        echo "ok $TOTAL_TESTS - $message"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo "not ok $TOTAL_TESTS - $message"
        echo "#   expected not to contain: '$needle'"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Assert command succeeds (exit code 0)
assert_success() {
    local cmd="$1"
    local message="${2:-command should succeed}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if eval "$cmd" >/dev/null 2>&1; then
        echo "ok $TOTAL_TESTS - $message"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo "not ok $TOTAL_TESTS - $message"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Assert command fails (non-zero exit code)
assert_failure() {
    local cmd="$1"
    local message="${2:-command should fail}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if ! eval "$cmd" >/dev/null 2>&1; then
        echo "ok $TOTAL_TESTS - $message"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo "not ok $TOTAL_TESTS - $message"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Assert file exists
assert_file_exists() {
    local file="$1"
    local message="${2:-file '$file' should exist}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ -f "$file" ]]; then
        echo "ok $TOTAL_TESTS - $message"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo "not ok $TOTAL_TESTS - $message"
        echo "#   file not found: $file"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Assert exit code matches
assert_exit_code() {
    local expected="$1"
    shift
    local message="${2:-exit code should be $expected}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    eval "$@"
    local actual=$?
    
    if [[ $actual -eq $expected ]]; then
        echo "ok $TOTAL_TESTS - $message"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo "not ok $TOTAL_TESTS - $message"
        echo "#   expected: $expected"
        echo "#   got: $actual"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Skip test with reason
skip_test() {
    local reason="$1"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo "ok $TOTAL_TESTS - SKIP: $reason"
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    return 0
}