#!/bin/bash
# tools/tests/lib/assertions.sh - Full assertion library with TAP output
# OUTPUT: Only TAP lines (ok/not ok) to stdout.
# DIAGNOSTICS: Go to stderr via echo with '# ' prefix.
# NOTE: Exit codes are handled by the test runner, not by assertions.

# Internal TAP counter (per test file, isolated by subshell)
_TAP_COUNTER=0

_tap_log() {
    echo "$@"
}

_tap_diag() {
    echo "# $*" >&2
}

# ============================================================================
# Equality Assertions
# ============================================================================

# Assert two values are equal
assert_equals() {
    local actual="$1"
    local expected="$2"
    local message="${3:-should equal}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ "$actual" == "$expected" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected: '$expected'"
        _tap_diag "Got:      '$actual'"
        return 1
    fi
}

# Assert two values are not equal
assert_not_equals() {
    local actual="$1"
    local expected="$2"
    local message="${3:-should not equal}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ "$actual" != "$expected" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected not equal to: '$expected'"
        _tap_diag "Got: '$actual'"
        return 1
    fi
}

# ============================================================================
# String Assertions
# ============================================================================

# Assert string contains substring
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-should contain '$needle'}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ "$haystack" == *"$needle"* ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected to contain: '$needle'"
        _tap_diag "Got: '$haystack'"
        return 1
    fi
}

# Assert string does NOT contain substring
assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-should not contain '$needle'}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ "$haystack" != *"$needle"* ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected NOT to contain: '$needle'"
        return 1
    fi
}

# Assert string starts with prefix
assert_starts_with() {
    local string="$1"
    local prefix="$2"
    local message="${3:-should start with '$prefix'}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ "$string" == "$prefix"* ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected to start with: '$prefix'"
        _tap_diag "Got: '$string'"
        return 1
    fi
}

# Assert string ends with suffix
assert_ends_with() {
    local string="$1"
    local suffix="$2"
    local message="${3:-should end with '$suffix'}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ "$string" == *"$suffix" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected to end with: '$suffix'"
        _tap_diag "Got: '$string'"
        return 1
    fi
}

# Assert string matches regex
assert_matches() {
    local string="$1"
    local pattern="$2"
    local message="${3:-should match pattern '$pattern'}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ "$string" =~ $pattern ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected to match: '$pattern'"
        _tap_diag "Got: '$string'"
        return 1
    fi
}

# ============================================================================
# Numeric Assertions
# ============================================================================

# Assert numeric value is greater than
assert_greater_than() {
    local actual="$1"
    local expected="$2"
    local message="${3:-should be > $expected}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if (( actual > expected )); then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected: > $expected"
        _tap_diag "Got: $actual"
        return 1
    fi
}

# Assert numeric value is less than
assert_less_than() {
    local actual="$1"
    local expected="$2"
    local message="${3:-should be < $expected}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if (( actual < expected )); then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected: < $expected"
        _tap_diag "Got: $actual"
        return 1
    fi
}

# ============================================================================
# File System Assertions
# ============================================================================

# Assert file exists
assert_file_exists() {
    local file="$1"
    local message="${2:-file '$file' should exist}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ -f "$file" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "File not found: $file"
        return 1
    fi
}

# Assert file does not exist
assert_file_not_exists() {
    local file="$1"
    local message="${2:-file '$file' should not exist}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ ! -f "$file" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "File exists: $file"
        return 1
    fi
}

# Assert directory exists
assert_dir_exists() {
    local dir="$1"
    local message="${2:-directory '$dir' should exist}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ -d "$dir" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Directory not found: $dir"
        return 1
    fi
}

# Assert file is readable
assert_file_readable() {
    local file="$1"
    local message="${2:-file '$file' should be readable}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ -r "$file" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "File not readable: $file"
        return 1
    fi
}

# Assert file is writable
assert_file_writable() {
    local file="$1"
    local message="${2:-file '$file' should be writable}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ -w "$file" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "File not writable: $file"
        return 1
    fi
}

# Assert file is executable
assert_file_executable() {
    local file="$1"
    local message="${2:-file '$file' should be executable}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ -x "$file" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "File not executable: $file"
        return 1
    fi
}

# ============================================================================
# Command and Exit Code Assertions
# ============================================================================

# Assert command succeeds (exit code 0)
assert_success() {
    local cmd="$1"
    local message="${2:-command should succeed}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if eval "$cmd" >/dev/null 2>&1; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        return 1
    fi
}

# Assert command fails (non-zero exit code)
assert_failure() {
    local cmd="$1"
    local message="${2:-command should fail}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if ! eval "$cmd" >/dev/null 2>&1; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        return 1
    fi
}

# Assert command exits with specific code
assert_exit_code() {
    local expected="$1"
    shift
    local cmd="$*"
    local message="${3:-exit code should be $expected}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    eval "$cmd" >/dev/null 2>&1
    local actual=$?
    
    if [[ $actual -eq $expected ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected exit code: $expected"
        _tap_diag "Got: $actual"
        return 1
    fi
}

# ============================================================================
# Output Assertions
# ============================================================================

# Assert command output equals expected
assert_output() {
    local expected="$1"
    shift
    local cmd="$*"
    local message="${3:-output should equal expected}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    local output
    output=$(eval "$cmd" 2>&1)
    
    if [[ "$output" == "$expected" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected output: '$expected'"
        _tap_diag "Got: '$output'"
        return 1
    fi
}

# Assert command output contains substring
assert_output_contains() {
    local needle="$1"
    shift
    local cmd="$*"
    local message="${3:-output should contain '$needle'}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    local output
    output=$(eval "$cmd" 2>&1)
    
    if [[ "$output" == *"$needle"* ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Expected to contain: '$needle'"
        _tap_diag "Got: '$output'"
        return 1
    fi
}

# ============================================================================
# Variable Assertions
# ============================================================================

# Assert variable is set (non-empty)
assert_set() {
    local var_name="$1"
    local value="${!var_name}"
    local message="${2:-variable '$var_name' should be set}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ -n "$value" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Variable '$var_name' is not set"
        return 1
    fi
}

# Assert variable is unset (empty)
assert_unset() {
    local var_name="$1"
    local value="${!var_name}"
    local message="${2:-variable '$var_name' should be unset}"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    
    if [[ -z "$value" ]]; then
        _tap_log "ok $_TAP_COUNTER - $message"
        return 0
    else
        _tap_log "not ok $_TAP_COUNTER - $message"
        _tap_diag "Variable '$var_name' is set to '$value'"
        return 1
    fi
}

# ============================================================================
# Utility Functions
# ============================================================================

# Skip test with reason
skip_test() {
    local reason="$1"
    
    _TAP_COUNTER=$((_TAP_COUNTER + 1))
    _tap_log "ok $_TAP_COUNTER - SKIP: $reason"
    return 0
}

# Reset counter (for test file isolation)
assert_reset() {
    _TAP_COUNTER=0
}