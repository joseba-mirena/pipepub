#!/bin/bash
# tools/lib/services.sh - Service-agnostic loader from pipeline configs
# Single source of truth - reads from .github/config/services/*.conf
# Priority: Production first, then development overrides

if [[ -n "${_SERVICES_SH_LOADED:-}" ]]; then
    return 0
fi
readonly _SERVICES_SH_LOADED=1

# Get production registry file
get_prod_registry() {
    echo "$PIPELINE_ROOT/config/registry.conf"
}

# Get development registry file (git ignored, for local dev)
get_dev_registry() {
    echo "$SCRIPT_DIR/config/registry-dev.conf"
}

# Get pipeline service config directory
get_pipeline_config_dir() {
    echo "$PIPELINE_ROOT/config/services"
}

# Get development service config directory (for services in development)
# This directory is git-ignored, for local development only
get_dev_config_dir() {
    echo "$SCRIPT_DIR/config/services-dev"
}

# Get all service names from config files (pipeline + development)
get_all_services() {
    local services=()
    local seen_names=()
    
    # Helper to add service if not seen
    add_service() {
        local name="$1"
        for seen in "${seen_names[@]}"; do
            if [[ "$seen" == "$name" ]]; then
                return 1
            fi
        done
        seen_names+=("$name")
        services+=("$name")
        return 0
    }
    
    # 1. Load from production registry FIRST (base services)
    local prod_registry=$(get_prod_registry)
    if [[ -f "$prod_registry" ]]; then
        while IFS='|' read -r name rest; do
            [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
            name=$(echo "$name" | xargs)
            add_service "$name"
        done < "$prod_registry"
    fi
    
    # 2. Load from development registry (adds new services, can override existing)
    local dev_registry=$(get_dev_registry)
    if [[ -f "$dev_registry" ]]; then
        while IFS='|' read -r name rest; do
            [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
            name=$(echo "$name" | xargs)
            
            # If service already exists in seen_names, remove it (dev override)
            for i in "${!seen_names[@]}"; do
                if [[ "${seen_names[$i]}" == "$name" ]]; then
                    unset 'seen_names[$i]'
                    # Remove from services array
                    for j in "${!services[@]}"; do
                        if [[ "${services[$j]}" == "$name" ]]; then
                            unset 'services[$j]'
                        fi
                    done
                    break
                fi
            done
            add_service "$name"
        done < "$dev_registry"
    fi
    
    # Sort and return
    printf '%s\n' "${services[@]}" | sort -u | tr '\n' ' '
}

# Load service config and extract a specific value
# Priority: Production config first, then dev override
get_service_config_value() {
    local service="$1"
    local key="$2"
    local default="${3:-}"
    local config_file=""
    
    # Check production config first
    local pipeline_dir=$(get_pipeline_config_dir)
    if [[ -f "$pipeline_dir/${service}.conf" ]]; then
        config_file="$pipeline_dir/${service}.conf"
    fi
    
    # Then check development config (overrides production)
    local dev_dir=$(get_dev_config_dir)
    if [[ -f "$dev_dir/${service}.conf" ]]; then
        config_file="$dev_dir/${service}.conf"
    fi
    
    if [[ -f "$config_file" ]]; then
        # Extract value, remove quotes
        local value=$(grep "^${key}=" "$config_file" 2>/dev/null | cut -d'=' -f2- | sed 's/^["\x27]//;s/["\x27]$//')
        if [[ -n "$value" ]]; then
            echo "$value"
            return 0
        fi
    fi
    
    echo "$default"
}

# Get service display name
get_service_display_name() {
    local service="$1"
    local name=$(get_service_config_value "$service" "SERVICE_DISPLAY")
    
    if [[ -n "$name" ]]; then
        echo "$name"
    else
        # Capitalize service name as fallback
        echo "${service^}"
    fi
}

# Get required fields for secret storage (from registry)
# Priority: Production registry first, then dev override
get_service_fields() {
    local service="$1"
    local fields=""
    
    # Check production registry first
    local prod_registry=$(get_prod_registry)
    if [[ -f "$prod_registry" ]]; then
        while IFS='|' read -r name handler_file required_fields; do
            [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
            name=$(echo "$name" | xargs)
            if [[ "$name" == "$service" ]]; then
                fields=$(echo "$required_fields" | xargs)
                break
            fi
        done < "$prod_registry"
    fi
    
    # Then check dev registry (overrides production)
    if [[ -z "$fields" ]]; then
        local dev_registry=$(get_dev_registry)
        if [[ -f "$dev_registry" ]]; then
            while IFS='|' read -r name handler_file required_fields; do
                [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
                name=$(echo "$name" | xargs)
                if [[ "$name" == "$service" ]]; then
                    fields=$(echo "$required_fields" | xargs)
                    break
                fi
            done < "$dev_registry"
        fi
    fi
    
    # No fallback - if not found, return error
    if [[ -z "$fields" ]]; then
        echo "ERROR: No required fields defined for service: $service" >&2
        return 1
    fi
    
    echo "$fields"
}

# Get help text for a specific service field
get_field_help() {
    local service="$1"
    local field="$2"
    
    # Get documentation URL from service config
    local doc_url=$(get_service_config_value "$service" "SERVICE_DOC_URL")
    
    if [[ -n "$doc_url" ]]; then
        echo "Get your $field from: $doc_url"
    else
        # Generic message when no doc URL available
        echo "Enter your $field for $service"
    fi
}

# Get documentation URL for service
get_service_doc_url() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_DOC_URL" ""
}

# Check if service requires OAuth flow
get_service_requires_oauth() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_REQUIRES_OAUTH" "false"
}

# Check if service fetches user_id dynamically (e.g., Medium)
get_service_fetches_user_id() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_FETCHES_USER_ID" "false"
}

# Get service auth type (Bearer, api-key, etc.)
get_service_auth_type() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_AUTH_TYPE" "Bearer"
}

# Get service endpoint URL
get_service_endpoint() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_ENDPOINT" ""
}

# Get service handler function name
get_service_handler_func() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_HANDLER_FUNC" "publish_to_${service}"
}

# Get max tags for service
get_service_max_tags() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_MAX_TAGS" "5"
}

# Get gist format for service
get_service_gist_format() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_GIST_FORMAT" "%s"
}

# Get default status for service
get_service_default_status() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_DEFAULT_STATUS" "draft"
}

# Get default auto-publish for service
get_service_default_auto() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_DEFAULT_AUTO" "true"
}

# Get tag pattern for service
get_service_tag_pattern() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_TAG_PATTERN" "^[a-z0-9_-]+$"
}

# Get min tag length for service
get_service_tag_min_length() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_TAG_MIN_LENGTH" "1"
}

# Get max tag length for service
get_service_tag_max_length() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_TAG_MAX_LENGTH" "25"
}

# Check if service supports subtitle
get_service_supports_subtitle() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_SUPPORTS_SUBTITLE" "false"
}

# Check if service supports cover image
get_service_supports_cover_image() {
    local service="$1"
    get_service_config_value "$service" "SERVICE_SUPPORTS_COVER_IMAGE" "false"
}

# Get handler file name from registry
# Priority: Production registry first, then dev override
get_service_handler_file() {
    local service="$1"
    local handler_file=""
    
    # Check production registry first
    local prod_registry=$(get_prod_registry)
    if [[ -f "$prod_registry" ]]; then
        while IFS='|' read -r name handler_file_tmp required_fields; do
            [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
            name=$(echo "$name" | xargs)
            if [[ "$name" == "$service" ]]; then
                handler_file=$(echo "$handler_file_tmp" | xargs)
                break
            fi
        done < "$prod_registry"
    fi
    
    # Then check dev registry (overrides production)
    if [[ -z "$handler_file" ]]; then
        local dev_registry=$(get_dev_registry)
        if [[ -f "$dev_registry" ]]; then
            while IFS='|' read -r name handler_file_tmp required_fields; do
                [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
                name=$(echo "$name" | xargs)
                if [[ "$name" == "$service" ]]; then
                    handler_file=$(echo "$handler_file_tmp" | xargs)
                    break
                fi
            done < "$dev_registry"
        fi
    fi
    
    # Fallback to service name
    if [[ -z "$handler_file" ]]; then
        handler_file="${service}.sh"
    fi
    
    echo "$handler_file"
}

# Get handler file path (checks pipeline first, then dev override)
get_handler_path() {
    local service="$1"
    local handler_file=$(get_service_handler_file "$service")
    
    # Check pipeline handlers first (production)
    if [[ -f "$PIPELINE_ROOT/scripts/handlers/${handler_file}" ]]; then
        echo "$PIPELINE_ROOT/scripts/handlers/${handler_file}"
        return 0
    fi
    
    # Then check tools/handlers-dev/ (development override)
    if [[ -f "$SCRIPT_DIR/handlers-dev/${handler_file}" ]]; then
        echo "$SCRIPT_DIR/handlers-dev/${handler_file}"
        return 0
    fi
    
    return 1
}
