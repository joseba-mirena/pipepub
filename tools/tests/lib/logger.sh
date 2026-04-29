#!/bin/bash
# tools/tests/lib/logger.sh - Light test _tlogger

_tlog() {
    echo "# $@" >&2
}

tlog_blank() {
    _tlog ""
}

tlog_debug() {
    if [[ "${LOG_LEVEL}" == "debug" ]]; then
        _tlog "[DEBUG] $@"
    fi
}

tlog_info() {
    _tlog "$@"
}

tlog_success() {
    tlog_blank
    _tlog " ✅ $@"
}

tlog_warning() {
    tlog_blank
    _tlog " ⚠️ $@"
}

tlog_error() {
    tlog_blank
    _tlog " ❌ $@"
}

tlog_separator() {
    _tlog "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

tlog_decoration() {
    _tlog "############################################################"
}

tlog_summary() {
    local header="$1"
    shift
    tlog_decoration
    _tlog " $header"
    tlog_decoration
    for line in "$@"; do
        _tlog "$line"
    done
    tlog_decoration
}

tlog_section() {
    tlog_separator
    for line in "$@"; do
        _tlog "$line"
    done
    tlog_separator
}
