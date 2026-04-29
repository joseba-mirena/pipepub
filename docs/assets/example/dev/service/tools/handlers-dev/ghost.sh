#!/bin/bash
# tools/handlers-dev/ghost.sh - Ghost publisher handler (development)

# This handler is for local testing only.
# Once working, move to .github/scripts/handlers/ghost.sh

publish_to_ghost() {
    local title="$1"
    local subtitle="$2"
    local content="$3"
    local tags="$4"
    local status="$5"
    local cover_image="$6"
    
    log_info "Publishing to Ghost (Dev): ${title:-Untitled}"
    
    # DRY RUN MODE
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_debug "DRY RUN: Would publish to Ghost"
        return 0
    fi
    
    # Check required credentials
    if [[ -z "${GHOST_TOKEN:-}" ]]; then
        log_error "GHOST_TOKEN not configured"
        return 1
    fi
    
    if [[ -z "${GHOST_DOMAIN:-}" ]]; then
        log_error "GHOST_DOMAIN not configured"
        return 1
    fi
    
    if [[ -z "$title" ]]; then
        log_error "Title is empty, cannot publish"
        return 1
    fi
    
    # Determine publish status
    local published_at="null"
    if [[ "$status" == "public" ]]; then
        published_at="$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")"
    fi
    
    # Apply gist format if needed
    local gist_format="${SERVICE_GIST_FORMAT:-%s}"
    local final_content=$(apply_gist_format "$content" "$gist_format" 2>/dev/null || echo "$content")
    
    # Process tags
    local -a processed_tags=()
    if declare -F process_tags_for_service >/dev/null 2>&1; then
        process_tags_for_service "$tags" processed_tags
    else
        # Fallback tag processing
        IFS=',' read -ra raw_tags <<< "$tags"
        for tag in "${raw_tags[@]}"; do
            local clean=$(echo "$tag" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | sed 's/^-\|-$//g')
            [[ -n "$clean" ]] && processed_tags+=("$clean")
        done
    fi
    
    if [[ ${#processed_tags[@]} -eq 0 ]]; then
        processed_tags=("technology" "programming")
        log_warning "No valid tags for Ghost, using defaults"
    fi
    
    log_info "Final Ghost tags (${#processed_tags[@]}): ${processed_tags[*]}"
    
    # Build tags array for API
    local tags_json="["
    for i in "${!processed_tags[@]}"; do
        [[ $i -gt 0 ]] && tags_json+=","
        tags_json+="\"${processed_tags[$i]}\""
    done
    tags_json+="]"
    
    # Build API endpoint
    local api_url="https://${GHOST_DOMAIN}/ghost/api/admin/posts/"
    
    # Build payload
    local payload
    if [[ -n "$cover_image" ]] && [[ -n "$subtitle" ]]; then
        payload=$(jq -n \
            --arg title "$title" \
            --arg custom_excerpt "$subtitle" \
            --arg mobiledoc "{\"version\":\"0.3.1\",\"markups\":[],\"atoms\":[],\"cards\":[[\"markdown\",{\"markdown\":$(echo "$final_content" | jq -Rs .)}]],\"sections\":[[10,0]]}" \
            --argjson tags "$tags_json" \
            --arg feature_image "$cover_image" \
            --arg status "$status" \
            --arg published_at "$published_at" \
            '{
                posts: [{
                    title: $title,
                    custom_excerpt: $custom_excerpt,
                    mobiledoc: $mobiledoc,
                    tags: $tags,
                    feature_image: $feature_image,
                    status: $status,
                    published_at: $published_at
                }]
            }')
    elif [[ -n "$cover_image" ]]; then
        payload=$(jq -n \
            --arg title "$title" \
            --arg mobiledoc "{\"version\":\"0.3.1\",\"markups\":[],\"atoms\":[],\"cards\":[[\"markdown\",{\"markdown\":$(echo "$final_content" | jq -Rs .)}]],\"sections\":[[10,0]]}" \
            --argjson tags "$tags_json" \
            --arg feature_image "$cover_image" \
            --arg status "$status" \
            --arg published_at "$published_at" \
            '{
                posts: [{
                    title: $title,
                    mobiledoc: $mobiledoc,
                    tags: $tags,
                    feature_image: $feature_image,
                    status: $status,
                    published_at: $published_at
                }]
            }')
    elif [[ -n "$subtitle" ]]; then
        payload=$(jq -n \
            --arg title "$title" \
            --arg custom_excerpt "$subtitle" \
            --arg mobiledoc "{\"version\":\"0.3.1\",\"markups\":[],\"atoms\":[],\"cards\":[[\"markdown\",{\"markdown\":$(echo "$final_content" | jq -Rs .)}]],\"sections\":[[10,0]]}" \
            --argjson tags "$tags_json" \
            --arg status "$status" \
            --arg published_at "$published_at" \
            '{
                posts: [{
                    title: $title,
                    custom_excerpt: $custom_excerpt,
                    mobiledoc: $mobiledoc,
                    tags: $tags,
                    status: $status,
                    published_at: $published_at
                }]
            }')
    else
        payload=$(jq -n \
            --arg title "$title" \
            --arg mobiledoc "{\"version\":\"0.3.1\",\"markups\":[],\"atoms\":[],\"cards\":[[\"markdown\",{\"markdown\":$(echo "$final_content" | jq -Rs .)}]],\"sections\":[[10,0]]}" \
            --argjson tags "$tags_json" \
            --arg status "$status" \
            --arg published_at "$published_at" \
            '{
                posts: [{
                    title: $title,
                    mobiledoc: $mobiledoc,
                    tags: $tags,
                    status: $status,
                    published_at: $published_at
                }]
            }')
    fi
    
    # API call
    local response
    if response=$(curl -s -S -w "\n%{http_code}" \
        -X POST "$api_url" \
        -H "Authorization: Bearer $GHOST_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept-Version: v5.0" \
        -d "$payload" 2>&1); then
        
        local http_code=$(echo "$response" | tail -n1)
        local body=$(echo "$response" | sed '$d')
        
        if [[ "$http_code" -ge 200 ]] && [[ "$http_code" -lt 300 ]]; then
            local post_url=$(echo "$body" | jq -r '.posts[0].url // empty')
            if [[ -n "$post_url" ]]; then
                log_success "Published to Ghost: $post_url"
                return 0
            else
                log_success "Ghost post created (draft)"
                return 0
            fi
        else
            local error_msg=$(echo "$body" | jq -r '.errors[0].message // "Unknown error"')
            log_error "Ghost API error (HTTP $http_code): $error_msg"
            return 1
        fi
    fi
    
    log_error "Failed to publish to Ghost"
    return 1
}