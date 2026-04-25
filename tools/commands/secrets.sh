#!/bin/bash
# tools/commands/secrets.sh - Secret management command

FROM_MAIN_MENU="${FROM_MAIN_MENU:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

show_menu() {
    local main_data=()
    local actions_data=()
    local info_lines=()
    
    # Publishing Services section
    main_data+=("category:Publishing Services")
    for service in $(get_services); do
        status=$(get_service_status "$service")
        name=$(get_service_display_name "$service")
        main_data+=("item:$name:$status")
    done
    
    # Core Infrastructure section
    main_data+=("category:Core Infrastructure")
    github_token=$(get_secret "github_token")
    if [[ -n "$github_token" ]]; then
        main_data+=("item:GitHub (Gist access):success")
    else
        main_data+=("item:GitHub (Gist access):error")
    fi
    
    # Info
    info_lines+=("Manage API tokens and credentials securely:ⓘ")
    
    # Actions
    actions_data+=("action:1:Add/update secrets")
    actions_data+=("action:2:Remove secrets")
    actions_data+=("action:3:List all configured services")
    actions_data+=("action:4:Export secrets (for GitHub Actions)")
    
    # Set context for footer
    set_options_context
    footer_text=$(get_footer_text)
    
    # Build and display panel
    panel_build "Secret Manager" main_data actions_data info_lines "$footer_text" "false"
    
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
        1)  # Help
            show_quick_help
            ;;
        2)  # Regular choice - handle tool actions
            case $choice in
                1) add_secrets_interactive ;;
                2) remove_secrets_interactive ;;
                3) list_secrets ;;
                4) export_secrets ;;
                *)
                    panel_prompt_error "Invalid choice"
                    show_menu
                    ;;
            esac
            ;;
    esac
}

validate_secret_value() {
    local value="$1"
    local field="$2"
    
    if [[ -z "$value" ]]; then
        chat_error "Value cannot be empty"
        return 1
    fi
    
    if [[ "$value" =~ [[:cntrl:]] ]]; then
        chat_error "Value contains control characters"
        return 1
    fi
    
    if [[ ${#value} -lt 4 ]]; then
        chat_warning "Value seems too short (${#value} chars)"
        if ! panel_confirm "Continue anyway?"; then
            return 1
        fi
    fi
    
    return 0
}

add_secrets_interactive() {
    local main_data=()
    local actions_data=()
    local info_lines=()
    
    # Publishing Services section
    main_data+=("category:Publishing Services")
    local services=($(get_services))
    for service in "${services[@]}"; do
        status=$(get_service_status "$service")
        name=$(get_service_display_name "$service")
        main_data+=("item:$name:$status")
    done
    
    # Core Infrastructure section - show actual status
    main_data+=("category:Core Infrastructure")
    github_token=$(get_secret "github_token")
    if [[ -n "$github_token" ]]; then
        main_data+=("item:GitHub Token (Gist access):success")
    else
        main_data+=("item:GitHub Token (Gist access):error")
    fi
    
    # Info line with warning style
    info_lines+=("Select a service to add or update its secrets:⚠")
    
    # Actions (NO Back action - footer handles it)
    local i=1
    for service in "${services[@]}"; do
        actions_data+=("action:$i:$(get_service_display_name "$service")")
        ((i++))
    done
    actions_data+=("action:$i:GitHub Token")
    
    # Set context for footer
    set_options_context
    footer_text=$(get_footer_text)
    
    # Build and display panel
    panel_build "Add Secrets" main_data actions_data info_lines "$footer_text" "false"
    
    panel_read_choice choice
    
    # Handle footer choice
    handle_footer_choice "$choice"
    case $? in
        0)  # Back (footer handles this)
            show_menu
            return
            ;;
        1)  # Help
            show_quick_help
            add_secrets_interactive
            return
            ;;
        2)  # Regular choice - handle tool actions
            local github_option_index=${#services[@]}
            if [[ "$choice" -eq "$((github_option_index + 1))" ]]; then
                add_github_token
                return
            fi
            
            local selected="${services[$((choice-1))]}"
            if [[ -z "$selected" ]]; then
                panel_prompt_error "Invalid choice"
                add_secrets_interactive
                return
            fi
            
            add_secrets "$selected"
            ;;
    esac
}

add_github_token() {
    panel_clear
    chat_warning "Adding GitHub Token"
    chat_blank
    chat_info "Required scope: 'gist' for table conversion feature"
    chat_info "Get token from: https://github.com/settings/tokens"
    chat_blank
    
    local token
    chat_prompt "Enter GitHub Personal Access Token (or 0 to go back)" token
    
    if [[ "$token" == "0" ]]; then
        chat_info "Returning to menu..."
        show_menu
        return
    fi
    
    if [[ -n "$token" ]]; then
        if validate_secret_value "$token" "github_token"; then
            set_secret "github_token" "$token"
            chat_success "GitHub token saved"
        else
            chat_error "Token not saved"
        fi
    else
        chat_warning "Skipped (empty)"
    fi
    
    panel_pause
    show_menu
}

add_secrets() {
    local service="$1"
    local service_name=$(get_service_display_name "$service")
    
    panel_clear
    chat_warning "Adding secrets for: $service_name"
    chat_blank
    
    local requires_oauth=$(get_service_requires_oauth "$service")
    
    for field in $(get_service_fields "$service"); do
        local display_field=$(echo "$field" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
        
        local help_text=$(get_field_help "$service" "$field")
        if [[ -n "$help_text" ]]; then
            chat_info "$help_text"
        fi
        
        local value
        chat_prompt "Enter $display_field (or 0 to go back)" value
        
        if [[ "$value" == "0" ]]; then
            chat_info "Returning to menu..."
            show_menu
            return
        fi
        
        if [[ -n "$value" ]]; then
            if validate_secret_value "$value" "$field"; then
                set_secret "${service}_${field}" "$value"
                chat_success "$display_field saved"
            else
                chat_warning "$display_field not saved (review secret format)"
            fi
        else
            chat_warning "Skipped (empty)"
        fi
        chat_blank
    done
    
    if [[ "$requires_oauth" == "true" ]]; then
        chat_blank
        chat_info "Next step: Run OAuth flow to get access token"
        chat_info "  ./tools/pipepub.sh oauth $service"
    fi
    
    panel_pause
    show_menu
}

remove_secrets_interactive() {
    local main_data=()
    local actions_data=()
    local configured_services=()
    
    for service in $(get_services); do
        status=$(get_service_status "$service")
        if [[ "$status" != "missing" ]]; then
            configured_services+=("$service")
        fi
    done
    
    github_token=$(get_secret "github_token")
    local has_github_token=false
    if [[ -n "$github_token" ]]; then
        has_github_token=true
    fi
    
    if [[ ${#configured_services[@]} -eq 0 ]] && [[ "$has_github_token" == "false" ]]; then
        chat_warning "No configured services or core tokens found."
        panel_pause
        show_menu
        return
    fi
    
    # Publishing Services section
    main_data+=("category:Publishing Services")
    for service in "${configured_services[@]}"; do
        name=$(get_service_display_name "$service")
        main_data+=("item:$name:success")
    done
    
    # Core Infrastructure section
    if [[ "$has_github_token" == "true" ]]; then
        main_data+=("category:Core Infrastructure")
        main_data+=("item:GitHub Token (Gist access):success")
    fi
    
    # Actions (NO Back action - footer handles it)
    local i=1
    for service in "${configured_services[@]}"; do
        actions_data+=("action:$i:$(get_service_display_name "$service")")
        ((i++))
    done
    if [[ "$has_github_token" == "true" ]]; then
        actions_data+=("action:$i:GitHub Token")
    fi
    
    # Set context for footer
    set_options_context
    footer_text=$(get_footer_text)
    
    # Build and display panel
    panel_build "Remove Secrets" main_data actions_data "" "$footer_text" "false"
    
    panel_read_choice choice
    
    # Handle footer choice
    handle_footer_choice "$choice"
    case $? in
        0)  # Back (footer handles this)
            show_menu
            return
            ;;
        1)  # Help
            show_quick_help
            remove_secrets_interactive
            return
            ;;
        2)  # Regular choice
            local github_index=${#configured_services[@]}
            if [[ "$has_github_token" == "true" ]] && [[ "$choice" -eq "$((github_index + 1))" ]]; then
                remove_github_token
                return
            fi
            
            local selected="${configured_services[$((choice-1))]}"
            if [[ -z "$selected" ]]; then
                panel_prompt_error "Invalid choice"
                remove_secrets_interactive
                return
            fi
            
            remove_secrets "$selected"
            ;;
    esac
}

remove_secrets() {
    local service="$1"
    local service_name=$(get_service_display_name "$service")
    
    if ! panel_confirm "Remove all secrets for '$service_name'?"; then
        chat_warning "Aborted."
        show_menu
        return
    fi
    
    for field in $(get_service_fields "$service"); do
        delete_secret "${service}_${field}"
    done
    
    chat_success "$service_name secrets removed"
    panel_pause
    show_menu
}

remove_github_token() {
    if ! panel_confirm "Remove GitHub token?"; then
        chat_warning "Aborted."
        show_menu
        return
    fi
    
    delete_secret "github_token"
    chat_success "GitHub token removed"
    panel_pause
    show_menu
}

list_secrets() {
    local main_data=()
    local actions_data=()
    local found=false
    
    # Helper to mask secret values
    mask_secret() {
        local value="$1"
        if [[ ${#value} -le 12 ]]; then
            echo "${value:0:4}****"
        else
            echo "${value:0:4}........"
        fi
    }
    
    # Publishing Services section - ONLY show configured services
    local has_configured=false
    for service in $(get_services); do
        status=$(get_service_status "$service")
        if [[ "$status" != "missing" ]]; then
            if [[ "$has_configured" == "false" ]]; then
                main_data+=("category:Publishing Services")
                has_configured=true
            fi
            found=true
            name=$(get_service_display_name "$service")
            main_data+=("item:$name:$status")
            
            # Show individual fields only if they have values
            for field in $(get_service_fields "$service"); do
                local value=$(get_secret "${service}_${field}")
                if [[ -n "$value" ]]; then
                    local display=$(echo "$field" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
                    local masked=$(mask_secret "$value")
                    # Put the masked value inside parentheses, no colon in the text
                    main_data+=("item:    └─ $display ($masked):text")
                fi
            done
        fi
    done
    
    # Core Infrastructure section
    github_value=$(get_secret "github_token")
    if [[ -n "$github_value" ]]; then
        found=true
        main_data+=("category:Core Infrastructure")
        main_data+=("item:GitHub Token (Gist access):success")
        local masked=$(mask_secret "$github_value")
        main_data+=("item:    └─ Token ($masked):text")
    fi
    
    if [[ "$found" == "false" ]]; then
        chat_warning "No services or core tokens configured yet."
        chat_info "Run: ./tools/pipepub.sh secrets add"
    fi
    
    # Actions
    actions_data+=("action:1:Add/update secrets")
    actions_data+=("action:2:Remove secrets")
    
    # Set context for footer
    set_options_context
    footer_text=$(get_footer_text)
    
    # Build and display panel
    panel_build "Configured Secrets" main_data actions_data "" "$footer_text" "false"
    
    panel_read_choice choice
    
    # Handle footer choice
    handle_footer_choice "$choice"
    case $? in
        0)  # Back (footer handles this)
            show_menu
            ;;
        1)  # Help
            show_quick_help
            list_secrets
            ;;
        2)  # Regular choice - handle tool actions
            case $choice in
                1) add_secrets_interactive ;;
                2) remove_secrets_interactive ;;
                *)
                    panel_prompt_error "Invalid choice"
                    list_secrets
                    ;;
            esac
            ;;
    esac
}

export_secrets() {
    local main_data=()
    local secrets_output=()
    
    main_data+=("category:Copy these secrets to GitHub repository")
    main_data+=("item:Settings → Secrets and variables → Actions → New repository secret:info")
    
    for service in $(get_services); do
        for field in $(get_service_fields "$service"); do
            local value=$(get_secret "${service}_${field}")
            if [[ -n "$value" ]]; then
                local env_var=$(echo "${service}_${field}" | tr '[:lower:]' '[:upper:]')
                secrets_output+=("$env_var=$value")
            fi
        done
    done
    
    local github_token=$(get_secret "github_token")
    if [[ -n "$github_token" ]]; then
        secrets_output+=("GH_PAT_GIST_TOKEN=$github_token")
    fi
    
    if [[ ${#secrets_output[@]} -gt 0 ]]; then
        main_data+=("category:Your secrets")
        for secret in "${secrets_output[@]}"; do
            main_data+=("item:$secret:success")
        done
    else
        main_data+=("item:No secrets found to export:warning")
    fi
    
    # Set context for footer
    set_options_context
    footer_text=$(get_footer_text)
    
    # Build and display panel
    panel_build "Export Secrets" main_data "" "" "$footer_text" "false"
    
    panel_read_choice choice
    
    # Handle footer choice
    handle_footer_choice "$choice"
    case $? in
        0)  # Back (footer handles this)
            show_menu
            ;;
        1)  # Help
            show_quick_help
            export_secrets
            ;;
        *)
            show_menu
            ;;
    esac
}

show_quick_help() {
    local main_data=()
    local actions_data=()
    
    main_data+=("category:Available Commands")
    main_data+=("item:1 - Add/update secrets for a service:success")
    main_data+=("item:2 - Remove secrets for a service:success")
    main_data+=("item:3 - List all configured services:success")
    main_data+=("item:4 - Export secrets for GitHub Actions:success")
    
    main_data+=("category:When adding secrets")
    main_data+=("item:• Tokens are stored in your OS keychain:info")
    main_data+=("item:• GitHub token requires 'gist' scope:info")
    main_data+=("item:• OAuth services require additional setup:info")
    
    # Actions
    actions_data+=("action:1:Back to main menu")
    
    # Set context for footer
    set_options_context
    footer_text=$(get_footer_text)
    
    # Build and display panel
    panel_build "Secret Manager Help" main_data actions_data "" "$footer_text" "false"
    
    panel_read_choice choice
    
    # Handle footer choice
    handle_footer_choice "$choice"
    case $? in
        0)  # Back (footer handles this)
            show_menu
            ;;
        1)  # Help (recursive)
            show_quick_help
            ;;
        2)  # Regular choice
            case $choice in
                1) show_menu ;;
                *) show_quick_help ;;
            esac
            ;;
    esac
}

cmd_line() {
    # Check master key, show error but don't use panel in CLI mode
    if ! ensure_master_key; then
        echo "ERROR: Failed to create master key"
        exit 1
    fi
    
    case "$1" in
        add)
            shift
            if [[ -z "$1" ]]; then
                echo "ERROR: Usage: secrets add <service>"
                exit 1
            fi
            add_secrets "$1"
            ;;
        remove)
            shift
            if [[ -z "$1" ]]; then
                echo "ERROR: Usage: secrets remove <service>"
                exit 1
            fi
            remove_secrets "$1"
            ;;
        list)
            for service in $(get_services); do
                status=$(get_service_status "$service")
                name=$(get_service_display_name "$service")
                
                case "$status" in
                    success)
                        echo "✓ $name"
                        ;;
                    partial)
                        echo "⚠ $name (partial)"
                        ;;
                    *)
                        echo "✗ $name (not configured)"
                        ;;
                esac
            done
            github_token=$(get_secret "github_token")
            if [[ -n "$github_token" ]]; then
                echo "✓ GitHub Token (Gist access)"
            else
                echo "✗ GitHub Token (Gist access) (not configured)"
            fi
            ;;
        export)
            for service in $(get_services); do
                for field in $(get_service_fields "$service"); do
                    local value=$(get_secret "${service}_${field}")
                    if [[ -n "$value" ]]; then
                        local env_var=$(echo "${service}_${field}" | tr '[:lower:]' '[:upper:]')
                        echo "$env_var=$value"
                    fi
                done
            done
            local github_token=$(get_secret "github_token")
            if [[ -n "$github_token" ]]; then
                echo "GH_PAT_GIST_TOKEN=$github_token"
            fi
            ;;
        *)
            show_quick_help
            ;;
    esac
}

main() {
    # Check master key first, show UI if needed
    if ! ensure_master_key; then
        panel_error "Failed to create master key"
        panel_pause
        exit 1
    fi
    
    if [[ $# -eq 0 ]]; then
        show_menu
    else
        cmd_line "$@"
    fi
}

main "$@"