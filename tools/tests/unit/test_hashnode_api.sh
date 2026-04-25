#!/bin/bash
# tools/tests/unit/test_hashnode_api.sh
# @tags: unit

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "tags"

tag "test_hashnode_api.sh" "unit"

run_tests() {
    echo "# Test: Hashnode Payload Generation"
    
    local test_title="Test Article"
    local test_subtitle="This is a test subtitle"
    local test_tags="delete me, auto, test, draft"
    
    declare -a parsed_tags=()
    parse_tags "$test_tags" parsed_tags
    
    declare -a hashnode_tags=()
    for tag in "${parsed_tags[@]}"; do
        if [[ ${#hashnode_tags[@]} -ge 5 ]]; then
            break
        fi
        cleaned=$(echo "$tag" | sed 's/[-_]//g' | sed 's/[^a-z0-9]//g')
        if [[ -n "$cleaned" ]]; then
            hashnode_tags+=("{\"name\":\"$cleaned\",\"slug\":\"$cleaned\"}")
        fi
    done
    
    local tags_json="[$(IFS=,; echo "${hashnode_tags[*]}")]"
    
    local actual_payload=$(jq -n \
        --arg title "$test_title" \
        --arg subtitle "$test_subtitle" \
        --argjson tags "$tags_json" \
        '{input: {title: $title, subtitle: $subtitle, tags: $tags}}')
    
    assert_json_snapshot "$actual_payload" "hashnode-payload.json" "Hashnode payload"
}

run_tests
tap_exit_code