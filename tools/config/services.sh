#!/bin/bash
# tools/config/services.sh - Single source of truth for all services

# Service definitions
# Format: "service_name|fields|display_name|icon|requires_oauth|doc_url"
declare -A SERVICE_CONFIG=(
    ["devto"]="devto|token|Dev.to|📚|false|https://dev.to/settings/account"
    ["hashnode"]="hashnode|token,publication_id|Hashnode|📚|false|https://hashnode.com/settings/developer"
    # Medium legacy API
    ["medium"]="medium|token|Medium|📚|false|https://medium.com/me/settings"
    # Medium OAUTH not implement ATM
    #["medium"]="medium|client_id,client_secret,access_token,refresh_token|Medium|📚|true|https://medium.com/oauth-register"
    ["twitter"]="twitter|client_id,client_secret,access_token,refresh_token|X (Twitter)|📚|true|https://developer.twitter.com/en/portal/dashboard"
    ["linkedin"]="linkedin|client_id,client_secret,access_token,refresh_token|LinkedIn|📚|true|https://www.linkedin.com/developers/apps"
)

# Helper functions
get_service_fields() {
    local service="$1"
    local config="${SERVICE_CONFIG[$service]}"
    echo "$config" | cut -d'|' -f2 | tr ',' ' '
}

get_service_display_name() {
    local service="$1"
    local config="${SERVICE_CONFIG[$service]}"
    echo "$config" | cut -d'|' -f3
}

get_service_icon() {
    local service="$1"
    local config="${SERVICE_CONFIG[$service]}"
    echo "$config" | cut -d'|' -f4
}

get_service_requires_oauth() {
    local service="$1"
    local config="${SERVICE_CONFIG[$service]}"
    echo "$config" | cut -d'|' -f5
}

get_service_doc_url() {
    local service="$1"
    local config="${SERVICE_CONFIG[$service]}"
    echo "$config" | cut -d'|' -f6
}

# Get all services (preserves order)
get_all_services() {
    echo "devto hashnode medium twitter linkedin"
}

# Get required fields for a service (returns array via nameref)
get_required_fields() {
    local service="$1"
    local -n result=$2
    result=()
    
    for field in $(get_service_fields "$service"); do
        result+=("$field")
    done
}

# Check if a field is required for a service
is_field_required() {
    local service="$1"
    local field="$2"
    local fields=$(get_service_fields "$service")
    
    for f in $fields; do
        if [[ "$f" == "$field" ]]; then
            return 0
        fi
    done
    return 1
}

# Get service help text for a specific field
get_field_help() {
    local service="$1"
    local field="$2"
    
    case "$field" in
        token)
            echo "Get your API token from: $(get_service_doc_url "$service")"
            ;;
        publication_id)
            echo "Found in your Hashnode dashboard URL after 'https://hashnode.com/'"
            ;;
        client_id|client_secret)
            echo "Register an OAuth app at: $(get_service_doc_url "$service")"
            ;;
        access_token|refresh_token)
            echo "Obtained via OAuth flow: ./tools/pipepub.sh oauth $service"
            ;;
        *)
            echo ""
            ;;
    esac
}