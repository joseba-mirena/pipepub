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

# ============================================================================
# Service-Agnostic Tag Validation (uses SERVICE_* variables from loaded config)
# ============================================================================

# Validate a single tag against service-specific rules
# Must be called after load_service_config for the target service
validate_tag_for_service() {
    local tag="$1"
    
    # Get service-specific validation rules from loaded config
    local min_length="${SERVICE_TAG_MIN_LENGTH:-1}"
    local max_length="${SERVICE_TAG_MAX_LENGTH:-25}"
    local pattern="${SERVICE_TAG_PATTERN:-^[a-z0-9_-]+$}"
    local display_name="${SERVICE_DISPLAY:-service}"
    
    if [[ -z "$tag" ]]; then
        log_debug "Empty tag rejected for $display_name"
        return 1
    fi
    
    if [[ ${#tag} -lt $min_length ]]; then
        log_debug "Tag too short for $display_name: '${#tag}' < $min_length"
        return 1
    fi
    
    if [[ ${#tag} -gt $max_length ]]; then
        log_debug "Tag too long for $display_name: '${#tag}' > $max_length"
        return 1
    fi
    
    if [[ ! "$tag" =~ $pattern ]]; then
        log_debug "Tag invalid for $display_name: '$tag' does not match pattern $pattern"
        return 1
    fi
    
    log_debug "Tag validated for $display_name: '$tag'"
    return 0
}

# Filter array of tags against service-specific rules
# Must be called after load_service_config for the target service
filter_tags_for_service() {
    local -n input_tags=$1
    local -n output_tags=$2
    local max_tags="${SERVICE_MAX_TAGS:-5}"
    local display_name="${SERVICE_DISPLAY:-service}"
    
    # Extract allowed characters from pattern for cleaning
    local pattern="${SERVICE_TAG_PATTERN:-^[a-z0-9_-]+$}"
    local allowed=$(echo "$pattern" | sed 's/\^\[\(.*\)\]+\$/\1/')
    
    output_tags=()
    
    for tag in "${input_tags[@]}"; do
        if [[ ${#output_tags[@]} -ge $max_tags ]]; then
            log_debug "Max tags ($max_tags) reached for $display_name, stopping"
            break
        fi
        
        if validate_tag_for_service "$tag"; then
            output_tags+=("$tag")
            log_debug "Tag accepted for $display_name: '$tag'"
        else
            # Try to clean the tag by removing disallowed characters
            local cleaned=$(echo "$tag" | sed "s/[^$allowed]//g")
            
            if [[ -n "$cleaned" ]] && validate_tag_for_service "$cleaned"; then
                output_tags+=("$cleaned")
                if [[ "$cleaned" != "$tag" ]]; then
                    log_debug "Tag cleaned for $display_name: '$tag' -> '$cleaned'"
                else
                    log_debug "Tag accepted for $display_name: '$cleaned'"
                fi
            else
                log_debug "Tag rejected for $display_name: '$tag'"
            fi
        fi
    done
    
    log_debug "filter_tags_for_service: ${#output_tags[@]} tags accepted out of ${#input_tags[@]} for $display_name"
}

# Process tags from string to filtered array in one step
# Must be called after load_service_config for the target service
process_tags_for_service() {
    local tags_string="$1"
    local -n result_array=$2
    
    # First parse the tags
    declare -a parsed_tags=()
    parse_tags "$tags_string" parsed_tags
    
    # Then filter them for this service
    filter_tags_for_service parsed_tags result_array
}

# ============================================================================
# Legacy Functions (kept for backward compatibility)
# ============================================================================

# Deprecated: Use validate_tag_for_service instead
validate_tag_for_platform() {
    log_warning "validate_tag_for_platform is deprecated. Use validate_tag_for_service after loading service config."
    
    local tag="$1"
    local platform="$2"
    
    # Map old platform names to service config expectations
    case "$platform" in
        devto|DEV.to)
            SERVICE_TAG_MIN_LENGTH="${SERVICE_TAG_MIN_LENGTH:-2}"
            SERVICE_TAG_MAX_LENGTH="${SERVICE_TAG_MAX_LENGTH:-30}"
            SERVICE_TAG_PATTERN="${SERVICE_TAG_PATTERN:-^[a-z0-9]+$}"
            ;;
        medium)
            SERVICE_TAG_MIN_LENGTH="${SERVICE_TAG_MIN_LENGTH:-1}"
            SERVICE_TAG_MAX_LENGTH="${SERVICE_TAG_MAX_LENGTH:-25}"
            SERVICE_TAG_PATTERN="${SERVICE_TAG_PATTERN:-^[a-z0-9-]+$}"
            ;;
        hashnode)
            SERVICE_TAG_MIN_LENGTH="${SERVICE_TAG_MIN_LENGTH:-1}"
            SERVICE_TAG_MAX_LENGTH="${SERVICE_TAG_MAX_LENGTH:-25}"
            SERVICE_TAG_PATTERN="${SERVICE_TAG_PATTERN:-^[a-z0-9]+$}"
            ;;
        *)
            SERVICE_TAG_MIN_LENGTH="${SERVICE_TAG_MIN_LENGTH:-1}"
            SERVICE_TAG_MAX_LENGTH="${SERVICE_TAG_MAX_LENGTH:-25}"
            SERVICE_TAG_PATTERN="${SERVICE_TAG_PATTERN:-^[a-z0-9_-]+$}"
            ;;
    esac
    
    validate_tag_for_service "$tag"
}