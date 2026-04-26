#!/bin/bash
# .github/scripts/lib/tags.sh - Generic tag utilities (platform agnostic)

# Guard against sourcing without logging
if ! declare -F log_debug >/dev/null 2>&1; then
    echo "ERROR: logging.sh must be sourced before tags.sh" >&2
    return 1 2>/dev/null || exit 1
fi

# ============================================================================
# Core Tag Sanitization
# ============================================================================

# Check if iconv is available
ICONV_AVAILABLE=false
if command -v iconv >/dev/null 2>&1; then
    ICONV_AVAILABLE=true
fi

# Normalize accented characters to ASCII
normalize_accents() {
    local text="$1"
    if [[ "$ICONV_AVAILABLE" == "true" ]]; then
        echo "$text" | iconv -f utf-8 -t ascii//translit 2>/dev/null || echo "$text"
    else
        # Return as-is if iconv not available
        echo "$text"
    fi
}

# Basic tag sanitization - common for ALL platforms (no platform-specific rules)
sanitize_tag() {
    local tag="$1"
    
    # Trim whitespace
    local sanitized=$(echo "$tag" | xargs)
    
    # Normalize accents
    sanitized=$(normalize_accents "$sanitized")
    
    # Convert to lowercase
    sanitized=$(echo "$sanitized" | tr '[:upper:]' '[:lower:]')
    
    # Replace spaces with underscores
    sanitized=$(echo "$sanitized" | sed 's/[[:space:]]/_/g')
    
    # Remove invalid characters (only keep a-z, 0-9, underscore, hyphen)
    sanitized=$(echo "$sanitized" | sed 's/[^a-z0-9_-]//g')
    
    # Remove multiple consecutive underscores/hyphens
    sanitized=$(echo "$sanitized" | sed 's/[_\-][_\-]*/_/g')
    
    # Remove leading/trailing underscores/hyphens
    sanitized=$(echo "$sanitized" | sed 's/^[-_]//' | sed 's/[-_]$//')
    
    # Ensure minimum length
    if [[ ${#sanitized} -lt 1 ]]; then
        log_debug "Tag sanitization resulted in empty string for: '$tag'"
        return 1
    fi
    
    echo "$sanitized"
}

# Parse comma-separated tags into array (preserves order, removes duplicates)
parse_tags() {
    local tags_string="$1"
    local -n result_array=$2
    
    result_array=()
    
    if [[ -z "$tags_string" ]]; then
        return 0
    fi
    
    IFS=',' read -ra raw_tags <<< "$tags_string"
    
    for raw_tag in "${raw_tags[@]}"; do
        local sanitized=$(sanitize_tag "$raw_tag" 2>/dev/null)
        
        if [[ -n "$sanitized" ]]; then
            # Check for duplicates
            local duplicate=false
            for existing in "${result_array[@]}"; do
                if [[ "$existing" == "$sanitized" ]]; then
                    duplicate=true
                    break
                fi
            done
            
            if [[ "$duplicate" == "false" ]]; then
                result_array+=("$sanitized")
                log_debug "Tag sanitized: '$raw_tag' -> '$sanitized'"
            else
                log_debug "Duplicate tag skipped: '$sanitized'"
            fi
        else
            log_debug "Tag sanitization failed for: '$raw_tag'"
        fi
    done
    
    log_debug "parse_tags: input='$tags_string', output=${result_array[*]} (${#result_array[@]} tags)"
}

# Convert tag array to JSON array
tags_to_json() {
    local -n input_tags=$1
    local json="["
    
    for i in "${!input_tags[@]}"; do
        if [[ $i -gt 0 ]]; then
            json+=","
        fi
        # Escape double quotes in tags
        local escaped_tag="${input_tags[$i]//\"/\\\"}"
        json+="\"$escaped_tag\""
    done
    json+="]"
    
    echo "$json"
}

# Convert tag array to comma-separated string
tags_to_string() {
    local -n input_tags=$1
    local result=""
    
    for tag in "${input_tags[@]}"; do
        if [[ -n "$result" ]]; then
            result+=","
        fi
        result+="$tag"
    done
    
    echo "$result"
}

# Validate tag against platform-specific constraints
validate_tag_for_platform() {
    local tag="$1"
    local platform="$2"
    local max_length="${3:-25}"
    
    if [[ ${#tag} -lt 1 ]]; then
        return 1
    fi
    
    if [[ ${#tag} -gt $max_length ]]; then
        log_debug "Tag too long for $platform: ${#tag} > $max_length"
        return 1
    fi
    
    case "$platform" in
        devto)
            # DEV.to: alphanumeric, 2-30 chars
            if [[ ${#tag} -lt 2 ]]; then
                return 1
            fi
            ;;
        medium)
            # Medium: alphanumeric with hyphens, 1-25 chars
            if [[ ! "$tag" =~ ^[a-z0-9-]+$ ]]; then
                return 1
            fi
            ;;
        hashnode)
            # Hashnode: alphanumeric only
            if [[ ! "$tag" =~ ^[a-z0-9]+$ ]]; then
                return 1
            fi
            ;;
    esac
    
    return 0
}