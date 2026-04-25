#!/bin/bash
# .github/scripts/handlers/devto.sh - Dev.to publisher handler

publish_to_devto() {
    local title="$1"
    local subtitle="$2"
    local content="$3"
    local tags="$4"
    local status="$5"
    local cover_image="$6"
    
    log_info "Publishing to Dev.to: ${title:-Untitled}"
    
    # DRY RUN MODE
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_debug "DRY RUN: Would publish to Dev.to"
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
        log_debug "Dev.to does not support subtitle, ignoring: '$subtitle'"
    fi
    
    local published="false"
    if [[ "$status" == "public" ]]; then
        published="true"
    fi
    
    # Format gist URLs for Dev.to: {% embed URL %}
    local final_content="$content"
    final_content=$(echo "$final_content" | sed -E 's|(https://gist\.github\.com/[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+)|{% embed \1 %}|g')
    
    # Parse tags using generic utility
    local -a parsed_tags=()
    parse_tags "$tags" parsed_tags
    
    # Apply Dev.to specific rules: max 4 tags, remove underscores/hyphens
    local -a devto_tags=()
    for tag in "${parsed_tags[@]}"; do
        if [[ ${#devto_tags[@]} -ge 4 ]]; then
            log_debug "Dev.to: Max 4 tags reached, stopping"
            break
        fi
        local devto_tag=$(echo "$tag" | sed 's/[-_]//g')
        if [[ ${#devto_tag} -ge 2 ]] && [[ ${#devto_tag} -le 30 ]]; then
            devto_tags+=("$devto_tag")
            log_debug "Dev.to tag accepted: '$tag' -> '$devto_tag'"
        else
            log_debug "Dev.to tag rejected (length ${#devto_tag}): '$tag'"
        fi
    done
    
    if [[ ${#devto_tags[@]} -eq 0 ]]; then
        devto_tags=("technology" "programming")
        log_warning "No valid tags for Dev.to, using defaults"
    fi
    
    log_info "Final Dev.to tags (${#devto_tags[@]}): ${devto_tags[*]}"
    
    # Build tags JSON array
    local tags_json=$(tags_to_json devto_tags)
    
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
        log_success "Published to Dev.to"
        return 0
    fi
    
    log_error "Failed to publish to Dev.to"
    return 1
}