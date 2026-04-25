#!/bin/bash
# tools/tests/e2e/run_dry_run.sh
# @tags: e2e

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "logging"
load_pipeline_lib "tags"

tag "run_dry_run.sh" "e2e"

run_tests() {
    echo "# Test: E2E Dry Run"
    
    local timestamp=$(date +%s)
    local test_post="posts/.test-e2e-${timestamp}.md"
    use_fixture "posts/with-table.md" "$test_post"
    
    export DRY_RUN=true
    export MANUAL_FILENAMES="$(basename "$test_post")"
    export DEVTO_TOKEN="mock"
    export HASHNODE_TOKEN="mock"
    export HASHNODE_PUBLICATION_ID="mock"
    export MEDIUM_TOKEN="mock"
    
    START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    START_TIMESTAMP=$(date +%s)
    
    output=$(./.github/scripts/main.sh 2>&1)
    exit_code=$?
    
    END_TIMESTAMP=$(date +%s)
    END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    DURATION=$((END_TIMESTAMP - START_TIMESTAMP))
    
    assert_equals "$exit_code" "0" "pipeline exit code"
    assert_contains "$output" "DRY RUN MODE" "dry run mode detected"
    assert_contains "$output" "Successfully published: 1" "published count"
    
    # Create JSON report in project root
    mkdir -p "$PROJECT_ROOT/.reports"
    REPORT_FILE="$PROJECT_ROOT/.reports/dry-run-$(date +%Y%m%d_%H%M%S).json"
    
    cat > "$REPORT_FILE" << EOF
{
  "metadata": {
    "timestamp": "$START_TIME",
    "mode": "dry-run",
    "execution_id": "run_$(date +%Y%m%d_%H%M%S)_$$"
  },
  "status": {
    "overall": "success",
    "exit_code": $exit_code,
    "published_count": 1
  },
  "execution": {
    "start_time": "$START_TIME",
    "end_time": "$END_TIME",
    "duration_seconds": $DURATION
  },
  "environment": {
    "repository": "${GITHUB_REPOSITORY:-local}",
    "branch": "${GITHUB_REF_NAME:-main}",
    "dry_run": true
  }
}
EOF
    
    echo "# Report saved: $REPORT_FILE"
}

run_tests
tap_exit_code