#!/bin/bash
# tools/commands/publish.sh - Publish articles command with file selection

FROM_MAIN_MENU="${FROM_MAIN_MENU:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Get files from posts/ sorted by modification time (newest first)
get_files() {
    local max_files="${1:-50}"
    find posts -maxdepth 1 -name "*.md" -type f -printf "%T@ %p\n" 2>/dev/null | \
        sort -rn | \
        head -n "$max_files" | \
        cut -d' ' -f2-
}

# Format file size
format_size() {
    local size="$1"
    if [[ $size -lt 1024 ]]; then
        echo "${size}B"
    elif [[ $size -lt 1048576 ]]; then
        echo "$((size / 1024))KB"
    else
        echo "$((size / 1048576))MB"
    fi
}

# Get file info for display (safe for IFS parsing)
get_file_info() {
    local file="$1"
    local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
    local mtime=$(stat -c%y "$file" 2>/dev/null | cut -d'.' -f1 || stat -f%Sm "$file" 2>/dev/null)
    # Remove colons from time (replace with hyphen)
    mtime="${mtime//:/-}"
    # Format with multiple spaces as separator, no special chars
    printf "%s  %-6s  %s" "$(basename "$file")" "$(format_size "$size")" "$mtime"
}

# Copy example file to posts/
copy_example_file() {
    local example_file="$APP_ROOT/docs/assets/example/post-example.md"
    local posts_dir="$APP_ROOT/posts"
    
    if [[ ! -f "$example_file" ]]; then
        chat_error "Example file not found: $example_file"
        return 1
    fi
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local target_file="$posts_dir/example_${timestamp}.md"
    
    cp "$example_file" "$target_file"
    chat_success "Example file copied to: $(basename "$target_file")"
    chat_info "Edit this file with your content and frontmatter"
    
    return 0
}

# Process selected files
# Process selected files
process_files() {
    local selected_files=("$@")
    local success_count=0
    local partial_count=0
    local fail_count=0
    
    for file in "${selected_files[@]}"; do
        local filename=$(basename "$file")
        chat_blank
        
        export MANUAL_FILENAMES="$filename"
        export DRY_RUN="false"
        export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-local}"
        export GITHUB_REF_NAME="${GITHUB_REF_NAME:-main}"
        
        # Set up debug logging if enabled
        if [[ "${LOG_LEVEL:-}" == "debug" ]]; then
            mkdir -p ".tmp"
            local timestamp=$(date +%Y%m%d_%H%M%S)
            export LOG_FILE=".tmp/pipepub_${timestamp}_${filename%.md}.log"
            export LOG_OUTPUT="both"
            chat_info "Debug log: $LOG_FILE"
        fi
        
        # Run pipeline with appropriate output handling
        local pipeline_output
        if [[ "${LOG_LEVEL:-}" == "debug" ]]; then
            pipeline_output=$(.github/scripts/main.sh 2>&1 | tee /dev/tty)
        else
            panel_spinner_start "Publishing $filename..."
            pipeline_output=$(.github/scripts/main.sh 2>&1)
            panel_spinner_stop
        fi
        
        chat_blank
        
        # Extract summary block and operation counts
        local summary_block=$(echo "$pipeline_output" | grep -A10 "Summary for $filename:")
        
        # Count successes and failures from the summary block
        local services_success=$(echo "$summary_block" | grep -c "✓ .*: success")
        local services_failed=$(echo "$summary_block" | grep -c "✗ .*: failed")
        local services_total=$((services_success + services_failed))
        
        if [[ $services_total -eq 0 ]]; then
            # No services found for this file (should not happen)
            chat_error "$filename - no services configured"
            ((fail_count++))
        elif [[ $services_failed -eq 0 ]]; then
            # All services succeeded
            chat_success "$filename published successfully"
            ((success_count++))
        elif [[ $services_success -eq 0 ]]; then
            # All services failed
            chat_error "$filename - all services failed"
            ((fail_count++))
            # Show last few error lines
            echo "$pipeline_output" | grep -E "(ERROR|❌|Failed)" | tail -3 | while read -r line; do
                clean_line=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g' | tr -d '❌')
                chat_error "${clean_line}"
            done
        else
            # Partial success
            chat_warning "$filename - $services_success succeeded, $services_failed failed"
            ((partial_count++))
        fi
    done
    
    chat_blank
    chat_info "Summary: $success_count fully succeeded, $partial_count partial, $fail_count failed"
}

# Delete selected files (interactive)
delete_files_interactive() {
    local files=($(get_files 50))
    
    if [[ ${#files[@]} -eq 0 ]]; then
        chat_error "No markdown files found in posts/"
        return 1
    fi
    
    panel_clear
    chat_warning "Delete articles"
    chat_blank
    
    chat_info "Available files:"
    chat_blank
    for i in "${!files[@]}"; do
        local info=$(get_file_info "${files[$i]}")
        chat_list_item "$((i+1))" "$info"
    done
    
    chat_blank
    chat_prompt "Enter selection (e.g., 1 3 5, 1-3, a for all) or 0 to go back" selection
    
    if [[ "$selection" == "0" ]]; then
        chat_info "Returning to main menu..."
        return 1
    fi
    
    local selected_files=()
    
    if [[ "$selection" == "a" ]]; then
        selected_files=("${files[@]}")
    else
        for part in $selection; do
            if [[ "$part" == *"-"* ]]; then
                start=$(echo "$part" | cut -d'-' -f1)
                end=$(echo "$part" | cut -d'-' -f2)
                for ((i=start; i<=end; i++)); do
                    if [[ $i -ge 1 ]] && [[ $i -le ${#files[@]} ]]; then
                        selected_files+=("${files[$((i-1))]}")
                    fi
                done
            else
                if [[ $part -ge 1 ]] && [[ $part -le ${#files[@]} ]]; then
                    selected_files+=("${files[$((part-1))]}")
                fi
            fi
        done
    fi
    
    if [[ ${#selected_files[@]} -eq 0 ]]; then
        chat_error "No valid files selected"
        return 1
    fi
    
    chat_blank
    chat_warning "Files to be deleted:"
    for file in "${selected_files[@]}"; do
        chat_error "  ✗ $(basename "$file")"
    done
    
    chat_blank
    if panel_confirm "Permanently delete these ${#selected_files[@]} file(s)?"; then
        for file in "${selected_files[@]}"; do
            rm -f "$file"
            chat_success "Deleted: $(basename "$file")"
        done
        chat_blank
        chat_success "Deleted ${#selected_files[@]} file(s)"
    else
        chat_warning "Aborted"
    fi
    
    return 0
}

# Delete all files in posts/
delete_all_files() {
    local files=($(get_files 9999))
    local count=${#files[@]}
    
    if [[ $count -eq 0 ]]; then
        chat_warning "No files found to delete"
        return
    fi
    
    chat_warning "This will permanently delete $count file(s) from posts/ directory"
    if panel_confirm "Are you absolutely sure?"; then
        for file in "${files[@]}"; do
            rm -f "$file"
            chat_success "Deleted: $(basename "$file")"
        done
        chat_blank
        chat_success "Deleted $count file(s)"
    else
        chat_warning "Aborted"
    fi
}

# Interactive file selection for processing (terminal chat style)
select_articles_interactive() {
    local files=($(get_files 50))
    
    if [[ ${#files[@]} -eq 0 ]]; then
        chat_error "No markdown files found in posts/"
        return 1
    fi
    
    panel_clear
    chat_warning "Select articles to process"
    chat_blank
    
    chat_info "Available files:"
    chat_blank
    for i in "${!files[@]}"; do
        local info=$(get_file_info "${files[$i]}")
        chat_list_item "$((i+1))" "$info"
    done
    
    chat_blank
    chat_prompt "Enter selection (e.g., 1 3 5, 1-3, a for all) or 0 to go back" selection
    
    if [[ "$selection" == "0" ]]; then
        chat_info "Returning to main menu..."
        return 1
    fi
    
    local selected_files=()
    
    if [[ "$selection" == "a" ]]; then
        selected_files=("${files[@]}")
    else
        for part in $selection; do
            if [[ "$part" == *"-"* ]]; then
                start=$(echo "$part" | cut -d'-' -f1)
                end=$(echo "$part" | cut -d'-' -f2)
                for ((i=start; i<=end; i++)); do
                    if [[ $i -ge 1 ]] && [[ $i -le ${#files[@]} ]]; then
                        selected_files+=("${files[$((i-1))]}")
                    fi
                done
            else
                if [[ $part -ge 1 ]] && [[ $part -le ${#files[@]} ]]; then
                    selected_files+=("${files[$((part-1))]}")
                fi
            fi
        done
    fi
    
    if [[ ${#selected_files[@]} -eq 0 ]]; then
        chat_error "No valid files selected"
        return 1
    fi
    
    chat_blank
    chat_info "Selected files:"
    for file in "${selected_files[@]}"; do
        chat_success "  $(basename "$file")"
    done
    
    if panel_confirm "Process these ${#selected_files[@]} file(s)?"; then
        process_files "${selected_files[@]}"
        return 0
    else
        chat_warning "Aborted"
        return 1
    fi
}

# Process all files directly
process_all_files() {
    local files=($(get_files 9999))
    
    if [[ ${#files[@]} -eq 0 ]]; then
        chat_error "No markdown files found in posts/"
        return 1
    fi
    
    chat_info "Processing all ${#files[@]} file(s)..."
    
    if panel_confirm "Process ${#files[@]} file(s)?"; then
        process_files "${files[@]}"
        return 0
    else
        chat_warning "Aborted"
        return 1
    fi
}

main() {
    panel_clear
    
    if ! ensure_master_key; then
        panel_error "Failed to initialize master key"
        panel_pause
        exit 1
    fi
    
    load_all_secrets
    
    local main_data=()
    local actions_data=()
    local info_lines=()
    local has_configured=false
    
    # Publishing Services section - show ALL services with their status
    main_data+=("category:Publishing Services")
    for service in $(get_services); do
        status=$(get_service_status "$service")
        name=$(get_service_display_name "$service")
        main_data+=("item:$name:$status")
        if [[ "$status" == "success" ]] || [[ "$status" == "partial" ]]; then
            has_configured=true
        fi
    done
    
    # Available files section - using 'text' status for plain rendering
    local files=($(get_files 20))
    local file_count=${#files[@]}
    
    main_data+=("category:Available files")
    if [[ $file_count -gt 0 ]]; then
        for file in "${files[@]}"; do
            local info=$(get_file_info "$file")
            main_data+=("item:$info:text")
        done
    else
        main_data+=("item:No markdown files found:warning")
    fi
    
    # Info line
    if [[ "$has_configured" == "false" ]]; then
        info_lines+=("No publishing services enabled. Add secrets to enable publishing:⚠")
    fi
    info_lines+=("$file_count file(s) ready to be processed:ⓘ")
    
    # Actions
    actions_data+=("action:1:Select articles")
    actions_data+=("action:2:Process all")
    actions_data+=("action:3:Delete files")
    actions_data+=("action:4:Delete all files")
    actions_data+=("action:5:Copy example file")
    actions_data+=("action:6:Manage secrets")
    
    # Set context for footer
    set_options_context
    footer_text=$(get_footer_text)
    
    # Build and display panel
    panel_build "Publish Articles" main_data actions_data info_lines "$footer_text" "false"
    
    panel_read_choice choice
    
    # Handle footer choice
    handle_footer_choice "$choice"
    case $? in
        0)  # Back (footer handles this)
            panel_clear
            if [[ "$FROM_MAIN_MENU" == "true" ]]; then
                "$SCRIPT_DIR/pipepub.sh"
            else
                exit 0
            fi
            ;;
        1)  # Help
            "$SCRIPT_DIR/commands/help.sh" publish
            main
            return
            ;;
        2)  # Regular choice
            case $choice in
                1)
                    if [[ "$has_configured" == "false" ]]; then
                        panel_error "No publishing services enabled"
                        panel_info "Please add secrets first"
                        panel_pause
                        main
                        return
                    fi
                    
                    if [[ $file_count -eq 0 ]]; then
                        panel_error "No files to process"
                        panel_pause
                        main
                        return
                    fi
                    
                    select_articles_interactive
                    
                    if [[ "$FROM_MAIN_MENU" == "true" ]]; then
                        panel_pause
                        main
                    else
                        exit 0
                    fi
                    ;;
                2)
                    if [[ "$has_configured" == "false" ]]; then
                        panel_error "No publishing services enabled"
                        panel_info "Please add secrets first"
                        panel_pause
                        main
                        return
                    fi
                    
                    if [[ $file_count -eq 0 ]]; then
                        panel_error "No files to process"
                        panel_pause
                        main
                        return
                    fi
                    
                    process_all_files
                    
                    if [[ "$FROM_MAIN_MENU" == "true" ]]; then
                        panel_pause
                        main
                    else
                        exit 0
                    fi
                    ;;
                3)
                    if [[ $file_count -eq 0 ]]; then
                        panel_error "No files to delete"
                        panel_pause
                        main
                        return
                    fi
                    
                    delete_files_interactive
                    panel_pause
                    main
                    ;;
                4)
                    delete_all_files
                    panel_pause
                    main
                    ;;
                5)
                    copy_example_file
                    panel_pause
                    main
                    ;;
                6)
                    FROM_MAIN_MENU=true "$SCRIPT_DIR/commands/secrets.sh"
                    main
                    return
                    ;;
                *)
                    panel_prompt_error "Invalid choice"
                    main
                    ;;
            esac
            ;;
    esac
}

main