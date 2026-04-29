#!/bin/bash
# .github/scripts/lib/common.sh - Common utility functions

# Guard against sourcing without logging
if ! declare -F log_error >/dev/null 2>&1; then
    echo "ERROR: logging.sh must be sourced before common.sh" >&2
    return 1 2>/dev/null || exit 1
fi

# These variables are set by main.sh:
# ROOT_DIR, DIR_CFG, DIR_HDL, DIR_LIB

# Retry configuration
export API_RETRY_COUNT=${API_RETRY_COUNT:-3}
export API_RETRY_DELAY=${API_RETRY_DELAY:-2}
export API_TIMEOUT=${API_TIMEOUT:-30}
export API_CONNECT_TIMEOUT=${API_CONNECT_TIMEOUT:-10}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure required commands are available
check_dependencies() {
    local deps=("jq" "curl")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing[*]}"
        log_error "Please install: sudo apt-get install ${missing[*]}"
        return 1
    fi
    
    # Check for optional dependencies
    if ! command_exists "iconv"; then
        log_warning "iconv not found - accent normalization will be limited"
    fi
    
    return 0
}

# Create temp file with cleanup trap
create_temp_file() {
    local prefix="${1:-publisher}"
    local temp_file=$(mktemp "/tmp/${prefix}_XXXXXX" 2>/dev/null || mktemp)
    
    # Register cleanup on exit
    trap 'rm -f "$temp_file"' EXIT
    
    echo "$temp_file"
}

# Safe JSON escape
json_escape() {
    local string="$1"
    echo "$string" | jq -Rsa .
}

# Validate URL format
validate_url() {
    local url="$1"
    if [[ -z "$url" ]]; then
        return 0
    fi
    
    if [[ "$url" =~ ^https?:// ]]; then
        return 0
    else
        log_error "Invalid URL: $url"
        return 1
    fi
}

# Get timestamp in ISO format
get_iso_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}
