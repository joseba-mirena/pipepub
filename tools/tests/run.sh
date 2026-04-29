#!/bin/bash
# tools/tests/run.sh - Main test entry point

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================================
# Parse Arguments
# ============================================================================

TEST_FILTER=""
TEST_DEV_MODE="false"
SUITES=()
UPDATE_SNAPSHOTS="${UPDATE_SNAPSHOTS:-false}"

# First, check for --dev flag
for arg in "$@"; do
    if [[ "$arg" == "--dev" ]]; then
        TEST_DEV_MODE="true"
    fi
done

# Then parse other arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dev)
            shift
            ;;
        --quick)
            SUITES=("unit" "integration")
            shift
            ;;
        --unit)
            SUITES=("unit")
            shift
            ;;
        --integration)
            SUITES=("integration")
            shift
            ;;
        --e2e)
            SUITES=("e2e")
            shift
            ;;
        --filter=*)
            TEST_FILTER="${1#--filter=}"
            shift
            ;;
        --update-snapshots)
            UPDATE_SNAPSHOTS=true
            shift
            ;;
        --debug)
            # Pass through to setup.sh
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --dev                Run dev tests only (requires dev files in tools/tests/dev/)"
            echo "  --quick              Run unit + integration tests (fast, no e2e)"
            echo "  --unit               Run only unit tests"
            echo "  --integration        Run only integration tests"
            echo "  --e2e                Run only e2e tests"
            echo "  --filter=NAME        Run only test file matching NAME"
            echo "  --update-snapshots   Update snapshot files"
            echo "  --debug              Enable debug logging"
            echo "  --help               Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Default: run all production suites
if [[ ${#SUITES[@]} -eq 0 ]] && [[ "$TEST_DEV_MODE" != "true" ]]; then
    SUITES=("unit" "integration" "e2e")
fi

# Dev mode: only dev suite
if [[ "$TEST_DEV_MODE" == "true" ]]; then
    SUITES=("dev")
fi

# ============================================================================
# Run Tests
# ============================================================================

# Source setup.sh (sets up environment and sources test_runner.sh)
source "$SCRIPT_DIR/lib/setup.sh"

# Export variables for test_runner
export TEST_FILTER
export UPDATE_SNAPSHOTS
export TEST_DEV_MODE

# Print test suite header using logger
tlog_section " PipePub Test Suite" \
    "  Project: $PROJECT_ROOT" \
    "  Update snapshots: $UPDATE_SNAPSHOTS" \
    "  Log level: $LOG_LEVEL" \
    "  Dev mode: $TEST_DEV_MODE"

# Run each requested suite
for suite in "${SUITES[@]}"; do
    case "$suite" in
        unit)
            run_suite "Unit Tests" "$SCRIPT_DIR/unit"
            ;;
        integration)
            run_suite "Integration Tests" "$SCRIPT_DIR/integration"
            ;;
        e2e)
            run_suite "E2E Tests" "$SCRIPT_DIR/e2e"
            ;;
        dev)
            if [[ -d "$SCRIPT_DIR/dev" ]]; then
                run_suite "Dev Tests" "$SCRIPT_DIR/dev"
            else
                tlog_warning "No dev tests found in $SCRIPT_DIR/dev"
                tlog_info "Create dev tests or remove --dev flag"
            fi
            ;;
    esac
done

# Print final summary
print_summary

exit $?