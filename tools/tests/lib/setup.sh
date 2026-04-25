#!/bin/bash
# tools/tests/lib/setup.sh - Common test environment setup

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

# Export for use in tests
export PROJECT_ROOT
export CALLER_DIR

# ============================================================================
# Environment Loading (.env first - sets defaults)
# ============================================================================

if [[ -f "$PROJECT_ROOT/.env" ]]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
fi

# Set defaults if not defined by .env
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
        *)
            shift
            ;;
    esac
done

export LOG_LEVEL
export LOG_OUTPUT

# ============================================================================
# Output Capture (when LOG_LEVEL=debug)
# ============================================================================

if [[ "$LOG_LEVEL" == "debug" ]] && [[ -z "${_OUTPUT_CAPTURED:-}" ]]; then
    # Create logs directory
    mkdir -p "$PROJECT_ROOT/.logs"
    
    # Generate log filename based on test name
    TEST_NAME=$(basename "${BASH_SOURCE[1]}" .sh 2>/dev/null || echo "unknown")
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    TEST_LOG_FILE="$PROJECT_ROOT/.logs/test_${TEST_NAME}_${TIMESTAMP}.log"
    
    # Capture output to file while still showing on console
    exec > >(tee -a "$TEST_LOG_FILE") 2>&1
    readonly _OUTPUT_CAPTURED=1
    
    echo "# Test output captured to: $TEST_LOG_FILE"
fi

# ============================================================================
# System Information (once per process)
# ============================================================================

print_system_info() {
    local kernel_name=$(uname -s)
    local hostname=$(uname -n)
    local kernel_release=$(uname -r)
    local machine=$(uname -m)
    local processor=$(uname -p 2>/dev/null || echo "unknown")
    
    local os_pretty=""
    if [[ -f /etc/os-release ]]; then
        os_pretty=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
    fi
    
    echo "# ================================================================"
    echo "# System Information"
    echo "# ================================================================"
    echo "#   OS: ${os_pretty:-$kernel_name}"
    echo "#   Kernel: $kernel_release"
    echo "#   Machine: $machine"
    echo "#   Processor: $processor"
    echo "#   Hostname: $hostname"
    echo "#   Bash: $BASH_VERSION"
    echo "#   Date: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "#   Timeout: $(command -v timeout 2>/dev/null || echo 'not found')"
    echo "#   jq: $(command -v jq 2>/dev/null || echo 'not found')"
    echo "# ================================================================"
    echo "# Environment Configuration"
    echo "# ================================================================"
    echo "#   LOG_LEVEL: ${LOG_LEVEL:-not set}"
    echo "#   LOG_OUTPUT: ${LOG_OUTPUT:-not set}"
    echo "#   DRY_RUN: ${DRY_RUN:-not set}"
    echo "#   TEST_MODE: ${TEST_MODE:-not set}"
    echo "#   CI: ${CI:-not set}"
    echo "# ================================================================"
    echo ""
}

if [[ -z "${_SYSTEM_INFO_PRINTED:-}" ]] && [[ "${LOG_LEVEL}" == "debug" ]]; then
    print_system_info
    readonly _SYSTEM_INFO_PRINTED=1
fi

# ============================================================================
# Create Log Directories in Project Root
# ============================================================================

mkdir -p "$PROJECT_ROOT/.tmp" "$PROJECT_ROOT/.reports"

# Set absolute path for pipeline logs (used by logging.sh)
export LOG_FILE="$PROJECT_ROOT/.tmp/pipepub_$(date +%Y%m%d_%H%M%S).log"

# ============================================================================
# Load Pipeline Libraries
# ============================================================================

source "$PROJECT_ROOT/.github/scripts/lib/logging.sh"

# ============================================================================
# Helper Functions
# ============================================================================

load_pipeline_lib() {
    local lib_name="$1"
    local lib_path="$PROJECT_ROOT/.github/scripts/lib/${lib_name}.sh"
    
    if [[ -f "$lib_path" ]]; then
        source "$lib_path"
        return 0
    else
        echo "ERROR: Pipeline library not found: $lib_path" >&2
        return 1
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
        echo "ERROR: Fixture not found: $source_file"
        return 1
    fi
    
    local target_dir=$(dirname "$target_path")
    if [[ "$target_dir" != "." ]]; then
        mkdir -p "$target_dir"
    fi
    
    cp "$source_file" "$target_path"
    echo "$target_path"
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
# Source Test Libraries
# ============================================================================

TEST_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for test_lib in assertions timeout deps tags fixtures test_runner; do
    lib_path="$TEST_LIB_DIR/${test_lib}.sh"
    if [[ -f "$lib_path" ]]; then
        source "$lib_path"
    fi
done

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

# Create posts directory
mkdir -p posts

# Copy fixtures to posts directory
if [[ -d "$PROJECT_ROOT/tools/tests/fixtures/input/posts" ]]; then
    cp -r "$PROJECT_ROOT/tools/tests/fixtures/input/posts"/* posts/ 2>/dev/null || true
fi

# Export temp directory for any cleanup needs
export TEST_TEMP_DIR

# Register cleanup on exit (only removes temp dir)
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
    echo "# DEBUG: Test setup complete" >&2
    echo "# DEBUG:   TEST_NAME: $TEST_NAME" >&2
    echo "# DEBUG:   TEST_TEMP_DIR: $TEST_TEMP_DIR" >&2
    echo "# DEBUG:   PROJECT_ROOT: $PROJECT_ROOT" >&2
    echo "# DEBUG:   LOG_FILE: $LOG_FILE" >&2
fi