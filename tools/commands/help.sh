#!/bin/bash
# tools/commands/help.sh - Display help documentation

FROM_MAIN_MENU="${FROM_MAIN_MENU:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_FILE="$APP_ROOT/docs/MAN"
source "$SCRIPT_DIR/lib/common.sh"

show_quick_help() {
    local main_data=()
    local info_lines=()
    local actions_data=()
    
    # Available Commands section
    main_data+=("category:Available Commands")
    main_data+=("item:pipepub.sh              :success")
    main_data+=("item:pipepub.sh publish      :success")
    main_data+=("item:pipepub.sh secrets      :success")
    main_data+=("item:pipepub.sh check        :success")
    main_data+=("item:pipepub.sh test         :success")
    main_data+=("item:pipepub.sh help         :success")
    main_data+=("item:pipepub.sh man          :success")
    
    # Quick Help section - render as plain text lines
    main_data+=("category:Quick Help")
    
    if [[ -f "$DOCS_FILE" ]]; then
        # Extract quick help block and add each line as plain text
        while IFS= read -r line; do
            # Skip empty lines and code blocks and markdown headers
            if [[ -n "$line" && ! "$line" =~ ^\`\`\` && ! "$line" =~ ^# ]]; then
                # Remove markdown comment markers if any
                clean_line=$(echo "$line" | sed 's/^<!--.*-->//' | sed 's/^[[:space:]]*//')
                if [[ -n "$clean_line" ]]; then
                    main_data+=("item:$clean_line:text")
                fi
            fi
        done < <(sed -n '/<!-- quick-help -->/,/<!-- end-quick-help -->/p' "$DOCS_FILE" | sed '1d;$d')
    else
        # Fallback quick help content (plain text, no icons)
        main_data+=("item:./tools/pipepub.sh              # Interactive menu:text")
        main_data+=("item:./tools/pipepub.sh publish      # Publish articles:text")
        main_data+=("item:./tools/pipepub.sh secrets      # Manage secrets:text")
        main_data+=("item:./tools/pipepub.sh check        # Check system:text")
        main_data+=("item:./tools/pipepub.sh test         # Run tests:text")
        main_data+=("item:./tools/pipepub.sh --help       # Show this help:text")
        main_data+=("item:./tools/pipepub.sh --man        # Show full manual:text")
        main_data+=("item:./tools/pipepub.sh --doc        # Open manual file:text")
    fi
    
    # Info line
    info_lines+=("Use 'man' for full documentation:➊")
    
    # Actions
    actions_data+=("action:1:View full manual")
    actions_data+=("action:2:Open documentation")
    
    # Set context for footer
    set_options_context
    footer_text=$(get_footer_text)
    
    # Build and display panel
    panel_build "Help" main_data actions_data info_lines "$footer_text" "false"
    
    panel_read_choice choice
    
    # Handle footer choice
    handle_footer_choice "$choice"
    case $? in
        0)  # Back to main menu or Exit
            panel_clear
            if [[ "$FROM_MAIN_MENU" == "true" ]]; then
                "$SCRIPT_DIR/pipepub.sh"
            else
                exit 0
            fi
            ;;
        1)  # Help (recursive, show help again)
            show_quick_help
            return
            ;;
        2)  # Regular choice - handle tool actions
            case $choice in
                1)  # View full manual
                    if [[ -f "$DOCS_FILE" ]]; then
                        sed '/^```/d' "$DOCS_FILE" | less
                    else
                        panel_error "Documentation not found: $DOCS_FILE"
                        panel_pause
                    fi
                    show_quick_help
                    ;;
                2)  # Open documentation
                    if [[ -f "$DOCS_FILE" ]]; then
                        case "$OSTYPE" in
                            darwin*)
                                open "$DOCS_FILE"
                                ;;
                            linux*)
                                if command -v xdg-open &>/dev/null; then
                                    xdg-open "$DOCS_FILE"
                                else
                                    panel_info "Open manually: $DOCS_FILE"
                                fi
                                ;;
                            *)
                                panel_info "Open manually: $DOCS_FILE"
                                ;;
                        esac
                    else
                        panel_error "Documentation not found: $DOCS_FILE"
                    fi
                    panel_pause
                    show_quick_help
                    ;;
                *)
                    panel_prompt_error "Invalid choice"
                    show_quick_help
                    ;;
            esac
            ;;
    esac
}

show_full_man() {
    if [[ -f "$DOCS_FILE" ]]; then
        sed '/^```/d' "$DOCS_FILE" | less
    else
        panel_error "Documentation not found: $DOCS_FILE"
        exit 1
    fi
}

open_doc() {
    if [[ -f "$DOCS_FILE" ]]; then
        case "$OSTYPE" in
            darwin*)
                open "$DOCS_FILE"
                ;;
            linux*)
                if command -v xdg-open &>/dev/null; then
                    xdg-open "$DOCS_FILE"
                else
                    panel_info "Open manually: $DOCS_FILE"
                fi
                ;;
            *)
                panel_info "Open manually: $DOCS_FILE"
                ;;
        esac
    else
        panel_error "Documentation not found: $DOCS_FILE"
        exit 1
    fi
}

# Handle command line arguments
if [[ $# -gt 0 ]]; then
    case "${1:-}" in
        man|--man|-m)
            show_full_man
            ;;
        doc|--doc|-d)
            open_doc
            ;;
        help|--help|-h)
            show_quick_help
            ;;
        *)
            show_quick_help
            ;;
    esac
    exit 0
fi

# Interactive mode
show_quick_help