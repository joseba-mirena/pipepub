#!/bin/bash
# .github/scripts/lib/frontmatter.sh - Frontmatter parser

# Simple frontmatter parser that sets global variables

parse_frontmatter() {
    local content="$1"
    
    # Initialize empty - defaults will be applied by caller
    FRONTMATTER_TAGS=""
    FRONTMATTER_STATUS=""
    FRONTMATTER_AUTO=""
    FRONTMATTER_GIST=""
    FRONTMATTER_PUBLISHER=""
    FRONTMATTER_COVER_IMAGE=""
    FRONTMATTER_TITLE=""
    FRONTMATTER_SUBTITLE=""
    
    # Check if file content has frontmatter
    if [[ ! $(echo "$content" | head -n1) == "---" ]]; then
        return 1
    fi
    
    # Extract ONLY the FIRST frontmatter block (between first two --- markers)
    local frontmatter=""
    local line=""
    local in_frontmatter=0
    local frontmatter_ended=0
    
    # FIXED: handle last line without trailing newline
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ $frontmatter_ended -eq 1 ]]; then
            break
        fi
        
        if [[ $in_frontmatter -eq 0 ]] && [[ "$line" == "---" ]]; then
            in_frontmatter=1
            continue
        elif [[ $in_frontmatter -eq 1 ]] && [[ "$line" == "---" ]]; then
            frontmatter_ended=1
            break
        elif [[ $in_frontmatter -eq 1 ]]; then
            frontmatter+="$line"$'\n'
        fi
    done <<< "$content"
    
    if [[ -z "$frontmatter" ]]; then
        log_debug "No frontmatter found in content"
        return 1
    fi
    
    # Parse each line of the frontmatter only
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" ]] && continue
        
        if [[ "$line" =~ ^([a-zA-Z_]+):[[:space:]]*(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Remove quotes
            value=$(echo "$value" | sed -e 's/^["\x27]//' -e 's/["\x27]$//')
            
            case "$key" in
                tags)
                    FRONTMATTER_TAGS="$value"
                    ;;
                status)
                    FRONTMATTER_STATUS="$value"
                    ;;
                auto)
                    FRONTMATTER_AUTO="$value"
                    ;;
                gist)
                    FRONTMATTER_GIST="$value"
                    ;;
                publisher)
                    FRONTMATTER_PUBLISHER="$value"
                    ;;
                image|cover_image|cover|hero)
                    FRONTMATTER_COVER_IMAGE="$value"
                    ;;
                title)
                    FRONTMATTER_TITLE="$value"
                    ;;
                subtitle)
                    FRONTMATTER_SUBTITLE="$value"
                    ;;
            esac
        fi
    done <<< "$frontmatter"
    
    log_debug "Parsed: tags='$FRONTMATTER_TAGS', status='$FRONTMATTER_STATUS', auto='$FRONTMATTER_AUTO', gist='$FRONTMATTER_GIST', publisher='$FRONTMATTER_PUBLISHER', cover_image='$FRONTMATTER_COVER_IMAGE', title='$FRONTMATTER_TITLE', subtitle='$FRONTMATTER_SUBTITLE'"
    
    return 0
}

get_frontmatter_value() {
    local key="$1"
    
    case "$key" in
        tags) echo "$FRONTMATTER_TAGS" ;;
        status) echo "$FRONTMATTER_STATUS" ;;
        auto) echo "$FRONTMATTER_AUTO" ;;
        gist) echo "$FRONTMATTER_GIST" ;;
        publisher) echo "$FRONTMATTER_PUBLISHER" ;;
        cover_image) echo "$FRONTMATTER_COVER_IMAGE" ;;
        title) echo "$FRONTMATTER_TITLE" ;;
        subtitle) echo "$FRONTMATTER_SUBTITLE" ;;
        *) echo "" ;;
    esac
}