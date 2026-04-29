#!/bin/bash
# tools/lib/common.sh - Common functions for all tools

if [[ -n "${_COMMON_SH_LOADED:-}" ]]; then
    return 0
fi

readonly _COMMON_SH_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export APP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export PIPELINE_ROOT="$APP_ROOT/.github"

# ============================================================================
# Environment File Loading
# ============================================================================

# Check if .env file exists in project root
check_env_file() {
    if [[ -f "$APP_ROOT/.env" ]]; then
        return 0
    else
        # Copy .env.example to .env if does not exists
        local env_example="$APP_ROOT/.env.example"
        if [[ -f "$env_example" ]]; then
            cp "$env_example" "$APP_ROOT/.env"
            return 0
        fi
        return 1
    fi
}

# Load .env file if it exists
load_env() {
    local env_file="$APP_ROOT/.env"
    
    if [[ -f "$env_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip comments and empty lines
            [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
            # Remove leading/trailing whitespace
            line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
            
            # Extract key and value
            if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$ ]]; then
                local key="${BASH_REMATCH[1]}"
                local value="${BASH_REMATCH[2]}"
                
                # Strip quotes if present
                if [[ "$value" =~ ^\'(.*)\'$ ]] || [[ "$value" =~ ^\"(.*)\"$ ]]; then
                    value="${BASH_REMATCH[1]}"
                fi
                
                export "$key=$value"
            fi
        done < "$env_file"
        return 0
    else
        return 1
    fi
}

# Auto-load .env
check_env_file
load_env

# Set DEBUG based on LOG_LEVEL
if [[ "${LOG_LEVEL:-}" == "debug" ]]; then
    DEBUG=true
else
    DEBUG=false
fi

# Load pipeline-based service definitions (single source of truth)
source "$SCRIPT_DIR/lib/services.sh"
source "$SCRIPT_DIR/lib/keychain.sh"
source "$SCRIPT_DIR/lib/panel.sh"
source "$SCRIPT_DIR/lib/options.sh"

# Get list of all services (delegates to services.sh)
get_services() {
    get_all_services
}

# Check and auto-create master key if needed (silent, no output)
ensure_master_key() {
    local master=$(get_secret "_master")
    if [[ -z "$master" ]]; then
        local master_key=$(openssl rand -base64 32)
        if set_secret "_master" "$master_key"; then
            return 0
        else
            return 1
        fi
    fi
    return 0
}

# Get status of a service
get_service_status() {
    local service="$1"
    local required_fields=$(get_service_fields "$service")
    local has_all=true
    local has_any=false
    
    for field in $required_fields; do
        # Use uppercase field names for keychain (consistent with pipeline)
        if secret_exists "$field"; then
            has_any=true
        else
            has_all=false
        fi
    done
    
    if [[ "$has_all" == "true" ]]; then
        echo "success"
    elif [[ "$has_any" == "true" ]]; then
        echo "partial"
    else
        echo "missing"
    fi
}

# Load service secrets into environment
load_service_secrets() {
    local service="$1"
    local fields=$(get_service_fields "$service")
    
    for field in $fields; do
        # Use uppercase field name as the secret key (consistent with pipeline)
        local value=$(get_secret "$field")
        if [[ -n "$value" ]]; then
            export "$field"="$value"
        fi
    done
}

# Load GitHub token into environment
load_github_token() {
    local token=$(get_secret "GH_PAT_GIST_TOKEN")
    if [[ -n "$token" ]]; then
        export GH_PAT_GIST_TOKEN="$token"
        return 0
    fi
    return 1
}

# Load all configured secrets
load_all_secrets() {
    for service in $(get_services); do
        load_service_secrets "$service"
    done
    load_github_token
}

# Check if running in GitHub Actions
is_github_actions() {
    [[ -n "${GITHUB_ACTIONS:-}" ]]
}

# Get all services that are configured
get_configured_services() {
    local configured=()
    for service in $(get_services); do
        local status=$(get_service_status "$service")
        if [[ "$status" == "success" ]] || [[ "$status" == "partial" ]]; then
            configured+=("$service")
        fi
    done
    echo "${configured[@]}"
}