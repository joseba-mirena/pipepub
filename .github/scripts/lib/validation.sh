#!/bin/bash
# .github/scripts/lib/validation.sh - Input validation functions

validate_tags() {
    local tags_json="$1"
    local max_tags="${2:-5}"
    
    local tag_count=$(echo "$tags_json" | jq '. | length')
    
    if [[ $tag_count -gt $max_tags ]]; then
        log_warning "Too many tags ($tag_count > $max_tags), truncating"
        echo "$tags_json" | jq ".[0:$max_tags]"
        return 1
    fi
    
    echo "$tags_json"
    return 0
}

validate_url() {
    local url="$1"
    if [[ -z "$url" ]]; then
        return 0
    fi
    
    if [[ "$url" =~ ^https?:// ]]; then
        return 0
    else
        log_error "Invalid URL: $url"
        return 1
    fi
}