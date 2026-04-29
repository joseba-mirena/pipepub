#!/bin/bash
# tools/tests/lib/fixtures.sh - Fixture and snapshot management
# NOTE: This file depends on assertions.sh being sourced first
# (assert_* and skip_test functions must be available)

# Get project root
get_project_root() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$script_dir/../../.." && pwd
}

PROJECT_ROOT=$(get_project_root)
FIXTURES_DIR="$PROJECT_ROOT/tools/tests/fixtures"
SNAPSHOTS_DIR="$FIXTURES_DIR/snapshots"

# ============================================================================
# Fixture Loading
# ============================================================================

# Get fixture path
get_fixture() {
    local category="$1"
    local name="$2"
    local path="$FIXTURES_DIR/$category/$name"
    
    if [[ ! -f "$path" ]]; then
        tlog_error "Fixture not found: $path"
        return 1
    fi
    echo "$path"
}

# ============================================================================
# Snapshot Management
# ============================================================================

# Get snapshot path
get_snapshot() {
    local category="$1"
    local name="$2"
    local path="$SNAPSHOTS_DIR/$category/$name"
    echo "$path"
}

# Assert against snapshot with auto-update support
assert_snapshot() {
    local actual="$1"
    local snapshot_path="$2"
    local message="${3:-should match snapshot}"
    
    local actual_normalized=""
    if echo "$actual" | jq . >/dev/null 2>&1; then
        actual_normalized=$(echo "$actual" | jq -cS . 2>/dev/null)
    else
        actual_normalized=$(echo "$actual" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    fi
    
    if [[ "${UPDATE_SNAPSHOTS:-false}" == "true" ]]; then
        mkdir -p "$(dirname "$snapshot_path")"
        if echo "$actual" | jq . >/dev/null 2>&1; then
            echo "$actual" | jq -S . > "$snapshot_path"
        else
            echo "$actual" > "$snapshot_path"
        fi
        tlog_info "📸 Snapshot updated: $snapshot_path"
        return 0
    fi
    
    if [[ ! -f "$snapshot_path" ]]; then
        mkdir -p "$(dirname "$snapshot_path")"
        if echo "$actual" | jq . >/dev/null 2>&1; then
            echo "$actual" | jq -S . > "$snapshot_path"
        else
            echo "$actual" > "$snapshot_path"
        fi
        tlog_info "📸 Snapshot created: $snapshot_path"
        skip_test "$message (snapshot created)"
        return 0
    fi
    
    local expected=$(cat "$snapshot_path")
    local expected_normalized=""
    
    if echo "$expected" | jq . >/dev/null 2>&1; then
        expected_normalized=$(echo "$expected" | jq -cS . 2>/dev/null)
    else
        expected_normalized=$(echo "$expected" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    fi
    
    # Use assert_equals from assertions.sh
    assert_equals "$actual_normalized" "$expected_normalized" "$message"
}

# Assert JSON response against snapshot
assert_json_snapshot() {
    local actual_json="$1"
    local snapshot_name="$2"
    local message="${3:-JSON should match snapshot}"
    
    local snapshot_path=$(get_snapshot "json" "$snapshot_name")
    assert_snapshot "$actual_json" "$snapshot_path" "$message"
}