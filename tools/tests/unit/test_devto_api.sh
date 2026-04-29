#!/bin/bash
# tools/tests/unit/test_devto_api.sh
# @tags: unit

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "tags"

tag "test_devto_api.sh" "unit"

run_tests() {
    tlog_section "Test: DEV.to Payload Generation"
    
    local test_title="Test Article"
    local test_tags="delete me, auto, test, draft"
    
    declare -a parsed_tags=()
    parse_tags "$test_tags" parsed_tags
    
    declare -a devto_tags=()
    for tag in "${parsed_tags[@]}"; do
        if [[ ${#devto_tags[@]} -ge 4 ]]; then
            break
        fi
        cleaned=$(echo "$tag" | sed 's/[-_]//g')
        if [[ ${#cleaned} -ge 2 ]] && [[ ${#cleaned} -le 30 ]]; then
            devto_tags+=("$cleaned")
        fi
    done
    
    local tags_json=$(printf '%s\n' "${devto_tags[@]}" | jq -R . | jq -s .)
    local actual_payload=$(jq -n \
        --arg title "$test_title" \
        --argjson tags "$tags_json" \
        '{article: {title: $title, tags: $tags, published: false}}')
    
    assert_json_snapshot "$actual_payload" "devto-payload.json" "DEV.to payload"
}

run_tests