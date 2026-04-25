#!/bin/bash
# tools/commands/check.sh - System check command

FROM_MAIN_MENU="${FROM_MAIN_MENU:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

PASSED=0
FAILED=0
WARNINGS=0

check_os() {
    case "$OSTYPE" in
        darwin*)
            echo "macOS ($(sw_vers -productVersion)):success"
            return 0
            ;;
        linux*)
            if [[ -f /etc/os-release ]]; then
                OS_NAME=$(grep "^NAME" /etc/os-release | cut -d'"' -f2)
                echo "Linux ($OS_NAME):success"
            else
                echo "Linux:success"
            fi
            return 0
            ;;
        msys*|cygwin*|mingw*)
            echo "Windows (not officially supported):error"
            echo "PipePub tools require macOS or Linux:warning"
            echo "Windows users can use WSL or Git Bash:warning"
            return 1
            ;;
        *)
            echo "Unknown OS: $OSTYPE:error"
            return 1
            ;;
    esac
}

check_dependencies() {
    local deps_ok=true
    
    if command -v git &>/dev/null; then
        echo "git ($(git --version | cut -d' ' -f3)):success"
    else
        echo "git (not found):error"
        deps_ok=false
    fi
    
    if command -v curl &>/dev/null; then
        echo "curl ($(curl --version | head -1 | cut -d' ' -f2)):success"
    else
        echo "curl (not found):error"
        deps_ok=false
    fi
    
    if command -v jq &>/dev/null; then
        echo "jq ($(jq --version)):success"
    else
        echo "jq (not found):error"
        echo "Install: brew install jq (macOS) or apt-get install jq (Linux):warning"
        deps_ok=false
    fi
    
    if command -v openssl &>/dev/null; then
        echo "openssl ($(openssl version | cut -d' ' -f2)):success"
    else
        echo "openssl (not found):error"
        deps_ok=false
    fi
    
    $deps_ok
}

check_keychain_tool() {
    case "$OSTYPE" in
        darwin*)
            if command -v security &>/dev/null; then
                echo "security (macOS Keychain):success"
                return 0
            else
                echo "security (not found):error"
                return 1
            fi
            ;;
        linux*)
            if command -v secret-tool &>/dev/null; then
                echo "secret-tool (GNOME Keyring / KWallet):success"
                return 0
            else
                echo "secret-tool (not found):error"
                echo "Install: apt-get install libsecret-tools (Ubuntu/Debian):warning"
                echo "        dnf install libsecret (Fedora):warning"
                echo "        pacman -S libsecret (Arch):warning"
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

check_keychain_access() {
    local test_key="_test_access_$(date +%s)"
    
    if set_secret "$test_key" "test_value" 2>/dev/null; then
        local value=$(get_secret "$test_key" 2>/dev/null)
        delete_secret "$test_key" 2>/dev/null
        
        if [[ "$value" == "test_value" ]]; then
            echo "Read/Write access:success"
            return 0
        else
            echo "Write succeeded but read failed:error"
            return 1
        fi
    else
        echo "Cannot write to keychain:error"
        echo "Check permissions or if keychain is locked:warning"
        return 1
    fi
}

check_python() {
    if command -v python3 &>/dev/null; then
        echo "python3 ($(python3 --version)):success"
        return 0
    else
        echo "python3 (not found):warning"
        echo "Python is only required for OAuth flows (Medium, Twitter):warning"
        echo "Install: brew install python3 (macOS) or apt-get install python3 (Linux):warning"
        return 1
    fi
}

main() {
    local main_data=()
    local info_lines=()
    local actions_data=()
    
    # OS Check
    main_data+=("category:Operating System")
    while IFS=':' read -r text status; do
        main_data+=("item:$text:$status")
    done < <(check_os)
    
    # Dependencies
    main_data+=("category:Dependencies")
    while IFS=':' read -r text status; do
        main_data+=("item:$text:$status")
    done < <(check_dependencies)
    
    # Keychain Tool
    main_data+=("category:Keychain")
    while IFS=':' read -r text status; do
        main_data+=("item:$text:$status")
    done < <(check_keychain_tool)
    
    # Keychain Access
    main_data+=("category:Keychain Access")
    while IFS=':' read -r text status; do
        main_data+=("item:$text:$status")
    done < <(check_keychain_access)
    
    # Python (optional)
    main_data+=("category:Python (Optional)")
    while IFS=':' read -r text status; do
        main_data+=("item:$text:$status")
    done < <(check_python)
        
    # Set context for footer
    set_options_context
    footer_text=$(get_footer_text)
    
    # Build and display panel
    panel_build "System Check" main_data actions_data info_lines "$footer_text" "false"
    
    panel_read_choice choice
    
    # Handle footer choice
    handle_footer_choice "$choice"
    case $? in
        0)  # Back to main menu
            panel_clear
            if [[ "$FROM_MAIN_MENU" == "true" ]]; then
                "$SCRIPT_DIR/pipepub.sh"
            else
                return 0
            fi
            ;;
        1)  # Help
            FROM_MAIN_MENU=true "$SCRIPT_DIR/commands/help.sh" check
            main
            return
            ;;
        *)
            panel_prompt_error "Invalid choice"
            main
            ;;
    esac
}

main