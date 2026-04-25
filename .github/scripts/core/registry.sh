#!/bin/bash
# core/registry.sh - Lazy loading service registry

# Prevent double sourcing
if [[ -n "${_REGISTRY_SH_LOADED:-}" ]]; then
    return 0
fi
readonly _REGISTRY_SH_LOADED=1

# Load minimal registry and check tokens
get_active_services() {
    local -n result=$1
    local registry_file="${2:-$DIR_CFG/registry.conf}"
    
    # Clear result array
    result=()
    
    # Check if registry file exists
    if [[ ! -f "$registry_file" ]]; then
        log_error "Registry file not found: $registry_file"
        return 1
    fi
    
    while IFS='|' read -r name token_var handler_file; do
        # Skip comments and empty lines
        [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
        
        # Trim whitespace
        name=$(echo "$name" | xargs)
        token_var=$(echo "$token_var" | xargs)
        handler_file=$(echo "$handler_file" | xargs)
        
        # Check if token exists
        if [[ -n "${!token_var:-}" ]]; then
            result+=("$name|$token_var|$handler_file")
            log_debug "Service $name active (token found)"
        else
            log_debug "Service $name inactive (no token)"
        fi
    done < "$registry_file"
    
    return 0
}

# Load full configuration for a service
load_service_config() {
    local service_name="$1"
    local config_file="$DIR_CFG/services/${service_name}.conf"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        log_debug "Loaded config for service: $service_name"
        return 0
    else
        log_error "Config not found for service: $service_name"
        return 1
    fi
}

# Lazy load handler for a service
load_service_handler() {
    local service_name="$1"
    local handler_file="$DIR_HDL/${service_name}.sh"
    
    if [[ -f "$handler_file" ]]; then
        source "$handler_file"
        log_debug "Loaded handler for service: $service_name"
        return 0
    else
        log_error "Handler not found for service: $service_name"
        return 1
    fi
}

# Register and load all active services
register_active_services() {
    local -n active_ref=$1
    active_ref=()
    
    local -a active_entries=()
    get_active_services active_entries
    
    for entry in "${active_entries[@]}"; do
        IFS='|' read -r name token_var handler_file <<< "$entry"
        
        # Load full config
        if load_service_config "$name"; then
            # Load handler
            if load_service_handler "$name"; then
                # Verify handler function exists
                if declare -F "$SERVICE_HANDLER_FUNC" >/dev/null 2>&1; then
                    active_ref+=("$name")
                    log_success "$SERVICE_DISPLAY publisher active"
                else
                    log_warning "Handler function '$SERVICE_HANDLER_FUNC' not found for $name"
                fi
            fi
        fi
    done
    
    return 0
}

# Get service configuration value (must be called after load_service_config)
get_service_config() {
    local service_name="$1"
    local config_key="$2"
    local default="${3:-}"
    
    # The config variables are already in scope from load_service_config
    case "$config_key" in
        display) echo "${SERVICE_DISPLAY:-$service_name}" ;;
        auth_type) echo "${SERVICE_AUTH_TYPE:-Bearer}" ;;
        endpoint) echo "${SERVICE_ENDPOINT:-}" ;;
        handler_func) echo "${SERVICE_HANDLER_FUNC:-publish_to_$service_name}" ;;
        max_tags) echo "${SERVICE_MAX_TAGS:-5}" ;;
        supports_subtitle) echo "${SERVICE_SUPPORTS_SUBTITLE:-false}" ;;
        supports_cover_image) echo "${SERVICE_SUPPORTS_COVER_IMAGE:-false}" ;;
        gist_format) echo "${SERVICE_GIST_FORMAT:-%s}" ;;
        requires_publication_id) echo "${SERVICE_REQUIRES_PUBLICATION_ID:-false}" ;;
        requires_user_id) echo "${SERVICE_REQUIRES_USER_ID:-false}" ;;
        *) echo "$default" ;;
    esac
}

# Service tokens validation
validate_service_tokens() {
    local -a active_entries=()
    get_active_services active_entries
    
    if [[ ${#active_entries[@]} -eq 0 ]]; then
        log_error "No active services found with valid tokens"
        return 1
    fi
    
    return 0
}