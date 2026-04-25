#!/bin/bash
# tools/tests/lib/fixtures.sh - Fixture and snapshot management

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
        echo "ERROR: Fixture not found: $path" >&2
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
        echo "# 📸 Snapshot updated: $snapshot_path"
        return 0
    fi
    
    if [[ ! -f "$snapshot_path" ]]; then
        mkdir -p "$(dirname "$snapshot_path")"
        if echo "$actual" | jq . >/dev/null 2>&1; then
            echo "$actual" | jq -S . > "$snapshot_path"
        else
            echo "$actual" > "$snapshot_path"
        fi
        echo "# 📸 Snapshot created: $snapshot_path"
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        echo "ok $TOTAL_TESTS - SKIP: $message (snapshot created)"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
        return 0
    fi
    
    local expected=$(cat "$snapshot_path")
    local expected_normalized=""
    
    if echo "$expected" | jq . >/dev/null 2>&1; then
        expected_normalized=$(echo "$expected" | jq -cS . 2>/dev/null)
    else
        expected_normalized=$(echo "$expected" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "$actual_normalized" == "$expected_normalized" ]]; then
        echo "ok $TOTAL_TESTS - $message"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo "not ok $TOTAL_TESTS - $message"
        echo "#   Snapshot: $snapshot_path"
        echo "#   Diff:"
        diff -u <(echo "$expected_normalized") <(echo "$actual_normalized") | head -20 | sed 's/^/#     /'
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Assert JSON response against snapshot
assert_json_snapshot() {
    local actual_json="$1"
    local snapshot_name="$2"
    local message="${3:-JSON should match snapshot}"
    
    local snapshot_path=$(get_snapshot "json" "$snapshot_name")
    assert_snapshot "$actual_json" "$snapshot_path" "$message"
}