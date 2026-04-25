#!/bin/bash
# tools/lib/keychain.sh - OS keychain abstraction

# Check OS dependencies before any operation (returns 0/1, no output)
check_os_dependencies() {
    case "$OSTYPE" in
        darwin*)
            if ! command -v security &>/dev/null; then
                return 1
            fi
            ;;
        linux*)
            if ! command -v secret-tool &>/dev/null; then
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

# Get app name - priority order:
# 1. Environment variable (from .env)
# 2. Repository name (git config)
# 3. Default
get_app_name() {
    if [[ -n "${PUBLISHER_DEV_APP_NAME:-}" ]]; then
        echo "$PUBLISHER_DEV_APP_NAME"
    elif git rev-parse --show-toplevel >/dev/null 2>&1; then
        basename "$(git rev-parse --show-toplevel)"
    else
        echo "pipepub"
    fi
}

# Get keychain service name
get_service() {
    echo "$(get_app_name)-secrets"
}

# Store a secret
set_secret() {
    local key="$1"
    local value="$2"
    local service="$(get_service)"
    
    case "$OSTYPE" in
        darwin*)
            security add-generic-password -s "$service" -a "$key" -w "$value" 2>/dev/null
            ;;
        linux*)
            secret-tool store --label="$service" service "$service" key "$key" <<< "$value" 2>/dev/null
            ;;
    esac
}

# Retrieve a secret
get_secret() {
    local key="$1"
    local service="$(get_service)"
    
    case "$OSTYPE" in
        darwin*)
            security find-generic-password -s "$service" -a "$key" -w 2>/dev/null
            ;;
        linux*)
            secret-tool lookup service "$service" key "$key" 2>/dev/null
            ;;
    esac
}

# Delete a secret
delete_secret() {
    local key="$1"
    local service="$(get_service)"
    
    case "$OSTYPE" in
        darwin*)
            security delete-generic-password -s "$service" -a "$key" 2>/dev/null
            ;;
        linux*)
            secret-tool clear service "$service" key "$key" 2>/dev/null
            ;;
    esac
}

# Check if a secret exists
secret_exists() {
    local value=$(get_secret "$1")
    [[ -n "$value" ]]
}

# List all secrets for this app
list_secrets() {
    local service="$(get_service)"
    
    case "$OSTYPE" in
        darwin*)
            security dump-keychain 2>/dev/null | grep -A1 "$service" | grep "acct" | cut -d'"' -f2
            ;;
        linux*)
            secret-tool search service "$service" 2>/dev/null | grep "key:" | cut -d: -f2
            ;;
    esac
}