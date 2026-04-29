#!/bin/bash
# tools/pipepub.sh

FROM_MAIN_MENU=false

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if [[ $# -gt 0 ]]; then
    COMMAND="$1"
    shift
    
    case "$COMMAND" in
        publish|secrets|check|test)
            if [[ -f "$SCRIPT_DIR/commands/${COMMAND}.sh" ]]; then
                "$SCRIPT_DIR/commands/${COMMAND}.sh" "$@"
            else
                panel_prompt_error "Unknown command: $COMMAND"
                exit 1
            fi
            ;;
        --version|-v)
            echo "$APP_NAME $APP_VERSION"
            exit 0
            ;;
        --man|-m)
            "$SCRIPT_DIR/commands/help.sh" man
            ;;
        --doc|-d)
            "$SCRIPT_DIR/commands/help.sh" doc
            ;;
        --help|-h)
            "$SCRIPT_DIR/commands/help.sh"
            ;;
        *)
            "$SCRIPT_DIR/commands/help.sh"
            ;;
    esac
    exit 0
fi

main() {
    local main_data=()
    local actions_data=()
    local info_lines=()
    local pub_ready=false
    
    # Publishing Services section
    main_data+=("category:Publishing Services")
    for service in $(get_services); do
        status=$(get_service_status "$service")
        if [[ "$status" == 'success' ]]; then
            pub_ready=true
        fi
        name=$(get_service_display_name "$service")
        main_data+=("item:$name:$status")
    done
    
    # Core Infrastructure section
    main_data+=("category:Core Infrastructure")
    github_token=$(get_secret "GH_PAT_GIST_TOKEN")
    if [[ -n "$github_token" ]]; then
        main_data+=("item:GitHub (Gist access):success")
    else
        main_data+=("item:GitHub (Gist access):error")
    fi

    # Info
    if [[ "$pub_ready" != true ]]; then
        info_lines+=("Add a secret to enable publishing:➋")
    else
        info_lines+=("Publishing is ready:➊")
    fi

    # Actions
    actions_data+=("action:1:Publish articles")
    actions_data+=("action:2:Manage secrets")
    actions_data+=("action:3:Check system")
    actions_data+=("action:4:Run tests")

    # Set context for footer (main menu)
    set_options_context
    footer_text=$(get_footer_text)

    # Build and display panel
    panel_build "$APP_NAME $APP_VERSION" main_data actions_data info_lines "$footer_text" "false" "$APP_ICON"

    panel_read_choice choice
    
    # Handle footer choice
    handle_footer_choice "$choice"
    case $? in
        0)  # Exit
            panel_clear
            exit 0
            ;;
        1)  # Help
            FROM_MAIN_MENU=true "$SCRIPT_DIR/commands/help.sh"
            main
            return
            ;;
        2)  # Regular choice - handle tool actions
            case $choice in
                1) FROM_MAIN_MENU=true "$SCRIPT_DIR/commands/publish.sh" ;;
                2) FROM_MAIN_MENU=true "$SCRIPT_DIR/commands/secrets.sh" ;;
                3) FROM_MAIN_MENU=true "$SCRIPT_DIR/commands/check.sh" ;;
                4) FROM_MAIN_MENU=true "$SCRIPT_DIR/commands/test.sh" ;;
                *)
                    panel_prompt_error "Invalid choice"
                    main
                    ;;
            esac
            ;;
    esac
}

main