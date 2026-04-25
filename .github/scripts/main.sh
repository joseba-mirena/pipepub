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

# Check if library files exist before sourcing
for lib in logging.sh common.sh api.sh validation.sh tags.sh content.sh frontmatter.sh; do
    if [[ ! -f "$DIR_LIB/$lib" ]]; then
        echo "ERROR: Required library not found: $DIR_LIB/$lib" >&2
        exit 1
    fi
    source "$DIR_LIB/$lib"
done

# Source core modules
if [[ ! -f "$DIR_SRC/core/registry.sh" ]]; then
    echo "ERROR: Required module not found: $DIR_SRC/core/registry.sh" >&2
    exit 1
fi
source "$DIR_SRC/core/registry.sh"

# ============================================================================
# Global Variables
# ============================================================================

declare -a PROCESSED_FILES=()
declare -a FAILED_OPERATIONS=()
declare -a SKIPPED_FILES=()
declare -a ACTIVE_SERVICES=()

# Global frontmatter variables
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
        # Manual mode: process only specified files
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
        # Automatic mode: detect changed files from git diff
        # Check if we have git history (not a fresh clone with only 1 commit)
        if git rev-parse HEAD~1 >/dev/null 2>&1; then
            # --diff-filter=ACMR means: Added, Copied, Modified, Renamed
            # Excludes: Deleted (D), Type changed (T), etc.
            while IFS= read -r file; do
                # Only include files that still exist on disk
                if [[ -n "$file" ]] && [[ -f "$file" ]]; then
                    files+=("$file")
                fi
            done < <(git diff --name-only --diff-filter=ACMR HEAD~1 HEAD 2>/dev/null | grep "^${target_folder}/.*\.md$" || true)
        else
            # Fallback: process all markdown files (first commit or shallow clone)
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
    
    for service in "${ACTIVE_SERVICES[@]}"; do
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
    
    # Case-insensitive match, handling comma-separated list
    echo "$publisher_list" | tr ',' '\n' | grep -qi "^[[:space:]]*${service}[[:space:]]*$"
}

validate_service_handler() {
    local service="$1"
    local handler_func="$2"
    
    if ! declare -F "$handler_func" >/dev/null 2>&1; then
        log_error "Handler function '$handler_func' not found for service '$service'"
        return 1
    fi
    return 0
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
    
    local -A results
    local any_success=false
    
    # Check auto-publish setting
    local auto_publish="${FRONTMATTER_AUTO:-true}"
    if [[ "$auto_publish" == "false" ]] && [[ -z "${MANUAL_FILENAMES:-}" ]]; then
        log_info "Auto-publish disabled for: $file_path"
        SKIPPED_FILES+=("$file_path")
        return 0
    fi
    
    for service in "${ACTIVE_SERVICES[@]}"; do
        if ! should_process_service "$service" "$publisher_list"; then
            log_info "$service not in publisher list for: $file_path"
            results["$service"]="not_requested"
            continue
        fi
        
        # Load service configuration
        if ! load_service_config "$service"; then
            log_error "Failed to load configuration for service: $service"
            results["$service"]="failed"
            FAILED_OPERATIONS+=("$file_path:$service:config_error")
            continue
        fi
        
        local display_name=$(get_service_config "$service" "display")
        local handler_func=$(get_service_config "$service" "handler_func")
        
        # Validate handler exists
        if ! validate_service_handler "$service" "$handler_func"; then
            results["$service"]="failed"
            FAILED_OPERATIONS+=("$file_path:$service:missing_handler")
            continue
        fi
        
        log_info "Publishing to $display_name..."
        
        # Implement retry logic for API calls
        local max_retries=3
        local retry_count=0
        local success=false
        
        while [[ $retry_count -lt $max_retries ]]; do
            if [[ "${DRY_RUN:-false}" == "true" ]]; then
                log_info "DRY RUN: Would publish to $display_name"
                success=true
                break
            fi
            
            if $handler_func "$title" "$subtitle" "$content" "$tags" "$status" "$cover_image"; then
                success=true
                break
            else
                retry_count=$((retry_count + 1))
                if [[ $retry_count -lt $max_retries ]]; then
                    log_warning "Retry $retry_count/$max_retries for $display_name"
                    sleep $((retry_count * 2))  # Exponential backoff
                fi
            fi
        done
        
        if [[ "$success" == true ]]; then
            results["$service"]="success"
            any_success=true
            log_success "Successfully published to $display_name"
        else
            results["$service"]="failed"
            FAILED_OPERATIONS+=("$file_path:$service:api_error")
            log_error "Failed to publish to $display_name after $max_retries attempts"
        fi
    done
    
    if [[ "$any_success" == true ]]; then
        PROCESSED_FILES+=("$file_path")
    fi
    
    # Log summary
    log_info "Summary for $(basename "$file_path"):"
    for platform in "${!results[@]}"; do
        case "${results[$platform]}" in
            success)        log_info "  ✓ $platform: success" ;;
            failed)         log_error "  ✗ $platform: failed" ;;
            not_requested)  log_info "  ○ $platform: not in publisher list" ;;
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
        log_info "Gist tables disabled in frontmatter"
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
    
    # Check if handler exists before sourcing
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
    # Check if at least one service has required tokens
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
    
    # Check dependencies
    if ! check_dependencies; then
        log_error "Dependency check failed"
        exit 1
    fi
    
    # Validate environment
    if ! validate_required_environment; then
        log_error "Environment validation failed"
        exit 1
    fi
    
    # Register active services
    if ! declare -F register_active_services >/dev/null 2>&1; then
        log_error "register_active_services function not found"
        exit 1
    fi
    
    register_active_services ACTIVE_SERVICES
    
    if [[ ${#ACTIVE_SERVICES[@]} -eq 0 ]]; then
        log_error "No active publishers with valid tokens"
        exit 1
    fi
    
    log_info "Active publishers:"
    for service in "${ACTIVE_SERVICES[@]}"; do
        if load_service_config "$service"; then
            local display_name=$(get_service_config "$service" "display")
            log_info "  • $display_name ($service)"
        else
            log_warning "  • $service (failed to load config)"
        fi
    done
    
    # Get files to process
    declare -a FILES_TO_PROCESS=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && FILES_TO_PROCESS+=("$file")
    done < <(get_files_to_process "posts")
    
    if [[ ${#FILES_TO_PROCESS[@]} -eq 0 ]]; then
        log_info "No markdown files to process"
        exit 0
    fi
    
    log_info "Found ${#FILES_TO_PROCESS[@]} file(s) to process"
    
    # Process each file
    for file_path in "${FILES_TO_PROCESS[@]}"; do
        [[ -z "$file_path" ]] && continue
        
        log_separator "━" 60
        log_info "Processing: $file_path"
        
        # Check if file exists (defensive check, should already be true)
        if [[ ! -f "$file_path" ]]; then
            log_error "File not found: $file_path"
            continue
        fi
        
        # Parse frontmatter
        if ! parse_frontmatter "$file_path"; then
            log_debug "No frontmatter found, using defaults"
        fi
        
        # Apply defaults
        FRONTMATTER_TAGS="${FRONTMATTER_TAGS:-}"
        FRONTMATTER_STATUS="${FRONTMATTER_STATUS:-${PUBLISHER_STATUS:-draft}}"
        FRONTMATTER_AUTO="${FRONTMATTER_AUTO:-${PUBLISHER_AUTO:-true}}"
        FRONTMATTER_GIST="${FRONTMATTER_GIST:-${PUBLISHER_GIST:-false}}"
        FRONTMATTER_PUBLISHER="${FRONTMATTER_PUBLISHER:-}"
        FRONTMATTER_COVER_IMAGE="${FRONTMATTER_COVER_IMAGE:-}"
        FRONTMATTER_TITLE="${FRONTMATTER_TITLE:-}"
        FRONTMATTER_SUBTITLE="${FRONTMATTER_SUBTITLE:-}"
        
        log_debug "After defaults: tags='$FRONTMATTER_TAGS', status='$FRONTMATTER_STATUS', auto='$FRONTMATTER_AUTO', gist='$FRONTMATTER_GIST', publisher='$FRONTMATTER_PUBLISHER'"
        
        # Extract content
        local raw_content=""
        if ! raw_content=$(extract_clean_content "$file_path"); then
            log_error "Failed to extract content from $file_path"
            continue
        fi
        
        # Extract or use title
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
        
        # Get subtitle
        local subtitle="$FRONTMATTER_SUBTITLE"
        if [[ -n "$subtitle" ]]; then
            log_info "Subtitle: $subtitle"
        fi
        
        # Get metadata
        local tags="$FRONTMATTER_TAGS"
        log_info "Tags: ${tags:-none}"
        
        local status="$FRONTMATTER_STATUS"
        log_info "Status: $status"
        
        local cover_image="$FRONTMATTER_COVER_IMAGE"
        if [[ -n "$cover_image" ]]; then
            log_info "Cover image: $cover_image"
        fi
        
        # Process gist tables if enabled
        local final_content=""
        process_gist_tables_if_enabled "$FRONTMATTER_GIST" "$raw_content" "$file_path" "$title" "${GH_PAT_GIST_TOKEN:-}" final_content
        
        # Get publisher list
        local publisher_list=$(get_publisher_list "$FRONTMATTER_PUBLISHER")
        
        # Process the file
        process_file "$file_path" "$title" "$subtitle" "$final_content" "$tags" "$status" "$cover_image" "$publisher_list"
        
    done
    
    # Final summary
    log_separator "━" 60
    log_info "=== PUBLISHING COMPLETE ==="
    log_info "Successfully published: ${#PROCESSED_FILES[@]} files"
    
    if [[ ${#PROCESSED_FILES[@]} -gt 0 ]]; then
        log_info "Published files:"
        for published in "${PROCESSED_FILES[@]}"; do
            log_info "  ✓ $published"
        done
    fi
    
    if [[ ${#SKIPPED_FILES[@]} -gt 0 ]]; then
        log_info "Skipped (auto-publish disabled): ${#SKIPPED_FILES[@]} files"
        for skipped in "${SKIPPED_FILES[@]}"; do
            log_info "  ○ $skipped"
        done
    fi
    
    if [[ ${#FAILED_OPERATIONS[@]} -gt 0 ]]; then
        log_error "Failed operations: ${#FAILED_OPERATIONS[@]}"
        for failed in "${FAILED_OPERATIONS[@]}"; do
            log_error "  ✗ $failed"
        done
        
        if [[ "${DRY_RUN:-false}" == "true" ]]; then
            log_error "DRY RUN: Validation failed due to ${#FAILED_OPERATIONS[@]} failed operation(s)"
            exit 1
        else
            # Don't exit with error if some operations failed but others succeeded
            # This allows partial success in CI/CD
            log_warning "Some operations failed, but continuing..."
            exit 0
        fi
    else
        log_success "All articles published successfully!"
        exit 0
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi