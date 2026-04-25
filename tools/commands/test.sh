#!/bin/bash
# tools/commands/test.sh - Run tests command

FROM_MAIN_MENU="${FROM_MAIN_MENU:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

clean_test_files() {
    local files_to_delete=()
    local dirs_to_delete=()
    
    # Find test files in posts/
    if [[ -d "$SCRIPT_DIR/../posts" ]]; then
        while IFS= read -r file; do
            files_to_delete+=("$file")
        done < <(find "$SCRIPT_DIR/../posts" -maxdepth 1 -name ".test-*.md" 2>/dev/null)
    fi
    
    # Find log files
    if [[ -d "$SCRIPT_DIR/../.logs" ]]; then
        while IFS= read -r file; do
            files_to_delete+=("$file")
        done < <(find "$SCRIPT_DIR/../.logs" -name "*.log" 2>/dev/null)
    fi
    
    # Find report files
    if [[ -d "$SCRIPT_DIR/../.reports" ]]; then
        while IFS= read -r file; do
            files_to_delete+=("$file")
        done < <(find "$SCRIPT_DIR/../.reports" -name "*.json" 2>/dev/null)
    fi
    
    # Find temp directories
    while IFS= read -r dir; do
        dirs_to_delete+=("$dir")
    done < <(find /tmp -maxdepth 1 -name "publisher-test-*" 2>/dev/null)
    
    local total_count=$(( ${#files_to_delete[@]} + ${#dirs_to_delete[@]} ))
    
    if [[ $total_count -eq 0 ]]; then
        chat_warning "No test files found to clean"
        return 0
    fi
    
    # Show what will be deleted
    chat_warning "The following test artifacts will be deleted:"
    chat_blank
    
    if [[ ${#files_to_delete[@]} -gt 0 ]]; then
        chat_info "Files:"
        for file in "${files_to_delete[@]}"; do
            chat_list_item "" "  $(basename "$file")"
        done
        chat_blank
    fi
    
    if [[ ${#dirs_to_delete[@]} -gt 0 ]]; then
        chat_info "Directories:"
        for dir in "${dirs_to_delete[@]}"; do
            chat_list_item "" "  $(basename "$dir")"
        done
        chat_blank
    fi
    
    # Ask for confirmation
    if panel_confirm "Delete ${total_count} test artifact(s)?"; then
        local deleted=0
        
        for file in "${files_to_delete[@]}"; do
            rm -f "$file"
            chat_success "Deleted: $(basename "$file")"
            ((deleted++))
        done
        
        for dir in "${dirs_to_delete[@]}"; do
            rm -rf "$dir"
            chat_success "Deleted: $(basename "$dir")"
            ((deleted++))
        done
        
        chat_blank
        chat_success "Deleted $deleted test artifact(s)"
    else
        chat_warning "Cleanup cancelled"
    fi
}

main() {
    local main_data=()
    local info_lines=()
    local actions_data=()
    
    # Test categories status
    main_data+=("category:Test Suites")
    
    # Check if test runner exists
    if [[ -f "$SCRIPT_DIR/tests/run_all_tests.sh" ]]; then
        main_data+=("item:Test runner:success")
    else
        main_data+=("item:Test runner:error")
    fi
    
    # Count test files
    local unit_count=$(find "$SCRIPT_DIR/tests/unit" -name "*.sh" 2>/dev/null | wc -l)
    local integration_count=$(find "$SCRIPT_DIR/tests/integration" -name "*.sh" 2>/dev/null | wc -l)
    local e2e_count=$(find "$SCRIPT_DIR/tests/e2e" -name "*.sh" 2>/dev/null | wc -l)
    
    main_data+=("item:Unit tests ($unit_count files):success")
    main_data+=("item:Integration tests ($integration_count files):success")
    main_data+=("item:E2E tests ($e2e_count files):success")
    
    # Info
    info_lines+=("Run tests to verify app integrity:ⓘ")
    info_lines+=("Tests are located in tools/tests/:ⓘ")
    
    # Actions
    actions_data+=("action:1:Run all tests")
    actions_data+=("action:2:Run unit tests only")
    actions_data+=("action:3:Run integration tests only")
    actions_data+=("action:4:Run E2E tests only")
    actions_data+=("action:5:Run with debug output")
    actions_data+=("action:6:Update snapshots")
    actions_data+=("action:7:Clean test files")
    
    # Set context for footer
    set_options_context
    footer_text=$(get_footer_text)
    
    # Build and display panel
    panel_build "Test Runner" main_data actions_data info_lines "$footer_text" "false"
    
    panel_read_choice choice
    
    # Handle footer choice
    handle_footer_choice "$choice"
    case $? in
        0)  # Back to main menu or Exit
            panel_clear
            if [[ "$FROM_MAIN_MENU" == "true" ]]; then
                "$SCRIPT_DIR/pipepub.sh"
            else
                return 0
            fi
            ;;
        1)  # Help
            FROM_MAIN_MENU=true "$SCRIPT_DIR/commands/help.sh" test
            main
            return
            ;;
        2)  # Regular choice - handle tool actions
            case $choice in
                1)
                    panel_clear
                    "$SCRIPT_DIR/tests/run_all_tests.sh"
                    panel_pause
                    main
                    ;;
                2)
                    panel_clear
                    for test in "$SCRIPT_DIR"/tests/unit/*.sh; do
                        if [[ -f "$test" ]]; then
                            echo "Running: $(basename "$test")"
                            "$test"
                            echo ""
                        fi
                    done
                    panel_pause
                    main
                    ;;
                3)
                    panel_clear
                    for test in "$SCRIPT_DIR"/tests/integration/*.sh; do
                        if [[ -f "$test" ]]; then
                            echo "Running: $(basename "$test")"
                            "$test"
                            echo ""
                        fi
                    done
                    panel_pause
                    main
                    ;;
                4)
                    panel_clear
                    for test in "$SCRIPT_DIR"/tests/e2e/*.sh; do
                        if [[ -f "$test" ]]; then
                            echo "Running: $(basename "$test")"
                            "$test"
                            echo ""
                        fi
                    done
                    panel_pause
                    main
                    ;;
                5)
                    panel_clear
                    "$SCRIPT_DIR/tests/run_all_tests.sh" --debug
                    panel_pause
                    main
                    ;;
                6)
                    panel_clear
                    chat_warning "Updating snapshots..."
                    UPDATE_SNAPSHOTS=true "$SCRIPT_DIR/tests/run_all_tests.sh"
                    chat_success "Snapshots updated"
                    panel_pause
                    main
                    ;;
                7)
                    panel_clear
                    clean_test_files
                    panel_pause
                    main
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