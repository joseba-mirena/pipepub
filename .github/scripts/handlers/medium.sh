#!/bin/bash
# .github/scripts/handlers/medium.sh - Medium publisher handler

MEDIUM_API_URL="https://api.medium.com/v1"

publish_to_medium() {
    local title="$1"
    local subtitle="$2"
    local content="$3"
    local tags="$4"
    local status="$5"
    local cover_image="$6"
    
    log_info "Publishing to Medium: ${title:-Untitled}"
    
    # DRY RUN MODE
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_debug "DRY RUN: Would publish to Medium"
        return 0
    fi
    
    if [[ -z "${MEDIUM_TOKEN:-}" ]]; then
        log_info "MEDIUM_TOKEN not configured, skipping Medium"
        return 0
    fi
    
    if [[ -z "$title" ]]; then
        log_error "Title is empty, cannot publish to Medium"
        return 1
    fi
    
    local user_id=$(get_medium_user_id)
    if [[ -z "$user_id" ]]; then
        log_error "Failed to get Medium user ID"
        return 1
    fi
    
    local publish_status="draft"
    if [[ "$status" == "public" ]]; then
        publish_status="public"
    fi
    
    # Raw gist URLs for Medium
    local final_content="$content"
    
    # Process tags using service-agnostic function
    # This uses SERVICE_MAX_TAGS, SERVICE_TAG_MIN_LENGTH, SERVICE_TAG_MAX_LENGTH, SERVICE_TAG_PATTERN
    # from the loaded service config (medium.conf)
    local -a processed_tags=()
    process_tags_for_service "$tags" processed_tags
    
    # Convert underscores to hyphens for Medium (Medium prefers hyphens)
    local -a medium_tags=()
    for tag in "${processed_tags[@]}"; do
        medium_tags+=("$(echo "$tag" | sed 's/_/-/g')")
    done
    
    if [[ ${#medium_tags[@]} -eq 0 ]]; then
        medium_tags=("technology" "programming")
        log_warning "No valid tags for Medium, using defaults"
    fi
    
    log_info "Final Medium tags (${#medium_tags[@]}): ${medium_tags[*]}"
    
    local tags_json=$(tags_to_json medium_tags)
    
    # Build payload
    local payload
    if [[ -n "$cover_image" ]] && [[ -n "$subtitle" ]]; then
        payload=$(jq -n \
            --arg title "$title" \
            --arg subtitle "$subtitle" \
            --arg content_format "markdown" \
            --arg content "$final_content" \
            --argjson tags "$tags_json" \
            --arg publish_status "$publish_status" \
            --arg canonicalUrl "$cover_image" \
            '{
                title: $title,
                subtitle: $subtitle,
                contentFormat: $content_format,
                content: $content,
                tags: $tags,
                publishStatus: $publish_status,
                notifyFollowers: true,
                canonicalUrl: $canonicalUrl
            }')
    elif [[ -n "$cover_image" ]]; then
        payload=$(jq -n \
            --arg title "$title" \
            --arg content_format "markdown" \
            --arg content "$final_content" \
            --argjson tags "$tags_json" \
            --arg publish_status "$publish_status" \
            --arg canonicalUrl "$cover_image" \
            '{
                title: $title,
                contentFormat: $content_format,
                content: $content,
                tags: $tags,
                publishStatus: $publish_status,
                notifyFollowers: true,
                canonicalUrl: $canonicalUrl
            }')
    elif [[ -n "$subtitle" ]]; then
        payload=$(jq -n \
            --arg title "$title" \
            --arg subtitle "$subtitle" \
            --arg content_format "markdown" \
            --arg content "$final_content" \
            --argjson tags "$tags_json" \
            --arg publish_status "$publish_status" \
            '{
                title: $title,
                subtitle: $subtitle,
                contentFormat: $content_format,
                content: $content,
                tags: $tags,
                publishStatus: $publish_status,
                notifyFollowers: true
            }')
    else
        payload=$(jq -n \
            --arg title "$title" \
            --arg content_format "markdown" \
            --arg content "$final_content" \
            --argjson tags "$tags_json" \
            --arg publish_status "$publish_status" \
            '{
                title: $title,
                contentFormat: $content_format,
                content: $content,
                tags: $tags,
                publishStatus: $publish_status,
                notifyFollowers: true
            }')
    fi
    
    # API call - HTTP 2xx means success
    if call_api_with_retry "$MEDIUM_API_URL/users/$user_id/posts" "$MEDIUM_TOKEN" "$payload" "POST" "application/json" "Bearer" > /dev/null; then
        log_success "Published to Medium"
        return 0
    fi
    
    log_error "Failed to publish to Medium"
    return 1
}

get_medium_user_id() {
    # DRY RUN MODE
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo "mock_medium_user_id_12345"
        return 0
    fi
    
    if [[ -f "/tmp/medium_user_id" ]]; then
        cat "/tmp/medium_user_id"
        return 0
    fi
    
    local response
    if response=$(call_api_with_retry "$MEDIUM_API_URL/me" "$MEDIUM_TOKEN" "" "GET" "application/json" "Bearer"); then
        local user_id=$(echo "$response" | jq -r '.data.id // empty')
        if [[ -n "$user_id" ]]; then
            echo "$user_id" > "/tmp/medium_user_id"
            echo "$user_id"
            return 0
        fi
    fi
    
    return 1
}