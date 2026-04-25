#!/bin/bash
# tools/tests/integration/test_gist_integration.sh
# @tags: integration

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "logging"
load_pipeline_lib "tags"

tag "test_gist_integration.sh" "integration"

run_tests() {
    echo "# Test: Gist Integration"
    
    # Create test post from fixture with gist enabled
    use_fixture "posts/with-multiple-tables.md" "posts/.test-gist.md"
    
    export DRY_RUN=true
    export MANUAL_FILENAMES=".test-gist.md"
    export DEVTO_TOKEN="mock"
    export HASHNODE_TOKEN="mock"
    export HASHNODE_PUBLICATION_ID="mock"
    export MEDIUM_TOKEN="mock"
    export GH_PAT_GIST_TOKEN="mock_token"
    
    output=$(./.github/scripts/main.sh 2>&1)
    exit_code=$?
    
    assert_equals "$exit_code" "0" "pipeline exit code"
}

run_tests
tap_exit_code