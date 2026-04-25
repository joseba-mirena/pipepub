#!/bin/bash
# tools/tests/run_all_tests.sh - Main test runner

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the common setup (gives us PROJECT_ROOT and test libraries)
source "$SCRIPT_DIR/lib/setup.sh"

# ============================================================================
# Parse Arguments
# ============================================================================

TEST_FILTER=""
TEST_TAG_INCLUDE=""
TEST_TAG_EXCLUDE=""
UPDATE_SNAPSHOTS="${UPDATE_SNAPSHOTS:-false}"

while [[ $# -gt 0 ]]; do
    case $1 in
        --filter=*)
            TEST_FILTER="${1#--filter=}"
            shift
            ;;
        --tag=*)
            TEST_TAG_INCLUDE="${1#--tag=}"
            shift
            ;;
        --exclude=*)
            TEST_TAG_EXCLUDE="${1#--exclude=}"
            shift
            ;;
        --update-snapshots)
            UPDATE_SNAPSHOTS=true
            shift
            ;;
        --debug)
            # setup.sh handles --debug flag
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --filter=NAME        Run only test file matching NAME"
            echo "  --tag=TAG            Run only tests with TAG"
            echo "  --exclude=TAG        Exclude tests with TAG"
            echo "  --update-snapshots   Update snapshot files"
            echo "  --debug              Enable debug logging (captures output to .logs/)"
            echo "  --help               Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# ============================================================================
# Environment Setup
# ============================================================================

# Create directories in project root
mkdir -p "$PROJECT_ROOT/.logs" "$PROJECT_ROOT/.reports" "$PROJECT_ROOT/.tmp"

# Print test suite header (setup.sh already printed system info if debug)
echo "PipePub Test Suite"
echo "# Project: $PROJECT_ROOT"
echo "# Update snapshots: $UPDATE_SNAPSHOTS"
echo "# Log level: $LOG_LEVEL"
echo ""

# Run all tests in a subshell to prevent environment pollution
(
    # Set test environment
    TEST_MODE=true
    DRY_RUN=true
    UPDATE_SNAPSHOTS="$UPDATE_SNAPSHOTS"
    
    # Pass through needed variables
    export TEST_FILTER
    export TEST_TAG_INCLUDE
    export TEST_TAG_EXCLUDE
    export LOG_LEVEL
    export UPDATE_SNAPSHOTS
    export TEST_MODE
    export DRY_RUN
    export PROJECT_ROOT
    
    # Unset real tokens to ensure mocks are used
    unset DEVTO_TOKEN HASHNODE_TOKEN HASHNODE_PUBLICATION_ID MEDIUM_TOKEN GH_PAT_GIST_TOKEN
    
    # Run all test suites
    run_all_suites "$SCRIPT_DIR"
)

exit $?