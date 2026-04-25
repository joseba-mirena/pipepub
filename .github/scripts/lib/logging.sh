#!/bin/bash
# .github/scripts/lib/logging.sh - Unified logging module

# Prevent double sourcing
if [[ -n "${_LOGGING_SH_LOADED:-}" ]]; then
    return 0
fi
readonly _LOGGING_SH_LOADED=1

# ============================================================================
# Configuration
# ============================================================================

LOG_LEVEL="${LOG_LEVEL:-info}"
LOG_OUTPUT="${LOG_OUTPUT:-console}"
LOG_FILE="${LOG_FILE:-}"
LOG_QUIET="${LOG_QUIET:-false}"
LOG_TIMESTAMP="${LOG_TIMESTAMP:-true}"
LOG_JSON="${LOG_JSON:-false}"
LOG_JSON_PRETTY="${LOG_JSON_PRETTY:-false}"

# ============================================================================
# Text Labels (native format for files and JSON)
# ============================================================================

declare -A LOG_LABELS=(
    ["debug"]="[DEBUG]"
    ["info"]="[INFO]"
    ["success"]="[SUCCESS]"
    ["warning"]="[WARNING]"
    ["error"]="[ERROR]"
)

# ============================================================================
# Emoji Mapping (console only - translates text labels to emojis)
# ============================================================================

declare -A LABEL_TO_EMOJI=(
    ["[DEBUG]"]="🔍"
    ["[INFO]"]=""
    ["[SUCCESS]"]="✅"
    ["[WARNING]"]="⚠️"
    ["[ERROR]"]="❌"
)

# Disable emojis if requested
if [[ "${LOG_NO_ICONS:-false}" == "true" ]]; then
    for key in "${!LABEL_TO_EMOJI[@]}"; do
        LABEL_TO_EMOJI["$key"]=""
    done
fi

# ============================================================================
# Terminal Colors (console only)
# ============================================================================

if [[ -t 1 ]] && [[ "$LOG_JSON" != "true" ]]; then
    LOG_COLOR_RESET='\033[0m'
    LOG_COLOR_INFO='\033[0;37m'
    LOG_COLOR_DEBUG='\033[0;35m'
    LOG_COLOR_SUCCESS='\033[0;32m'
    LOG_COLOR_WARNING='\033[1;33m'
    LOG_COLOR_ERROR='\033[0;31m'
    LOG_COLOR_HEADER='\033[0;36m'
    LOG_COLOR_SEPARATOR='\033[0;90m'
    LOG_COLOR_TIMESTAMP='\033[0;90m'
else
    LOG_COLOR_RESET=''
    LOG_COLOR_INFO=''
    LOG_COLOR_DEBUG=''
    LOG_COLOR_SUCCESS=''
    LOG_COLOR_WARNING=''
    LOG_COLOR_ERROR=''
    LOG_COLOR_HEADER=''
    LOG_COLOR_SEPARATOR=''
    LOG_COLOR_TIMESTAMP=''
fi

# ============================================================================
# Helper Functions
# ============================================================================

_log_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

_log_timestamp_iso() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

_log_should_show() {
    local level="$1"
    local level_num=0
    local current_num=0
    
    case "$level" in
        debug) level_num=1 ;;
        info) level_num=2 ;;
        success) level_num=2 ;;
        warning) level_num=3 ;;
        error) level_num=4 ;;
        *) return 1 ;;
    esac
    
    case "$LOG_LEVEL" in
        debug) current_num=1 ;;
        info) current_num=2 ;;
        warning) current_num=3 ;;
        error) current_num=4 ;;
        *) current_num=2 ;;
    esac
    
    [[ $level_num -ge $current_num ]]
}

_validate_log_path() {
    local log_path="$1"
    
    # Reject path traversal attempts
    [[ "$log_path" == *".."* ]] && return 1
    
    # Allow safe paths
    case "$log_path" in
        /tmp/*|.tmp/*|.reports/*|.logs/*|/dev/null)
            return 0
            ;;
        *)
            # Also allow absolute paths under PROJECT_ROOT (if PROJECT_ROOT is set)
            if [[ -n "${PROJECT_ROOT:-}" ]] && [[ "$log_path" == "$PROJECT_ROOT"/* ]]; then
                # Only allow specific subdirectories
                case "$log_path" in
                    "$PROJECT_ROOT/.tmp/"*|"$PROJECT_ROOT/.logs/"*|"$PROJECT_ROOT/.reports/"*)
                        return 0
                        ;;
                esac
            fi
            return 1
            ;;
    esac
}

# Console only: translate text label to emoji
_label_to_emoji() {
    local label="$1"
    echo "${LABEL_TO_EMOJI[$label]:-$label}"
}

_get_label() {
    echo "${LOG_LABELS[$1]:-[INFO]}"
}

_get_color() {
    case "$1" in
        debug)   echo "$LOG_COLOR_DEBUG" ;;
        info)    echo "$LOG_COLOR_INFO" ;;
        success) echo "$LOG_COLOR_SUCCESS" ;;
        warning) echo "$LOG_COLOR_WARNING" ;;
        error)   echo "$LOG_COLOR_ERROR" ;;
        *)       echo "$LOG_COLOR_INFO" ;;
    esac
}

# ============================================================================
# Output Writers
# ============================================================================

_log_write_file() {
    local message="$1"
    
    if [[ -z "${GITHUB_ACTIONS:-}" ]]; then
        if [[ "$LOG_OUTPUT" == "file" ]] || [[ "$LOG_OUTPUT" == "both" ]]; then
            if [[ "$LOG_LEVEL" == "debug" ]]; then
                if [[ -n "$LOG_FILE" ]] && _validate_log_path "$LOG_FILE"; then
                    # File output: plain text, no processing (FAST)
                    echo "$message" >> "$LOG_FILE"
                fi
            fi
        fi
    fi
}

_log_write_console() {
    local message="$1"
    
    if [[ "$LOG_QUIET" != "true" ]]; then
        if [[ -n "${GITHUB_ACTIONS:-}" ]] || [[ "$LOG_OUTPUT" == "console" ]] || [[ "$LOG_OUTPUT" == "both" ]]; then
            echo -e "$message" >&2
        fi
    fi
}

_log_write_json() {
    local level="$1"
    local message="$2"
    local timestamp="$3"
    
    # Use text label directly (no emoji translation)
    local label="${LOG_LABELS[$level]:-[INFO]}"
    label="${label//\[/}"
    label="${label//\]/}"
    label="${label,,}"
    
    message="${message//\\/\\\\}"
    message="${message//\"/\\\"}"
    
    if [[ "$LOG_JSON_PRETTY" == "true" ]]; then
        jq -n --arg ts "$timestamp" --arg lvl "$label" --arg msg "$message" \
            '{timestamp: $ts, level: $lvl, message: $msg}' >> "$LOG_FILE"
    else
        jq -n -c --arg ts "$timestamp" --arg lvl "$label" --arg msg "$message" \
            '{timestamp: $ts, level: $lvl, message: $msg}' >> "$LOG_FILE"
    fi
}

# ============================================================================
# Main Log Function
# ============================================================================

_log() {
    local level="$1"
    local message="$2"
    
    _log_should_show "$level" || return 0
    
    local timestamp_human=""
    local timestamp_iso=""
    if [[ "$LOG_TIMESTAMP" == "true" ]]; then
        timestamp_human="$(_log_timestamp) "
        timestamp_iso="$(_log_timestamp_iso)"
    fi
    
    local label=$(_get_label "$level")
    local color=$(_get_color "$level")
    
    # File/JSON format: text label directly (FAST - no translation)
    local file_msg="${timestamp_human}${label} ${message}"
    
    # Console format: translate label to emoji (slower, but console is interactive)
    local emoji=$(_label_to_emoji "$label")
    local console_msg=""
    if [[ -n "$emoji" ]]; then
        console_msg="${LOG_COLOR_TIMESTAMP}${timestamp_human}${LOG_COLOR_RESET}${color}${emoji} ${message}${LOG_COLOR_RESET}"
    else
        console_msg="${LOG_COLOR_TIMESTAMP}${timestamp_human}${LOG_COLOR_RESET}${color}${message}${LOG_COLOR_RESET}"
    fi
    
    # Route output
    if [[ "$LOG_JSON" == "true" ]]; then
        _log_write_json "$level" "$message" "$timestamp_iso"
    else
        case "$LOG_OUTPUT" in
            console)
                _log_write_console "$console_msg"
                ;;
            file)
                _log_write_file "$file_msg"
                ;;
            both)
                _log_write_console "$console_msg"
                _log_write_file "$file_msg"
                ;;
            *)
                _log_write_console "$console_msg"
                ;;
        esac
    fi
}

# ============================================================================
# Public API
# ============================================================================

log_debug()   { _log "debug" "$1"; }
log_info()    { _log "info" "$1"; }
log_success() { _log "success" "$1"; }
log_warning() { _log "warning" "$1"; }
log_error()   { _log "error" "$1"; }

log_blank() {
    _log_write_console ""
    _log_write_file ""
}

log_separator() {
    local char="${1:-━}"
    local length="${2:-60}"
    local separator=$(printf '%0.s'"$char" $(seq 1 "$length"))
    
    _log_write_console "${LOG_COLOR_SEPARATOR}${separator}${LOG_COLOR_RESET}"
    _log_write_file "$separator"
}

log_header() {
    local title="$1"
    local char="${2:-━}"
    local length="${3:-60}"
    
    local separator=$(printf '%0.s'"$char" $(seq 1 "$length"))
    
    _log_write_console "${LOG_COLOR_HEADER}${separator}${LOG_COLOR_RESET}"
    _log_write_console "${LOG_COLOR_HEADER}${title}${LOG_COLOR_RESET}"
    _log_write_console "${LOG_COLOR_HEADER}${separator}${LOG_COLOR_RESET}"
    
    _log_write_file "$separator"
    _log_write_file "$title"
    _log_write_file "$separator"
}

log_init() {    
    if [[ "$LOG_LEVEL" == "debug" ]]; then
        if [[ "$LOG_OUTPUT" == "file" ]] || [[ "$LOG_OUTPUT" == "both" ]]; then
            if [[ -z "$LOG_FILE" ]]; then
                local timestamp=$(date +%Y%m%d_%H%M%S)
                LOG_FILE="$PROJECT_ROOT/.tmp/pipepub_${timestamp}.log"
            fi
            
            if _validate_log_path "$LOG_FILE"; then
                local log_dir=$(dirname "$LOG_FILE")
                mkdir -p "$log_dir"
                echo "Debug log: $LOG_FILE" >&2
            else
                echo "Warning: Unsafe log path, disabling file logging" >&2
                LOG_OUTPUT="console"
                LOG_FILE=""
            fi
        fi
    fi
}

log_init