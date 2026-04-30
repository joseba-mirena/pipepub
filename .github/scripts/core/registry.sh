#!/bin/bash
# core/registry.sh - Lazy loading service registry

# Prevent double sourcing
if [[ -n "${_REGISTRY_SH_LOADED:-}" ]]; then
    return 0
fi
readonly _REGISTRY_SH_LOADED=1

# ============================================================================
# Phase 1: Check service availability (token + config + handler files)
# ============================================================================

# Get required fields for a service from registry
_get_service_required_fields() {
    local service="$1"
    local registry_file="${2:-$DIR_CFG/registry.conf}"
    local fields=""
    
    if [[ ! -f "$registry_file" ]]; then
        echo ""
        return 1
    fi
    
    while IFS='|' read -r name handler_file required_fields || [[ -n "$name" ]]; do
        [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
        name=$(echo "$name" | xargs)
        if [[ "$name" == "$service" ]]; then
            fields=$(echo "$required_fields" | xargs)
            break
        fi
    done < "$registry_file"
    
    echo "$fields"
}

# Check if a service is available (can be loaded when needed)
is_service_available() {
    local service="$1"
    
    # Get required fields from registry
    local required_fields=$(_get_service_required_fields "$service")
    if [[ -z "$required_fields" ]]; then
        log_debug "Service $service: not found in registry"
        return 1
    fi
    
    # Check all required fields (tokens) exist
    local missing_fields=""
    for field in $required_fields; do
        if [[ -z "${!field:-}" ]]; then
            missing_fields="$missing_fields $field"
        fi
    done
    
    if [[ -n "$missing_fields" ]]; then
        log_debug "Service $service: missing token(s):$missing_fields"
        return 1
    fi
    
    # Check config file exists
    local config_file="$DIR_CFG/services/${service}.conf"
    if [[ ! -f "$config_file" ]]; then
        log_warning "Service $service: config file not found: $config_file"
        return 1
    fi
    
    # Check handler file exists
    local handler_file="$DIR_HDL/${service}.sh"
    if [[ ! -f "$handler_file" ]]; then
        log_warning "Service $service: handler file not found: $handler_file"
        return 1
    fi
    
    log_info "Service $service available"
    return 0
}

# Get all available services (from registry, filtered by availability)
get_available_services() {
    local -n result=$1
    local registry_file="${2:-$DIR_CFG/registry.conf}"
    
    result=()
    
    if [[ ! -f "$registry_file" ]]; then
        log_error "Registry file not found: $registry_file"
        return 1
    fi
    
    while IFS='|' read -r name handler_file required_fields || [[ -n "$name" ]]; do
        [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
        name=$(echo "$name" | xargs)
        
        if is_service_available "$name"; then
            result+=("$name")
            log_debug "Service $name registered as available"
        else
            log_debug "Service $name not available"
        fi
    done < "$registry_file"
    
    return 0
}

# ============================================================================
# Phase 2: Load service (config + handler) when needed
# ============================================================================

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

# Load a service (config + handler) and validate it's ready for use
# Returns 0 if successful, 1 otherwise
load_service() {
    local service="$1"
    
    # Verify service is available first
    if ! is_service_available "$service"; then
        log_error "Service $service not available, cannot load"
        return 1
    fi
    
    # Load config
    if ! load_service_config "$service"; then
        log_error "Failed to load config for service: $service"
        return 1
    fi
    
    # Load handler
    if ! load_service_handler "$service"; then
        log_error "Failed to load handler for service: $service"
        return 1
    fi
    
    # Validate handler function exists
    if [[ -z "${SERVICE_HANDLER_FUNC:-}" ]]; then
        log_error "SERVICE_HANDLER_FUNC not defined in $service.conf"
        return 1
    fi
    
    if ! declare -F "$SERVICE_HANDLER_FUNC" >/dev/null 2>&1; then
        log_error "Handler function '$SERVICE_HANDLER_FUNC' not found for $service"
        return 1
    fi
    
    log_debug "Service $service loaded and ready"
    return 0
}

# ============================================================================
# Legacy compatibility (deprecated, use get_available_services + load_service)
# ============================================================================

# Register and load all active services (deprecated - use lazy loading)
# Kept for backward compatibility
register_active_services() {
    local -n active_ref=$1
    active_ref=()
    
    local -a available_services=()
    get_available_services available_services
    
    # For backward compatibility, load all available services immediately
    for service in "${available_services[@]}"; do
        if load_service "$service"; then
            active_ref+=("$service")
            log_success "$SERVICE_DISPLAY publisher active"
        else
            log_warning "$SERVICE_DISPLAY publisher inactive"
        fi
    done
    
    return 0
}

# ============================================================================
# Service Configuration Getters
# ============================================================================

# Get service configuration value (must be called after load_service_config)
get_service_config() {
    local service_name="$1"
    local config_key="$2"
    local default="${3:-}"
    
    case "$config_key" in
        display) echo "${SERVICE_DISPLAY:-$service_name}" ;;
        auth_type) echo "${SERVICE_AUTH_TYPE:-Bearer}" ;;
        endpoint) echo "${SERVICE_ENDPOINT:-}" ;;
        handler_func) echo "${SERVICE_HANDLER_FUNC:-}" ;;
        max_tags) echo "${SERVICE_MAX_TAGS:-5}" ;;
        min_tag_length) echo "${SERVICE_TAG_MIN_LENGTH:-1}" ;;
        max_tag_length) echo "${SERVICE_TAG_MAX_LENGTH:-25}" ;;
        tag_pattern) echo "${SERVICE_TAG_PATTERN:-^[a-z0-9_-]+$}" ;;
        supports_subtitle) echo "${SERVICE_SUPPORTS_SUBTITLE:-false}" ;;
        supports_cover_image) echo "${SERVICE_SUPPORTS_COVER_IMAGE:-false}" ;;
        fetches_user_id) echo "${SERVICE_FETCHES_USER_ID:-false}" ;;
        requires_oauth) echo "${SERVICE_REQUIRES_OAUTH:-false}" ;;
        doc_url) echo "${SERVICE_DOC_URL:-}" ;;
        default_status) echo "${SERVICE_DEFAULT_STATUS:-draft}" ;;
        default_auto) echo "${SERVICE_DEFAULT_AUTO:-true}" ;;
        *) echo "$default" ;;
    esac
}

# ============================================================================
# Validation
# ============================================================================

# Service tokens validation (checks if any service is available)
validate_service_tokens() {
    local -a available_services=()
    get_available_services available_services
    
    if [[ ${#available_services[@]} -eq 0 ]]; then
        log_error "No available services found in registry"
        return 1
    fi
    
    return 0
}