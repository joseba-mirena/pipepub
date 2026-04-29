#!/bin/bash
# .github/scripts/handlers/devto.sh - DEV.to publisher handler

publish_to_devto() {
    local title="$1"
    local subtitle="$2"
    local content="$3"
    local tags="$4"
    local status="$5"
    local cover_image="$6"
    
    log_info "Publishing to DEV.to: ${title:-Untitled}"
    
    # DRY RUN MODE
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_debug "DRY RUN: Would publish to DEV.to"
        return 0
    fi
    
    if [[ -z "${DEVTO_TOKEN:-}" ]]; then
        log_error "DEVTO_TOKEN not configured"
        return 1
    fi
    
    if [[ -z "$title" ]]; then
        log_error "Title is empty, cannot publish"
        return 1
    fi
    
    if [[ -n "$subtitle" ]]; then
        log_debug "DEV.to does not support subtitle, ignoring: '$subtitle'"
    fi
    
    local published="false"
    if [[ "$status" == "public" ]]; then
        published="true"
    fi
    
    # Format gist URLs for DEV.to
    local final_content=$(echo "$content" | sed -E 's|(https://gist\.github\.com/[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+)|{% embed \1 %}|g')
    
    # Process tags using service-agnostic function
    # This uses SERVICE_MAX_TAGS, SERVICE_TAG_MIN_LENGTH, SERVICE_TAG_MAX_LENGTH, SERVICE_TAG_PATTERN
    # from the loaded service config (devto.conf)
    local -a processed_tags=()
    process_tags_for_service "$tags" processed_tags
    
    # Check if we have any tags after processing
    if [[ ${#processed_tags[@]} -eq 0 ]]; then
        processed_tags=("technology" "programming")
        log_warning "No valid tags for DEV.to, using defaults"
    fi
    
    log_info "Final DEV.to tags (${#processed_tags[@]}): ${processed_tags[*]}"
    
    # Build tags JSON array
    local tags_json=$(tags_to_json processed_tags)
    
    # Build payload
    local payload
    if [[ -n "$cover_image" ]]; then
        payload=$(jq -n \
            --arg title "$title" \
            --arg body_markdown "$final_content" \
            --argjson published "$published" \
            --argjson tags "$tags_json" \
            --arg main_image "$cover_image" \
            '{
                article: {
                    title: $title,
                    body_markdown: $body_markdown,
                    published: $published,
                    tags: $tags,
                    main_image: $main_image
                }
            }' 2>/dev/null)
    else
        payload=$(jq -n \
            --arg title "$title" \
            --arg body_markdown "$final_content" \
            --argjson published "$published" \
            --argjson tags "$tags_json" \
            '{
                article: {
                    title: $title,
                    body_markdown: $body_markdown,
                    published: $published,
                    tags: $tags
                }
            }' 2>/dev/null)
    fi
    
    # API call - HTTP 2xx means success
    if call_api_with_retry "https://dev.to/api/articles" "$DEVTO_TOKEN" "$payload" "POST" "application/json" "api-key" > /dev/null; then
        log_success "Published to DEV.to"
        return 0
    fi
    
    log_error "Failed to publish to DEV.to"
    return 1
}