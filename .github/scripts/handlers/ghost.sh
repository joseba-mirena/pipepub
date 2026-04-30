#!/bin/bash
# .github/scripts/handlers/ghost.sh - Ghost v6 publisher handler with Lexical support

# Helper function to generate JWT for Ghost Admin API
_generate_ghost_jwt() {
    local admin_key="$1"
    local id="${admin_key%:*}"
    local secret="${admin_key#*:}"
    
    if ! command -v xxd &>/dev/null; then
        log_error "xxd command not found - required for JWT generation"
        return 1
    fi
    
    if ! command -v openssl &>/dev/null; then
        log_error "openssl command not found - required for JWT generation"
        return 1
    fi
    
    local secret_decoded=$(echo -n "$secret" | xxd -r -p)
    local iat=$(date +%s)
    local exp=$((iat + 300))
    
    local header=$(echo -n "{\"alg\":\"HS256\",\"typ\":\"JWT\",\"kid\":\"$id\"}" | base64 -w 0 | tr -d '=' | tr '/+' '_-')
    local payload=$(echo -n "{\"iat\":$iat,\"exp\":$exp,\"aud\":\"/admin/\"}" | base64 -w 0 | tr -d '=' | tr '/+' '_-')
    local signature=$(echo -n "$header.$payload" | openssl dgst -sha256 -hmac "$secret_decoded" -binary | base64 -w 0 | tr -d '=' | tr '/+' '_-')
    
    echo "$header.$payload.$signature"
}

# Helper function to extract gist ID from URL
_extract_gist_id() {
    local url="$1"
    echo "$url" | sed -E 's|https://gist\.github\.com/[a-zA-Z0-9_-]+/([a-zA-Z0-9_-]+).*|\1|'
}

# Helper function to build Lexical nodes from content
_build_lexical_nodes() {
    local content="$1"
    local -n result_nodes=$2
    local nodes=()
    local current_markdown=""
    local line
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check if line is a Gist URL
        if [[ "$line" =~ https://gist\.github\.com/[a-zA-Z0-9_-]+/([a-zA-Z0-9_-]+) ]]; then
            # Flush current markdown if any
            if [[ -n "$current_markdown" ]]; then
                # Create markdown node with proper newline handling
                local markdown_node=$(jq -n \
                    --arg md "$current_markdown" \
                    '{
                        type: "markdown",
                        markdown: $md
                    }' | sed 's/\\\\n/\\n/g')
                nodes+=("$markdown_node")
                current_markdown=""
            fi
            
            # Add Gist as HTML card
            local gist_id=$(_extract_gist_id "$line")
            local html_node=$(jq -n \
                --arg script "<script src=\"https://gist.github.com/${gist_id}.js\"></script>" \
                '{
                    type: "html",
                    html: $script
                }')
            nodes+=("$html_node")
            log_debug "Added Gist card for ID: $gist_id"
        else
            # Add to current markdown accumulator
            if [[ -n "$current_markdown" ]]; then
                current_markdown+="\n$line"
            else
                current_markdown="$line"
            fi
        fi
    done <<< "$content"
    
    # Flush remaining markdown
    if [[ -n "$current_markdown" ]]; then
        local markdown_node=$(jq -n \
            --arg md "$current_markdown" \
            '{
                type: "markdown",
                markdown: $md
            }' | sed 's/\\\\n/\\n/g')
        nodes+=("$markdown_node")
    fi
    
    # Build nodes array JSON
    local result="["
    for i in "${!nodes[@]}"; do
        [[ $i -gt 0 ]] && result+=","
        result+="${nodes[$i]}"
    done
    result+="]"
    result_nodes="$result"
}

publish_to_ghost() {
    local title="$1"
    local subtitle="$2"
    local content="$3"
    local tags="$4"
    local status="$5"
    local cover_image="$6"
    
    log_info "Publishing to Ghost: ${title:-Untitled}"
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_debug "DRY RUN: Would publish to Ghost"
        return 0
    fi
    
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
    
    # Generate JWT from admin key
    local jwt_token=$(_generate_ghost_jwt "$GHOST_TOKEN")
    if [[ -z "$jwt_token" ]]; then
        log_error "Failed to generate JWT token"
        return 1
    fi
    
    # Process tags
    local -a processed_tags=()
    if declare -F process_tags_for_service >/dev/null 2>&1; then
        process_tags_for_service "$tags" processed_tags
    else
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
        tags_json+="{\"name\":\"${processed_tags[$i]}\"}"
    done
    tags_json+="]"
    
    # Build API endpoint
    local api_url="https://${GHOST_DOMAIN}/ghost/api/admin/posts/"
    # Local Docker (uncomment for local testing)
    # if [[ "$GHOST_DOMAIN" == "localhost" ]]; then
    #     api_url="http://localhost:2368/ghost/api/admin/posts/"
    # fi
    
    # Build Lexical nodes from content
    local lexical_nodes=""
    _build_lexical_nodes "$content" lexical_nodes
    
    # Build Lexical structure as compact JSON string
    local lexical=$(jq -c -n \
        --argjson nodes "$lexical_nodes" \
        '{
            root: {
                children: $nodes,
                direction: "ltr",
                format: "",
                indent: 0,
                type: "root",
                version: 1
            }
        }')
    
    # Build payload based on available fields and status
    local payload
    local api_status="$status"
    if [[ "$status" == "public" ]]; then
        api_status="published"
        local published_at="$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")"
        
        if [[ -n "$cover_image" ]] && [[ -n "$subtitle" ]]; then
            payload=$(jq -n \
                --arg title "$title" \
                --arg custom_excerpt "$subtitle" \
                --arg lexical "$lexical" \
                --argjson tags "$tags_json" \
                --arg feature_image "$cover_image" \
                --arg status "$api_status" \
                --arg published_at "$published_at" \
                '{
                    posts: [{
                        title: $title,
                        custom_excerpt: $custom_excerpt,
                        lexical: $lexical,
                        tags: $tags,
                        feature_image: $feature_image,
                        status: $status,
                        published_at: $published_at
                    }]
                }')
        elif [[ -n "$cover_image" ]]; then
            payload=$(jq -n \
                --arg title "$title" \
                --arg lexical "$lexical" \
                --argjson tags "$tags_json" \
                --arg feature_image "$cover_image" \
                --arg status "$api_status" \
                --arg published_at "$published_at" \
                '{
                    posts: [{
                        title: $title,
                        lexical: $lexical,
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
                --arg lexical "$lexical" \
                --argjson tags "$tags_json" \
                --arg status "$api_status" \
                --arg published_at "$published_at" \
                '{
                    posts: [{
                        title: $title,
                        custom_excerpt: $custom_excerpt,
                        lexical: $lexical,
                        tags: $tags,
                        status: $status,
                        published_at: $published_at
                    }]
                }')
        else
            payload=$(jq -n \
                --arg title "$title" \
                --arg lexical "$lexical" \
                --argjson tags "$tags_json" \
                --arg status "$api_status" \
                --arg published_at "$published_at" \
                '{
                    posts: [{
                        title: $title,
                        lexical: $lexical,
                        tags: $tags,
                        status: $status,
                        published_at: $published_at
                    }]
                }')
        fi
    else
        # Draft status - omit published_at entirely
        if [[ -n "$cover_image" ]] && [[ -n "$subtitle" ]]; then
            payload=$(jq -n \
                --arg title "$title" \
                --arg custom_excerpt "$subtitle" \
                --arg lexical "$lexical" \
                --argjson tags "$tags_json" \
                --arg feature_image "$cover_image" \
                --arg status "$api_status" \
                '{
                    posts: [{
                        title: $title,
                        custom_excerpt: $custom_excerpt,
                        lexical: $lexical,
                        tags: $tags,
                        feature_image: $feature_image,
                        status: $status
                    }]
                }')
        elif [[ -n "$cover_image" ]]; then
            payload=$(jq -n \
                --arg title "$title" \
                --arg lexical "$lexical" \
                --argjson tags "$tags_json" \
                --arg feature_image "$cover_image" \
                --arg status "$api_status" \
                '{
                    posts: [{
                        title: $title,
                        lexical: $lexical,
                        tags: $tags,
                        feature_image: $feature_image,
                        status: $status
                    }]
                }')
        elif [[ -n "$subtitle" ]]; then
            payload=$(jq -n \
                --arg title "$title" \
                --arg custom_excerpt "$subtitle" \
                --arg lexical "$lexical" \
                --argjson tags "$tags_json" \
                --arg status "$api_status" \
                '{
                    posts: [{
                        title: $title,
                        custom_excerpt: $custom_excerpt,
                        lexical: $lexical,
                        tags: $tags,
                        status: $status
                    }]
                }')
        else
            payload=$(jq -n \
                --arg title "$title" \
                --arg lexical "$lexical" \
                --argjson tags "$tags_json" \
                --arg status "$api_status" \
                '{
                    posts: [{
                        title: $title,
                        lexical: $lexical,
                        tags: $tags,
                        status: $status
                    }]
                }')
        fi
    fi
    
    # Debug payload logging (uncomment for local testing)
    # if [[ "${LOG_LEVEL:-}" == "debug" ]]; then
    #     mkdir -p .tmp
    #     local debug_file=".tmp/ghost_lexical_$(date +%Y%m%d_%H%M%S).json"
    #     echo "$payload" > "$debug_file"
    #     log_debug "Lexical payload saved to: $debug_file"
    # fi
    
    # API call with Ghost auth type
    if response=$(call_api_with_retry "$api_url" "$jwt_token" "$payload" "POST" "application/json" "Ghost" "Accept-Version: v6.0"); then
        local post_url=$(echo "$response" | jq -r '.posts[0].url // empty')
        if [[ -n "$post_url" ]]; then
            log_success "Published to Ghost: $post_url"
            return 0
        else
            log_success "Ghost post created"
            return 0
        fi
    fi
    
    log_error "Failed to publish to Ghost"
    return 1
}