#!/bin/bash
# .github/scripts/main.sh - Main publisher pipeline orchestration
set -euo pipefail

# ============================================================================
# Context Detection
# ============================================================================
if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    export LOG_OUTPUT="console"
    export LOG_FILE=""
fi

# ============================================================================
# Path Initialization
# ============================================================================

DIR_SRC="$(dirname "${BASH_SOURCE[0]}")"
ROOT_DIR="$(cd "$DIR_SRC/.." && pwd)"

DIR_CFG="$ROOT_DIR/config"
DIR_HDL="$DIR_SRC/handlers"
DIR_LIB="$DIR_SRC/lib"

# ============================================================================
# Source Core Libraries
# ============================================================================

for lib in logging.sh common.sh api.sh validation.sh tags.sh content.sh frontmatter.sh; do
    if [[ ! -f "$DIR_LIB/$lib" ]]; then
        echo "ERROR: Required library not found: $DIR_LIB/$lib" >&2
        exit 1
    fi
    source "$DIR_LIB/$lib"
done

if [[ ! -f "$DIR_SRC/core/registry.sh" ]]; then
    echo "ERROR: Required module not found: $DIR_SRC/core/registry.sh" >&2
    exit 1
fi
source "$DIR_SRC/core/registry.sh"

# ============================================================================
# Global Variables
# ============================================================================

declare -a PROCESSED_FILES=()
declare -a AVAILABLE_SERVICES=()

FRONTMATTER_TAGS=""
FRONTMATTER_STATUS=""
FRONTMATTER_AUTO=""
FRONTMATTER_GIST=""
FRONTMATTER_PUBLISHER=""
FRONTMATTER_COVER_IMAGE=""
FRONTMATTER_TITLE=""
FRONTMATTER_SUBTITLE=""

# ============================================================================
# Helper Functions
# ============================================================================

get_files_to_process() {
    local target_folder="${1:-posts}"
    local files=()
    
    if [[ -n "${MANUAL_FILENAMES:-}" ]]; then
        IFS=' ' read -ra manual_files <<< "$MANUAL_FILENAMES"
        for file in "${manual_files[@]}"; do
            file=$(echo "$file" | xargs)
            local full_path="$target_folder/$file"
            if [[ -f "$full_path" ]]; then
                files+=("$full_path")
            else
                log_warning "File not found: $full_path"
            fi
        done
    else
        if git rev-parse HEAD~1 >/dev/null 2>&1; then
            while IFS= read -r file; do
                if [[ -n "$file" ]] && [[ -f "$file" ]]; then
                    files+=("$file")
                fi
            done < <(git diff --name-only --diff-filter=ACMR HEAD~1 HEAD 2>/dev/null | grep "^${target_folder}/.*\.md$" || true)
        else
            while IFS= read -r file; do
                if [[ -n "$file" ]]; then
                    files+=("$file")
                fi
            done < <(find "$target_folder" -name "*.md" -type f 2>/dev/null || true)
        fi
    fi
    
    printf '%s\n' "${files[@]}"
}

get_publisher_list() {
    local frontmatter_publisher="$1"
    local result=""
    
    if [[ -n "$frontmatter_publisher" ]]; then
        echo "$frontmatter_publisher"
        return
    fi
    
    for service in "${AVAILABLE_SERVICES[@]}"; do
        if [[ -n "$result" ]]; then
            result="$result,$service"
        else
            result="$service"
        fi
    done
    
    echo "$result"
}

should_process_service() {
    local service="$1"
    local publisher_list="$2"
    
    if [[ -z "$publisher_list" ]]; then
        return 0
    fi
    
    echo "$publisher_list" | tr ',' '\n' | grep -qi "^[[:space:]]*${service}[[:space:]]*$"
}

prepare_content() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        log_error "File not found: $file_path"
        return 1
    fi

    sed '1s/^\xEF\xBB\xBF//' "$file_path" | sed 's/\r$//'
}

process_file() {
    local file_path="$1"
    local title="$2"
    local subtitle="$3"
    local content="$4"
    local tags="$5"
    local status="$6"
    local cover_image="$7"
    local publisher_list="$8"
    local -n total_ops_ref=$9
    local -n success_ops_ref=${10}
    
    local -A results
    
    if [[ -z "${MANUAL_FILENAMES:-}" ]]; then
        local auto_publish="${FRONTMATTER_AUTO:-}"
        if [[ "$auto_publish" == "false" ]]; then
            log_info "Auto-publish disabled for: $file_path"
            return 0
        fi
    fi
    
    for service in "${AVAILABLE_SERVICES[@]}"; do
        if ! should_process_service "$service" "$publisher_list"; then
            log_info "$service not in publisher list for: $file_path"
            results["$service"]="not_requested"
            continue
        fi
        
        total_ops_ref=$((total_ops_ref + 1))
        
        # Lazy load the service (loads config + handler only when needed)
        if ! load_service "$service"; then
            log_error "Failed to load service: $service"
            results["$service"]="failed"
            continue
        fi
        
        local display_name=$(get_service_config "$service" "display")
        local handler_func=$(get_service_config "$service" "handler_func")
        
        local service_status="$status"
        if [[ -z "$service_status" ]]; then
            service_status=$(get_service_config "$service" "default_status")
        fi
        
        local service_auto="${FRONTMATTER_AUTO:-}"
        if [[ -z "$service_auto" ]]; then
            service_auto=$(get_service_config "$service" "default_auto")
        fi
        
        if [[ "$service_auto" == "false" ]] && [[ -z "${MANUAL_FILENAMES:-}" ]]; then
            log_info "Auto-publish disabled for $display_name on this file"
            results["$service"]="skipped_auto"
            continue
        fi
        
        log_info "Publishing to $display_name..."
        
        local max_retries=3
        local retry_count=0
        local success=false
        
        while [[ $retry_count -lt $max_retries ]]; do
            if [[ "${DRY_RUN:-false}" == "true" ]]; then
                log_info "DRY RUN: Would publish to $display_name"
                success=true
                break
            fi
            
            if $handler_func "$title" "$subtitle" "$content" "$tags" "$service_status" "$cover_image"; then
                success=true
                break
            else
                retry_count=$((retry_count + 1))
                if [[ $retry_count -lt $max_retries ]]; then
                    log_warning "Retry $retry_count/$max_retries for $display_name"
                    sleep $((retry_count * 2))
                fi
            fi
        done
        
        if [[ "$success" == true ]]; then
            results["$service"]="success"
            success_ops_ref=$((success_ops_ref + 1))
            log_success "Successfully published to $display_name"
        else
            results["$service"]="failed"
            log_error "Failed to publish to $display_name after $max_retries attempts"
        fi
    done
    
    log_info "Summary for $(basename "$file_path"):"
    for platform in "${!results[@]}"; do
        case "${results[$platform]}" in
            success)        log_info "  ✓ $platform: success" ;;
            failed)         log_error "  ✗ $platform: failed" ;;
            not_requested)  log_info "  ○ $platform: not in publisher list" ;;
            skipped_auto)   log_info "  ○ $platform: auto-publish disabled" ;;
        esac
    done
}

process_gist_tables_if_enabled() {
    local enable_gist="$1"
    local raw_content="$2"
    local file_path="$3"
    local title="$4"
    local gist_token="$5"
    local -n result_content=$6
    
    result_content="$raw_content"
    
    if [[ "$enable_gist" != "true" ]]; then
        log_debug "Gist tables disabled in frontmatter"
        return 0
    fi
    
    if [[ -z "$gist_token" ]]; then
        log_info "No GitHub token provided (GH_PAT_GIST_TOKEN not set)"
        return 0
    fi
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "DRY RUN: Would process markdown tables to gists"
        return 0
    fi
    
    log_info "Processing markdown tables to gists..."
    
    local gist_handler="$DIR_HDL/gist_tables.sh"
    if [[ ! -f "$gist_handler" ]]; then
        log_warning "Gist handler not found at $gist_handler"
        return 0
    fi
    
    source "$gist_handler" 2>/dev/null || true
    if declare -F process_gist_tables >/dev/null 2>&1; then
        local temp_stderr=$(mktemp)
        local temp_result=$(mktemp)
        
        if process_gist_tables "$raw_content" "$file_path" "$gist_token" "$title" > "$temp_result" 2> "$temp_stderr"; then
            result_content=$(cat "$temp_result")
            log_info "Tables processed successfully"
        else
            local error_msg=$(cat "$temp_stderr")
            log_warning "Table processing failed: $error_msg"
            log_warning "Using original content"
            result_content="$raw_content"
        fi
        
        rm -f "$temp_stderr" "$temp_result"
    else
        log_warning "Gist handler function not available"
    fi
    
    return 0
}

validate_required_environment() {
    if declare -F validate_service_tokens >/dev/null 2>&1; then
        if ! validate_service_tokens; then
            log_error "No valid service tokens found"
            return 1
        fi
    else
        log_debug "validate_service_tokens function not found, skipping validation"
    fi
    
    return 0
}

# ============================================================================
# Main Orchestration
# ============================================================================

main() {
    log_info "=== PipePub Pipeline ==="
    log_info "Repository: ${GITHUB_REPOSITORY:-local}"
    log_info "Branch: ${GITHUB_REF_NAME:-unknown}"
    
    if [[ -n "${MANUAL_FILENAMES:-}" ]]; then
        log_info "Mode: Manual trigger"
        log_info "Files: $MANUAL_FILENAMES"
    else
        log_info "Mode: Push trigger"
    fi
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_warning "DRY RUN MODE - No actual API calls will be made"
    fi
    
    if ! check_dependencies; then
        log_error "Dependency check failed"
        exit 1
    fi
    
    if ! validate_required_environment; then
        log_error "Environment validation failed"
        exit 1
    fi
    
    # Get available services (checks token + config + handler files)
    if ! declare -F get_available_services >/dev/null 2>&1; then
        log_error "get_available_services function not found"
        exit 1
    fi
    
    get_available_services AVAILABLE_SERVICES
    
    if [[ ${#AVAILABLE_SERVICES[@]} -eq 0 ]]; then
        log_error "No available services found"
        exit 1
    fi
    
    log_info "Available services:"
    for service in "${AVAILABLE_SERVICES[@]}"; do
        # Try to load config to get display name (without loading handler)
        if load_service_config "$service" 2>/dev/null; then
            local display_name=$(get_service_config "$service" "display")
            log_info "  • $display_name ($service)"
        else
            log_info "  • $service"
        fi
    done
    
    declare -a FILES_TO_PROCESS=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && FILES_TO_PROCESS+=("$file")
    done < <(get_files_to_process "posts")
    
    if [[ ${#FILES_TO_PROCESS[@]} -eq 0 ]]; then
        log_info "No markdown files to process"
        exit 0
    fi
    
    log_info "Found ${#FILES_TO_PROCESS[@]} file(s) to process"
    
    local total_operations=0
    local successful_operations=0
    
    for file_path in "${FILES_TO_PROCESS[@]}"; do
        [[ -z "$file_path" ]] && continue
        
        log_separator "━" 60
        log_info "Processing: $file_path"
        
        if [[ ! -f "$file_path" ]]; then
            log_error "File not found: $file_path"
            continue
        fi

        local current_content=$(prepare_content "$file_path")

        if [[ -z "$current_content" ]]; then
            log_warning "Skipping empty or invalid file: $file_path"
            continue
        fi

        FRONTMATTER_TAGS=""
        FRONTMATTER_STATUS=""
        FRONTMATTER_AUTO=""
        FRONTMATTER_GIST=""
        FRONTMATTER_PUBLISHER=""
        FRONTMATTER_COVER_IMAGE=""
        FRONTMATTER_TITLE=""
        FRONTMATTER_SUBTITLE=""
        
        parse_frontmatter "$current_content" || log_debug "No frontmatter found, using defaults"
        
        FRONTMATTER_TAGS="${FRONTMATTER_TAGS:-}"
        FRONTMATTER_STATUS="${FRONTMATTER_STATUS:-}"
        FRONTMATTER_AUTO="${FRONTMATTER_AUTO:-}"
        FRONTMATTER_GIST="${FRONTMATTER_GIST:-${PUBLISHER_GIST:-false}}"
        FRONTMATTER_PUBLISHER="${FRONTMATTER_PUBLISHER:-}"
        FRONTMATTER_COVER_IMAGE="${FRONTMATTER_COVER_IMAGE:-}"
        FRONTMATTER_TITLE="${FRONTMATTER_TITLE:-}"
        FRONTMATTER_SUBTITLE="${FRONTMATTER_SUBTITLE:-}"
        
        log_debug "After parsing: tags='$FRONTMATTER_TAGS', status='$FRONTMATTER_STATUS', auto='$FRONTMATTER_AUTO', gist='$FRONTMATTER_GIST', publisher='$FRONTMATTER_PUBLISHER'"
        
        local raw_content=""
        if ! raw_content=$(extract_clean_content "$current_content"); then
            log_error "Failed to extract content from $file_path"
            continue
        fi
        
        local title=""
        if [[ -n "$FRONTMATTER_TITLE" ]]; then
            title="$FRONTMATTER_TITLE"
            log_info "Title (from frontmatter): $title"
        else
            title=$(extract_title "$raw_content")
            if [[ -z "$title" ]]; then
                title=$(basename "$file_path" .md | tr '-' ' ')
                log_warning "No title found, using filename: $title"
            fi
            log_info "Title (extracted from markdown): $title"
        fi
        
        local subtitle="$FRONTMATTER_SUBTITLE"
        if [[ -n "$subtitle" ]]; then
            log_info "Subtitle: $subtitle"
        fi
        
        local tags="$FRONTMATTER_TAGS"
        log_info "Tags: ${tags:-none}"
        
        local status="$FRONTMATTER_STATUS"
        log_info "Status: ${status:-using service defaults}"
        
        local cover_image="$FRONTMATTER_COVER_IMAGE"
        if [[ -n "$cover_image" ]]; then
            log_info "Cover image: $cover_image"
        fi
        
        local final_content=""
        process_gist_tables_if_enabled "$FRONTMATTER_GIST" "$raw_content" "$file_path" "$title" "${GH_PAT_GIST_TOKEN:-}" final_content
        
        local publisher_list=$(get_publisher_list "$FRONTMATTER_PUBLISHER")
        
        process_file "$file_path" "$title" "$subtitle" "$final_content" "$tags" "$status" "$cover_image" "$publisher_list" total_operations successful_operations
        
    done
    
    log_separator "━" 60
    log_info "=== PUBLISHING COMPLETE ==="
    
    local failed_operations=$((total_operations - successful_operations))
    
    log_info "Operations: $successful_operations succeeded, $failed_operations failed"
    log_info "Total operations: $total_operations"
    
    if [[ $failed_operations -eq 0 ]]; then
        log_success "All operations succeeded!"
        exit 0
    else
        log_error "$failed_operations operation(s) failed"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi