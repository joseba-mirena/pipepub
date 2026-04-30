#!/bin/bash
# tools/tests/unit/test_ghost_api.sh
# @tags: unit

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "tags"

tag "test_ghost_api.sh" "unit"

run_tests() {
    tlog_section "Test: Ghost Lexical Payload Generation"
    
    local test_title="Ghost Test Article"
    local test_subtitle="This is a test subtitle"
    local test_tags="test, ghost, api"
    local test_cover="https://example.com/cover.jpg"
    
    # Parse tags
    declare -a parsed_tags=()
    parse_tags "$test_tags" parsed_tags
    
    # Filter tags for Ghost (alphanumeric + hyphen, max 5)
    declare -a ghost_tags=()
    for tag in "${parsed_tags[@]}"; do
        if [[ ${#ghost_tags[@]} -ge 5 ]]; then
            break
        fi
        # Ghost allows a-z, 0-9, and hyphens
        local cleaned=$(echo "$tag" | sed 's/[^a-z0-9-]//g')
        if [[ -n "$cleaned" ]]; then
            ghost_tags+=("{\"name\":\"$cleaned\"}")
        fi
    done
    
    if [[ ${#ghost_tags[@]} -eq 0 ]]; then
        ghost_tags=("{\"name\":\"technology\"}" "{\"name\":\"programming\"}")
    fi
    
    local tags_json="[$(IFS=,; echo "${ghost_tags[*]}")]"
    
    # Build expected payload
    local actual_payload=$(jq -n \
        --arg title "$test_title" \
        --arg custom_excerpt "$test_subtitle" \
        --argjson tags "$tags_json" \
        --arg feature_image "$test_cover" \
        '{
            posts: [{
                title: $title,
                custom_excerpt: $custom_excerpt,
                tags: $tags,
                feature_image: $feature_image
            }]
        }')
    
    # Compare with snapshot
    assert_json_snapshot "$actual_payload" "ghost-payload.json" "Ghost Lexical payload"
}

run_tests