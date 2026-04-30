#!/bin/bash
# tools/tests/lib/setup.sh - Test environment setup

# Prevent multiple sourcing
if [[ -n "${_SETUP_SH_LOADED:-}" ]]; then
    return 0
fi
readonly _SETUP_SH_LOADED=1

# ============================================================================
# Path Calculation
# ============================================================================

if [[ -n "${BASH_SOURCE[1]}" ]]; then
    CALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
else
    CALLER_DIR="$(pwd)"
fi

if [[ "$CALLER_DIR" == *"/tools/tests" ]]; then
    PROJECT_ROOT="$(cd "$CALLER_DIR/../.." && pwd)"
elif [[ "$CALLER_DIR" == *"/tools/tests/unit" ]]; then
    PROJECT_ROOT="$(cd "$CALLER_DIR/../../.." && pwd)"
elif [[ "$CALLER_DIR" == *"/tools/tests/integration" ]]; then
    PROJECT_ROOT="$(cd "$CALLER_DIR/../../.." && pwd)"
elif [[ "$CALLER_DIR" == *"/tools/tests/e2e" ]]; then
    PROJECT_ROOT="$(cd "$CALLER_DIR/../../.." && pwd)"
else
    PROJECT_ROOT="$(cd "$CALLER_DIR/../.." && pwd)"
fi

export PROJECT_ROOT
export CALLER_DIR

# ============================================================================
# Environment Loading
# ============================================================================

if [[ -f "$PROJECT_ROOT/.env" ]]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
fi

LOG_LEVEL="${LOG_LEVEL:-info}"
LOG_OUTPUT="${LOG_OUTPUT:-console}"

# ============================================================================
# Parse Arguments (overrides .env)
# ============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            LOG_LEVEL="debug"
            shift
            ;;
        --log)
            LOG_OUTPUT="both"
            shift
            ;;
        --dev)
            TEST_DEV_MODE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

export LOG_LEVEL
export LOG_OUTPUT
export TEST_DEV_MODE

# ============================================================================
# Output Capture (when LOG_LEVEL=debug)
# ============================================================================

if [[ "$LOG_LEVEL" == "debug" ]] && [[ -z "${_OUTPUT_CAPTURED:-}" ]]; then
    mkdir -p "$PROJECT_ROOT/.logs"
    
    TEST_NAME=$(basename "${BASH_SOURCE[1]}" .sh 2>/dev/null || echo "unknown")
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    TEST_LOG_FILE="$PROJECT_ROOT/.logs/test_${TEST_NAME}_${TIMESTAMP}.log"
    
    exec > >(tee -a "$TEST_LOG_FILE") 2>&1
    readonly _OUTPUT_CAPTURED=1
fi

# ============================================================================
# Create Log Directories
# ============================================================================

mkdir -p "$PROJECT_ROOT/.tmp" "$PROJECT_ROOT/.reports"

timestamp=$(date +%Y%m%d_%H%M%S)
if [[ "${TEST_DEV_MODE:-false}" == "true" ]]; then
    export LOG_FILE="$PROJECT_ROOT/.tmp/pipepub_dev_${timestamp}.log"
else
    export LOG_FILE="$PROJECT_ROOT/.tmp/pipepub_${timestamp}.log"
fi

# ============================================================================
# Load Pipeline Libraries
# ============================================================================

source "$PROJECT_ROOT/.github/scripts/lib/logging.sh"

# ============================================================================
# Source Test Libraries (must be before they are used)
# ============================================================================

# Get the directory where this script lives
SETUP_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Log light library
source "$SETUP_LIB_DIR/logger.sh"

# Test runner (provides run_suite, run_test_file, print_summary)
source "$SETUP_LIB_DIR/test_runner.sh"

# Test assertion libraries
for test_lib in assertions timeout deps tags fixtures; do
    lib_path="$SETUP_LIB_DIR/${test_lib}.sh"
    if [[ -f "$lib_path" ]]; then
        source "$lib_path"
    fi
done

# ============================================================================
# System Information (once per process) - logger is now available
# ============================================================================

if [[ -z "${_SYSTEM_INFO_PRINTED:-}" ]] && [[ "${LOG_LEVEL}" == "debug" ]]; then
    tlog_summary "System Information" \
        "  OS: $(uname -s)" \
        "  Kernel: $(uname -r)" \
        "  Machine: $(uname -m)" \
        "  Bash: $BASH_VERSION" \
        "  Date: $(date '+%Y-%m-%d %H:%M:%S %Z')" \
        "============================================================" \
        " Environment Configuration" \
        "============================================================" \
        "  LOG_LEVEL: ${LOG_LEVEL:-not set}" \
        "  LOG_OUTPUT: ${LOG_OUTPUT:-not set}" \
        "  CI: ${CI:-not set}" \
        "  TEST_DEV_MODE: ${TEST_DEV_MODE:-not set}"
    
    readonly _SYSTEM_INFO_PRINTED=1
fi

# ============================================================================
# Helper Functions
# ============================================================================

load_pipeline_lib() {
    local lib_name="$1"
    local lib_path="$PROJECT_ROOT/.github/scripts/lib/${lib_name}.sh"
    
    if [[ -f "$lib_path" ]]; then
        source "$lib_path"
        return 0
    fi
    tlog_error "Pipeline library not found: $lib_path"
    return 1
}

# ============================================================================
# Test Environment Setup
# ============================================================================

setup_test_environment() {
    # Read registry from temp .github directory
    local registry_file=".github/config/registry.conf"
    if [[ -f "$registry_file" ]]; then
        while IFS='|' read -r name handler required_fields || [[ -n "$name" ]]; do
            [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue
            for field in $required_fields; do
                export "$(echo "$field" | xargs)"="mock"
            done
        done < "$registry_file"
    fi
    
    export GH_PAT_GIST_TOKEN="mock"
    export DRY_RUN=true
}

# Overlay dev files for --dev mode
overlay_dev_files() {
    if [[ -d "$PROJECT_ROOT/tools/config/services-dev" ]]; then
        mkdir -p ".github/config/services"
        cp -r "$PROJECT_ROOT/tools/config/services-dev"/* ".github/config/services/" 2>/dev/null || true
    fi
    
    if [[ -f "$PROJECT_ROOT/tools/config/registry-dev.conf" ]]; then
        cp "$PROJECT_ROOT/tools/config/registry-dev.conf" ".github/config/registry.conf" 2>/dev/null || true
    fi
    
    if [[ -d "$PROJECT_ROOT/tools/handlers-dev" ]]; then
        mkdir -p ".github/scripts/handlers"
        cp "$PROJECT_ROOT/tools/handlers-dev"/*.sh ".github/scripts/handlers/" 2>/dev/null || true
    fi
}

# ============================================================================
# Fixture Helpers
# ============================================================================

use_fixture() {
    local fixture_path="$1"
    local target_path="${2:-$(basename "$fixture_path")}"
    local source_file="$PROJECT_ROOT/tools/tests/fixtures/input/$fixture_path"
    
    if [[ ! -f "$source_file" ]]; then
        tlog_error "Fixture not found: $source_file"
        return 1
    fi
    
    local target_dir=$(dirname "$target_path")
    [[ "$target_dir" != "." ]] && mkdir -p "$target_dir"
    
    cp "$source_file" "$target_path"
    tlog_debug "Fixture copied: $fixture_path -> $target_path"
}

create_test_post() {
    local fixture_name="$1"
    local custom_title="$2"
    local target_name="${3:-$(basename "$fixture_name" .md)}"
    local post_file="posts/${target_name}.md"
    
    mkdir -p posts
    use_fixture "posts/$fixture_name" "$post_file"
    
    if [[ -n "$custom_title" ]]; then
        sed -i "s/^title:.*/title: $custom_title/" "$post_file"
    fi
    
    echo "$post_file"
}

# ============================================================================
# Automatic Test Isolation
# ============================================================================

# Get test name from the file that sourced setup.sh
TEST_NAME=$(basename "${BASH_SOURCE[1]}" .sh 2>/dev/null || echo "unknown")

# Create isolated temp directory
TEST_TEMP_DIR=$(mktemp -d "/tmp/publisher-test-${TEST_NAME}-XXXXXX")
cd "$TEST_TEMP_DIR"

# Copy entire .github folder
if [[ -d "$PROJECT_ROOT/.github" ]]; then
    cp -r "$PROJECT_ROOT/.github" . 2>/dev/null || true
fi

# Overlay dev files if in dev mode
if [[ "${TEST_DEV_MODE:-false}" == "true" ]]; then
    overlay_dev_files
fi

# Create posts directory
mkdir -p posts

# Copy fixtures to posts directory
if [[ -d "$PROJECT_ROOT/tools/tests/fixtures/input/posts" ]]; then
    cp -r "$PROJECT_ROOT/tools/tests/fixtures/input/posts"/* posts/ 2>/dev/null || true
fi

export TEST_TEMP_DIR

# Register cleanup on exit
cleanup_test_environment() {
    cd "$PROJECT_ROOT"
    rm -rf "$TEST_TEMP_DIR"
}
trap cleanup_test_environment EXIT

# ============================================================================
# Default Configuration
# ============================================================================

TEST_TIMEOUT_SECONDS="${TEST_TIMEOUT_SECONDS:-30}"

if [[ "${LOG_LEVEL}" == "debug" ]]; then
    tlog_debug "Test setup complete"
    tlog_debug "  TEST_NAME: $TEST_NAME"
    tlog_debug "  TEST_TEMP_DIR: $TEST_TEMP_DIR"
    tlog_debug "  PROJECT_ROOT: $PROJECT_ROOT"
    tlog_debug "  LOG_FILE: $LOG_FILE"
    tlog_debug "  TEST_DEV_MODE: ${TEST_DEV_MODE:-false}"
    tlog_decoration
fi

# Load service config for a specific service (for tests that need it)
load_test_service_config() {
    local service="$1"
    local config_file="$PROJECT_ROOT/.github/config/services/${service}.conf"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        return 0
    fi
    return 1
}