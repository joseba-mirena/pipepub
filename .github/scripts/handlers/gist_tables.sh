#!/bin/bash
# .github/scripts/handlers/gist_tables.sh - Gist tables handler

# Guard against sourcing without logging
if ! declare -F log_error >/dev/null 2>&1; then
    echo "ERROR: logging.sh must be sourced before gist_tables.sh" >&2
    return 1 2>/dev/null || exit 1
fi

process_gist_tables() {
    local content="$1"
    local file_path="$2"
    local gist_token="$3"
    local post_title="$4"
    
    local table_count=0
    local result=""
    local in_table=0
    local table_buffer=""
    
    local safe_title=$(echo "$post_title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*\|.*\|[[:space:]]*$ ]]; then
            if [[ $in_table -eq 0 ]]; then
                in_table=1
                table_buffer="$line"
            else
                table_buffer="$table_buffer"$'\n'"$line"
            fi
        else
            if [[ $in_table -eq 1 ]]; then
                table_count=$((table_count + 1))
                
                if [[ "$table_buffer" =~ \|[-:]+\| ]]; then
                    local gist_name="${safe_title}_table-${table_count}.md"
                    local gist_url=$(create_gist "$table_buffer" "$gist_name" "$gist_token")
                    
                    if [[ -n "$gist_url" ]]; then
                        result+="$gist_url"$'\n'
                        log_debug "Table $table_count replaced with gist: $gist_url"
                    else
                        log_warning "Failed to create gist for table $table_count, keeping original"
                        result+="$table_buffer"$'\n'
                    fi
                else
                    result+="$table_buffer"$'\n'
                fi
                
                in_table=0
                table_buffer=""
            fi
            
            result+="$line"$'\n'
        fi
    done <<< "$content"
    
    # Handle trailing table
    if [[ $in_table -eq 1 ]]; then
        table_count=$((table_count + 1))
        
        if [[ "$table_buffer" =~ \|[-:]+\| ]]; then
            local gist_name="${safe_title}_table-${table_count}.md"
            local gist_url=$(create_gist "$table_buffer" "$gist_name" "$gist_token")
            
            if [[ -n "$gist_url" ]]; then
                result+="$gist_url"$'\n'
                log_debug "Table $table_count replaced with gist: $gist_url"
            else
                result+="$table_buffer"$'\n'
            fi
        else
            result+="$table_buffer"$'\n'
        fi
    fi

    log_debug "Processed $table_count table(s)"
    echo "$result"
}

create_gist() {
    local content="$1"
    local name="$2"
    local token="$3"
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo "https://gist.github.com/mock/dry-run-$(date +%s)"
        return 0
    fi
    
    if [[ -z "$token" ]]; then
        log_error "GitHub token not provided for gist creation"
        return 1
    fi
    
    # Create temporary file for content to avoid quoting issues
    local temp_content=$(mktemp)
    echo "$content" > "$temp_content"
    
    # Build payload using jq with file input
    local payload=$(jq -n \
        --arg desc "Table from markdown" \
        --arg name "$name" \
        --rawfile content "$temp_content" \
        '{description: $desc, public: true, files: {($name): {content: $content}}}')
    
    rm -f "$temp_content"
    
    local response
    if response=$(call_api_with_retry "https://api.github.com/gists" "$token" "$payload" "POST" "application/json" "Bearer"); then
        local gist_url=$(echo "$response" | jq -r '.html_url // empty')
        if [[ -n "$gist_url" ]]; then
            echo "$gist_url"
            return 0
        else
            log_error "No URL returned from gist creation"
            log_debug "Response: $response"
        fi
    fi
    
    return 1
}