#!/bin/bash
# .github/scripts/handlers/hashnode.sh - Hashnode publisher handler

publish_to_hashnode() {
    local title="$1"
    local subtitle="$2"
    local content="$3"
    local tags="$4"
    local status="$5"
    local cover_image="$6"
    
    log_info "Publishing to Hashnode: ${title:-Untitled}"
    
    # DRY RUN MODE
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_debug "DRY RUN: Would publish to Hashnode"
        return 0
    fi
    
    if [[ -z "${HASHNODE_TOKEN:-}" ]]; then
        log_info "HASHNODE_TOKEN not configured, skipping Hashnode"
        return 0
    fi
    
    if [[ -z "${HASHNODE_PUBLICATION_ID:-}" ]]; then
        log_error "HASHNODE_PUBLICATION_ID not configured"
        return 1
    fi
    
    if [[ -z "$title" ]]; then
        log_error "Title is empty, cannot publish"
        return 1
    fi
    
    # Process cover image: add as first content in the article
    local final_content="$content"
    if [[ -n "$cover_image" ]]; then
        log_info "Adding cover image as first element in content: $cover_image"
        final_content="![Cover Image]($cover_image)

$content"
    fi
    
    # Process tags
    local -a processed_tags=()
    process_tags_for_service "$tags" processed_tags
    
    # Hashnode requires tags as objects with name and slug
    local -a hashnode_tags=()
    for tag in "${processed_tags[@]}"; do
        # Remove hyphens and underscores (Hashnode prefers alphanumeric only)
        local clean_tag=$(echo "$tag" | sed 's/[-_]//g')
        hashnode_tags+=("{\"name\":\"$clean_tag\",\"slug\":\"$clean_tag\"}")
        log_debug "Hashnode tag: '$tag' -> '$clean_tag'"
    done
    
    if [[ ${#hashnode_tags[@]} -eq 0 ]]; then
        hashnode_tags=("{\"name\":\"technology\",\"slug\":\"technology\"}" "{\"name\":\"programming\",\"slug\":\"programming\"}")
        log_warning "No valid tags for Hashnode, using defaults"
    fi
    
    log_info "Final Hashnode tags (${#hashnode_tags[@]}): $(echo "${hashnode_tags[@]}" | sed 's/},{/} {/g')"
    
    local tags_json="[$(IFS=,; echo "${hashnode_tags[*]}")]"
    
    # Determine publication state
    local publication_state="DRAFT"
    if [[ "$status" == "public" ]]; then
        publication_state="PUBLISHED"
    fi
    
    # Build GraphQL mutation
    local mutation='mutation CreateDraft($input: CreateDraftInput!) {
        createDraft(input: $input) {
            draft {
                id
                title
                slug
            }
        }
    }'
    
    local variables
    if [[ -n "$subtitle" ]]; then
        variables=$(jq -n \
            --arg publicationId "$HASHNODE_PUBLICATION_ID" \
            --arg title "$title" \
            --arg subtitle "$subtitle" \
            --arg contentMarkdown "$final_content" \
            --argjson tags "$tags_json" \
            '{
                input: {
                    publicationId: $publicationId,
                    title: $title,
                    subtitle: $subtitle,
                    contentMarkdown: $contentMarkdown,
                    tags: $tags
                }
            }')
    else
        variables=$(jq -n \
            --arg publicationId "$HASHNODE_PUBLICATION_ID" \
            --arg title "$title" \
            --arg contentMarkdown "$final_content" \
            --argjson tags "$tags_json" \
            '{
                input: {
                    publicationId: $publicationId,
                    title: $title,
                    contentMarkdown: $contentMarkdown,
                    tags: $tags
                }
            }')
    fi
    
    local payload=$(jq -n \
        --arg query "$mutation" \
        --argjson variables "$variables" \
        '{query: $query, variables: $variables}')
    
    # Create draft
    local response
    if response=$(call_api_with_retry "https://gql.hashnode.com/" "$HASHNODE_TOKEN" "$payload" "POST" "application/json" "Bearer"); then
        local draft_id=$(echo "$response" | jq -r '.data.createDraft.draft.id // empty')
        
        if [[ -z "$draft_id" ]]; then
            log_error "Failed to create draft - no ID returned"
            return 1
        fi
        
        log_success "Draft created: https://hashnode.com/drafts/$draft_id"
        
        # Publish if status is public
        if [[ "$publication_state" == "PUBLISHED" ]]; then
            log_info "Publishing draft..."
            
            local publish_mutation='mutation PublishDraft($input: PublishDraftInput!) {
                publishDraft(input: $input) {
                    post {
                        id
                        title
                        url
                    }
                }
            }'
            
            local publish_variables=$(jq -n \
                --arg id "$draft_id" \
                '{input: {id: $id}}')
            
            local publish_payload=$(jq -n \
                --arg query "$publish_mutation" \
                --argjson variables "$publish_variables" \
                '{query: $query, variables: $variables}')
            
            if publish_response=$(call_api_with_retry "https://gql.hashnode.com/" "$HASHNODE_TOKEN" "$publish_payload" "POST" "application/json" "Bearer"); then
                local article_url=$(echo "$publish_response" | jq -r '.data.publishDraft.post.url // empty')
                if [[ -n "$article_url" ]]; then
                    log_success "Published to Hashnode: $article_url"
                    return 0
                fi
            else
                log_warning "Draft created but could not publish automatically"
                return 0
            fi
        fi
        
        return 0
    fi
    
    log_error "Failed to publish to Hashnode"
    return 1
}