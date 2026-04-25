#!/bin/bash
# tools/lib/options.sh - Persistent footer options handler

if [[ -n "${_OPTIONS_SH_LOADED:-}" ]]; then
    return 0
fi

readonly _OPTIONS_SH_LOADED=1

# Option labels and icons
OPTION_BACK_LABEL="Back"
OPTION_BACK_ICON="🄌"
OPTION_EXIT_LABEL="Exit"
OPTION_EXIT_ICON="🄌"
OPTION_HELP_LABEL="Help"
OPTION_HELP_ICON="🅗"

# Set context based on FROM_MAIN_MENU flag
set_options_context() {
    if [[ "$FROM_MAIN_MENU" == "true" ]]; then
        CURRENT_OPTION_0_LABEL="$OPTION_BACK_LABEL"
        CURRENT_OPTION_0_ICON="$OPTION_BACK_ICON"
    else
        CURRENT_OPTION_0_LABEL="$OPTION_EXIT_LABEL"
        CURRENT_OPTION_0_ICON="$OPTION_EXIT_ICON"
    fi
}

# Get formatted footer text
get_footer_text() {
    echo "${CURRENT_OPTION_0_ICON} ${CURRENT_OPTION_0_LABEL}       ${OPTION_HELP_ICON} ${OPTION_HELP_LABEL}"
}

# Handle footer choice
# Returns: 0=Exit/Back, 1=Help, 2=Regular choice
handle_footer_choice() {
    local choice="$1"
    
    case $choice in
        0)
            return 0
            ;;
        q|Q)
            panel_clear
            exit 0
            ;;
        h|H)
            return 1
            ;;
        *)
            return 2
            ;;
    esac
}