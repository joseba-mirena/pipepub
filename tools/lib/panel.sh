#!/bin/bash
# tools/lib/panel.sh - Panel Menu Handler

if [[ -n "${_PANEL_SH_LOADED:-}" ]]; then
    return 0
fi

readonly _PANEL_SH_LOADED=1

# Configuration

PAN_MARGIN=4
PAN_PADDING=2
PAN_INNER_PADDING=2

# Reset style
PAN_RESET='\033[0m'

# Wording strings
PAN_STR_PAUSE="Press Enter to continue..."
PAN_STR_CONFIRM="Continue?"
PAN_STR_YESYNO="y/N"

# Icons and actions/options
PAN_NUMBERS=("➊" "➋" "➌" "➍" "➎" "➏" "➐" "➑" "➒" "➓")

PAN_ICON_APP="⟳"
PAN_ICON_CATEGORY="⮩"
PAN_ICON_SUBCAT="⮩"
PAN_ICON_ACTION="⮮"
PAN_ICON_EXIT="🄌"
PAN_ICON_BACK="🄌"
PAN_ICON_HELP="🅗"
PAN_PROMPT_PREFIX="⤷"

PAN_ICON_SUCCESS="✔"
PAN_ICON_ERROR="✘"
PAN_ICON_WARNING="⚠"
PAN_ICON_INFO="ⓘ"

PAN_SPINNER_CHARS='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
PAN_PROGRESS_FILL='█'
PAN_PROGRESS_EMPTY='░'

# Main background colors
PAN_BG_HEADER='\033[45m'          # Magenta
PAN_BG_MAIN='\033[48;5;235m'      # Dark gray
PAN_BG_OPTIONS='\033[46m'         # Cyan

# Prompt
PAN_PROMPT_PREFIX="⤷"
PAN_COLOR_PROMPT='\033[0;32m'
PAN_PROMPT_ERROR='\033[0;31m'
PAN_STYLE_CLEAN_TEXT='\033[0;97m'      # White text only
PAN_STYLE_CLEAN_INFO='\033[0;36m'      # Cyan text only
PAN_STYLE_CLEAN_SUCCESS='\033[0;32m'   # Green text only
PAN_STYLE_CLEAN_ERROR='\033[0;31m'     # Red text only
PAN_STYLE_CLEAN_WARNING='\033[1;33m'   # Bold yellow text only
PAN_STYLE_CLEAN_ACTION='\033[0;32m'    # Green text only for numbers


# Combined styles (foreground + background)
PAN_STYLE_HEADER='\033[1;37;45m'          # Bold white on magenta
PAN_STYLE_OPTIONS='\033[1;37;46m'         # Bold white on cyan
PAN_STYLE_TITLE='\033[1;36;48;5;235m'     # Bold cyan on dark gray
PAN_STYLE_TEXT='\033[0;97;48;5;235m'      # White on dark gray
PAN_STYLE_LIGHT='\033[0;37;48;5;235m'     # Light grey on dark gray
PAN_STYLE_MUTED='\033[0;90;48;5;235m'     # Grey on dark gray
PAN_STYLE_SEPARATOR='\033[0;30;48;5;235m' # Darker grey on dark gray
PAN_STYLE_ACTION='\033[0;32;48;5;235m'    # Green on dark gray
PAN_STYLE_INFO='\033[0;36;48;5;235m'      # Cyan on dark gray
PAN_STYLE_SUCCESS='\033[0;32;48;5;235m'   # Green on dark gray
PAN_STYLE_ERROR='\033[0;31;48;5;235m'     # Red on dark gray
PAN_STYLE_WARNING='\033[1;33;48;5;235m'   # Bold yellow on dark gray
PAN_STYLE_MENU='\033[0;32;48;5;235m'      # Green on dark gray
PAN_STYLE_BULLET='\033[0;90;48;5;235m'    # Gray bullet on dark gray


if [[ -n "${PAN_WIDTH:-}" ]]; then
    PAN_WIDTH=$PAN_WIDTH
elif [[ -t 1 ]]; then
    PAN_WIDTH=$(($(tput cols) - PAN_MARGIN - 2))
else
    PAN_WIDTH=70
fi
[[ $PAN_WIDTH -lt 40 ]] && PAN_WIDTH=40
[[ $PAN_WIDTH -gt 120 ]] && PAN_WIDTH=120

readonly PAN_WIDTH

# ============================================================================
# Internal state
# ============================================================================

_panel_main_lines=()
_panel_actions_lines=()

# ============================================================================
# Main panel build
# ============================================================================

panel_build() {
    local header_title="$1"
    local -n main_data_ref="$2"
    local -n actions_data_ref="$3"
    local -n info_lines_ref="$4"
    local footer_text="${5:-}"
    local is_submenu="${6:-false}"
    local header_icon="${7:-$PAN_ICON_APP}"
    
    # Build main lines from raw data
    local main_lines=()
    local in_category=false
    
    for data in "${main_data_ref[@]}"; do
        IFS=':' read -r type value1 value2 <<< "$data"
        
        case "$type" in
            category)
                if [[ "$in_category" == "true" ]]; then
                    main_lines+=("")
                fi
                main_lines+=("$(_panel_title "$value1" "$PAN_STYLE_TITLE" "$PAN_ICON_CATEGORY")")
                in_category=true
                ;;
            raw)
                main_lines+=("  ${PAN_STYLE_TEXT}${data#raw:}")
                ;;
            muted)
                main_lines+=("  ${PAN_STYLE_MUTED}${data#muted:}")
                ;;
            item)
                local name="$value1"
                local status="$value2"
                case "$status" in
                    success)
                        main_lines+=(" ${PAN_STYLE_SUCCESS}${PAN_ICON_SUCCESS}${PAN_STYLE_TEXT} ${name}")
                        ;;
                    warning)
                        main_lines+=("   ${PAN_STYLE_WARNING}${PAN_ICON_WARNING}${PAN_STYLE_MUTED} ${name} (partial)")
                        ;;
                    error)
                        main_lines+=("   ${PAN_STYLE_ERROR}${PAN_ICON_ERROR}${PAN_STYLE_MUTED} ${name}")
                        ;;
                    info)
                        main_lines+=(" ${PAN_STYLE_INFO}${PAN_ICON_INFO}${PAN_STYLE_TEXT} ${name}")
                        ;;
                    text)
                        main_lines+=(" ${PAN_STYLE_TEXT}${name}")
                        ;;
                    *)
                        main_lines+=("   ${PAN_STYLE_ERROR}${PAN_ICON_ERROR}${PAN_STYLE_MUTED} ${name}")
                        ;;
                esac
                ;;
        esac
    done
    
    # Build actions lines from raw data
    local actions_lines=()
    actions_lines+=("$(_panel_title "Actions" "$PAN_STYLE_TITLE" "$PAN_ICON_ACTION")")
    
    for data in "${actions_data_ref[@]}"; do
        IFS=':' read -r type number label <<< "$data"
        if [[ "$type" == "action" ]]; then
            local graphic_num="${PAN_NUMBERS[$((number - 1))]}"
            actions_lines+=(" ${PAN_STYLE_ACTION}${graphic_num}${PAN_STYLE_TEXT} ${label}")
        fi
    done
    
    # Render the panel
    panel_clear
    
    _panel_draw_header "$header_title" "$header_icon"
    _panel_draw_line "$PAN_BG_MAIN" ""
    
    if [[ ${#main_lines[@]} -gt 0 ]]; then
        _panel_draw_block "$PAN_BG_MAIN" main_lines
    fi
    
    _panel_draw_separator
    
    # Draw info lines if provided
    if [[ ${#info_lines_ref[@]} -gt 0 ]]; then
        for info_item in "${info_lines_ref[@]}"; do
            if [[ "$info_item" == *":"* ]]; then
                IFS=':' read -r info_text info_icon <<< "$info_item"
                _panel_draw_info_line "$info_text" "$info_icon"
            else
                _panel_draw_info_line "$info_item"
            fi
        done
        _panel_draw_separator
    fi

    if [[ ${#actions_lines[@]} -gt 0 ]]; then
        _panel_draw_block "$PAN_BG_MAIN" actions_lines
    fi
    
    _panel_draw_line "$PAN_BG_MAIN" ""
    
    # Draw footer only if provided
    if [[ -n "$footer_text" ]]; then
        _panel_draw_options "$footer_text"
    fi
    
    _panel_prompt
}

# ============================================================================
# Public methods
# ============================================================================

panel_read_choice() {
    local option="$1"
    local value
    read -r value
    eval "$option='$value'"
}

panel_confirm() {
    local option
    echo -ne "$(_panel_margin)${1:-${PAN_STR_CONFIRM}} (${PAN_STR_YESYNO}): "
    read -r option
    [[ "$option" == "y" || "$option" == "Y" ]]
}

panel_pause() {
    echo -ne "\n$(_panel_margin)⮐ ${1:-${PAN_STR_PAUSE}}\n"
    tput civis
    trap 'tput cnorm' INT TERM EXIT
    read -r
    tput cnorm
    trap - INT TERM EXIT
}

panel_clear() { clear; }

panel_success() {
    echo -e "$(_panel_margin)${PAN_STYLE_SUCCESS}${PAN_ICON_SUCCESS} ${1}${PAN_RESET}"
}

panel_error() {
    echo -e "$(_panel_margin)${PAN_STYLE_ERROR}${PAN_ICON_ERROR} ${1}${PAN_RESET}"
}

panel_prompt_error() {
    _panel_notify "$PAN_PROMPT_ERROR" "$PAN_ICON_ERROR" "$1"
}

panel_warning() {
    echo -e "$(_panel_margin)${PAN_STYLE_WARNING}${PAN_ICON_WARNING} ${1}${PAN_RESET}"
}

panel_info() {
    echo -e "$(_panel_margin)${PAN_STYLE_TITLE}${PAN_ICON_INFO} ${1}${PAN_RESET}"
}

# Display a blank line
panel_blank() {
    echo ""
}

# ============================================================================
# Prompt handling
# ============================================================================

# Display a prompt and read input (returns value in variable via nameref)
panel_prompt() {
    local prompt="$1"
    local -n result_var="$2"
    
    echo -ne "$(_panel_margin)${PAN_COLOR_PROMPT}${PAN_PROMPT_PREFIX}${PAN_RESET} ${prompt}: "
    read -r result_var
}

# Display a password prompt (hidden input)
panel_prompt_password() {
    local prompt="$1"
    local -n result_var="$2"
    
    echo -ne "$(_panel_margin)${PAN_COLOR_PROMPT}${PAN_PROMPT_PREFIX}${PAN_RESET} ${prompt}: "
    read -rs result_var
    echo ""
}

# Display a simple prompt without prefix (for inline questions)
panel_ask() {
    local prompt="$1"
    local -n result_var="$2"
    
    echo -ne "$(_panel_margin)${prompt}: "
    read -r result_var
}

# ============================================================================
# Chat/Interactive methods (no background, clean output for terminal chat)
# ============================================================================

chat_margin() {
    _panel_pf "$PAN_MARGIN"
}

chat_blank() {
    echo ""
}

chat_info() {
    echo -e "$(chat_margin)${PAN_STYLE_CLEAN_INFO}${PAN_ICON_INFO} ${1}${PAN_RESET}"
}

chat_success() {
    echo -e "$(chat_margin)${PAN_STYLE_CLEAN_SUCCESS}${PAN_ICON_SUCCESS} ${1}${PAN_RESET}"
}

chat_error() {
    echo -e "$(chat_margin)${PAN_STYLE_CLEAN_ERROR}${PAN_ICON_ERROR} ${1}${PAN_RESET}"
}

chat_warning() {
    echo -e "$(chat_margin)${PAN_STYLE_CLEAN_WARNING}${PAN_ICON_WARNING} ${1}${PAN_RESET}"
}

chat_list_item() {
    local number="$1"
    local text="$2"
    echo -e "$(chat_margin)  ${PAN_STYLE_CLEAN_ACTION}${number}${PAN_RESET}) ${PAN_STYLE_CLEAN_TEXT}${text}${PAN_RESET}"
}

chat_prompt() {
    local prompt="$1"
    local -n result_var="$2"
    
    echo -ne "$(chat_margin)${PAN_COLOR_PROMPT}${PAN_PROMPT_PREFIX}${PAN_RESET} ${prompt}: "
    read -r result_var
}

# Spinner with margin for chat mode
chat_spinner_start() {
    local message="$1"
    local delay="${2:-0.5}"
    
    if [[ -n "${_panel_spinner_pid}" ]] && kill -0 "$_panel_spinner_pid" 2>/dev/null; then
        kill "$_panel_spinner_pid" 2>/dev/null
        wait "$_panel_spinner_pid" 2>/dev/null
    fi
    
    sleep "$delay"
    
    # Save cursor position and hide it
    echo -ne "$(chat_margin)"
    tput sc
    tput civis
    
    (
        local i=0
        while true; do
            tput rc
            printf "${PAN_STYLE_SUCCESS}${PAN_SPINNER_CHARS:$i:1} $message${PAN_RESET}"
            i=$(( (i + 1) % ${#PAN_SPINNER_CHARS} ))
            sleep 0.1
        done
    ) &
    _panel_spinner_pid=$!
}

chat_spinner_stop() {
    if [[ -n "${_panel_spinner_pid}" ]]; then
        kill "$_panel_spinner_pid" 2>/dev/null
        wait "$_panel_spinner_pid" 2>/dev/null
        unset _panel_spinner_pid
    fi
    tput rc
    printf "\r%*s\r" "$(tput cols)" ""
    tput cnorm
}

chat_spinner_success() {
    chat_spinner_stop
    chat_success "$1"
}

chat_spinner_error() {
    chat_spinner_stop
    chat_error "$1"
}

# ============================================================================
# Internal helper methods
# ============================================================================

_panel_pf() { printf '%*s' "$1" ''; }
_panel_margin() { _panel_pf "$PAN_MARGIN"; }
_panel_padding() { _panel_pf "$PAN_PADDING"; }

_panel_write() {
    local message="$1"
    printf '%b\n' "$(_panel_margin)$message"
}

_panel_draw_line() {
    local bg="$1"
    local content="$2"
    local width="$PAN_WIDTH"
    
    local clean=$(printf '%b' "$content" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
    local content_len=${#clean}
    local spaces=$((width - content_len - PAN_PADDING - 1))
    [[ $spaces -lt 0 ]] && spaces=0
    
    _panel_write "${bg}$(_panel_padding)${content}$(printf '%*s' $spaces '')$(_panel_padding)${PAN_RESET}"
}

_panel_draw_block() {
    local bg="$1"
    local -n lines_ref="$2"
    for line in "${lines_ref[@]}"; do
        _panel_draw_line "$bg" "$line"
    done
}

_panel_title() {
    local title="$1"
    local color="$2"
    local icon="$3"
    echo "${color}${icon} ${title}"
}

_panel_draw_info_line() {
    local info_text="$1"
    local icon="${2:-$PAN_ICON_INFO}"
    
    # Split multiline text and draw each line
    while IFS= read -r line; do
        _panel_draw_line "$PAN_BG_MAIN" " ${PAN_STYLE_INFO}${icon} ${line}"
    done <<< "$info_text"
}

_panel_draw_options() {
    local options_text="$1"
    local width="$PAN_WIDTH"
    
    _panel_write "${PAN_BG_OPTIONS}$(printf '%*s' $((width + 1)) '')${PAN_RESET}"
    
    local options_len=${#options_text}
    local spaces=$((width - options_len - PAN_PADDING - 1))
    _panel_write "${PAN_BG_OPTIONS}$(_panel_padding)${options_text}$(printf '%*s' $spaces '')$(_panel_padding)${PAN_RESET}"
    
    _panel_write "${PAN_BG_OPTIONS}$(printf '%*s' $((width + 1)) '')${PAN_RESET}"
}

_panel_draw_header() {
    local title="$1"
    local icon="$2"
    _panel_draw_line "$PAN_BG_HEADER" ""
    _panel_draw_line "$PAN_BG_HEADER" "${icon} ${PAN_STYLE_HEADER}${title}"
    _panel_draw_line "$PAN_BG_HEADER" ""
}

_panel_draw_separator() {
    local width=$((PAN_WIDTH - 1))
    _panel_write "${PAN_STYLE_SEPARATOR} $(printf '%0.s─' $(seq 1 $width)) ${PAN_RESET}"
}

_panel_prompt() {
    echo -ne "\n$(_panel_margin)${PAN_COLOR_PROMPT}${PAN_PROMPT_PREFIX}${PAN_RESET} "
}

_panel_notify() {
    tput civis
    trap 'tput cnorm' INT TERM EXIT
    echo -ne "$(_panel_margin)${1}${2}${PAN_RESET} ${3}"
    sleep 1
    tput cnorm
    trap - INT TERM EXIT
}

# ============================================================================
# Spinner & Progress
# ============================================================================

_panel_spinner_pid=""

panel_spinner_start() {
    local message="$1"
    local delay="${2:-0.5}"
    
    if [[ -n "${_panel_spinner_pid}" ]] && kill -0 "$_panel_spinner_pid" 2>/dev/null; then
        kill "$_panel_spinner_pid" 2>/dev/null
        wait "$_panel_spinner_pid" 2>/dev/null
    fi
    
    sleep "$delay"
    tput civis
    
    (
        local i=0
        while true; do
            printf "\r${PAN_STYLE_SUCCESS}${PAN_SPINNER_CHARS:$i:1} $message${PAN_RESET}"
            i=$(( (i + 1) % ${#PAN_SPINNER_CHARS} ))
            sleep 0.1
        done
    ) &
    _panel_spinner_pid=$!
}

panel_spinner_stop() {
    if [[ -n "${_panel_spinner_pid}" ]]; then
        kill "$_panel_spinner_pid" 2>/dev/null
        wait "$_panel_spinner_pid" 2>/dev/null
        unset _panel_spinner_pid
    fi
    printf "\r%*s\r" "$(tput cols)" ""
    tput cnorm
}

panel_spinner_success() {
    panel_spinner_stop
    panel_success "$1"
}

panel_spinner_error() {
    panel_spinner_stop
    panel_error "$1"
}

panel_progress() {
    local message="${1:-Progress}"
    local current="$2"
    local total="$3"
    local width="${4:-40}"
    
    if [[ $total -eq 0 ]]; then
        return 0
    fi
    
    local percent=$((current * 100 / total))
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    local fill_char=$(printf "%0.s${PAN_PROGRESS_FILL}" $(seq 1 "$filled"))
    local empty_char=$(printf "%0.s${PAN_PROGRESS_EMPTY}" $(seq 1 "$empty"))
    
    printf "\r${PAN_STYLE_SUCCESS}%s: [%s%s] %3d%% (%d/%d)${PAN_RESET}" \
           "$message" "$fill_char" "$empty_char" "$percent" "$current" "$total"
}

panel_progress_done() {
    panel_progress "$1" "$2" "$3" 40
    echo ""
}

# ============================================================================