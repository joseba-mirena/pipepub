#!/bin/bash
# tools/tests/unit/test_medium_api.sh
# @tags: unit

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "tags"

tag "test_medium_api.sh" "unit"

run_tests() {
    tlog_section "Test: Medium Payload Generation"
    
    local test_title="Test Article"
    local test_subtitle="This is a test subtitle"
    local test_tags="delete me, auto, test, draft"
    local test_cover_image="https://example.com/cover.jpg"
    
    declare -a parsed_tags=()
    parse_tags "$test_tags" parsed_tags
    
    declare -a medium_tags=()
    for tag in "${parsed_tags[@]}"; do
        if [[ ${#medium_tags[@]} -ge 5 ]]; then
            break
        fi
        cleaned=$(echo "$tag" | sed 's/_/-/g')
        if [[ ${#cleaned} -ge 1 ]] && [[ ${#cleaned} -le 25 ]]; then
            medium_tags+=("$cleaned")
        fi
    done
    
    local tags_json=$(printf '%s\n' "${medium_tags[@]}" | jq -R . | jq -s .)
    
    local actual_payload=$(jq -n \
        --arg title "$test_title" \
        --arg subtitle "$test_subtitle" \
        --arg content "Test content" \
        --argjson tags "$tags_json" \
        --arg canonicalUrl "$test_cover_image" \
        '{title: $title, subtitle: $subtitle, content: $content, tags: $tags, canonicalUrl: $canonicalUrl}')
    
    assert_json_snapshot "$actual_payload" "medium-payload.json" "Medium payload"
}

run_tests