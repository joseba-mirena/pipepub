#!/bin/bash
# tools/tests/lib/tags.sh - Test tagging and filtering

# Tag registry
declare -A TEST_TAGS

# Add tags to a test
tag() {
    local test_name="$1"
    local tags="$2"
    TEST_TAGS["$test_name"]="$tags"
}

# Get tags for a test
get_tags() {
    local test_name="$1"
    echo "${TEST_TAGS[$test_name]}"
}

# Check if test has tag
has_tag() {
    local test_name="$1"
    local target_tag="$2"
    local tags="${TEST_TAGS[$test_name]}"
    
    # Split tags by space
    for tag in $tags; do
        if [[ "$tag" == "$target_tag" ]]; then
            return 0
        fi
    done
    return 1
}

# Filter tests by tag
filter_by_tag() {
    local target_tag="$1"
    shift
    local tests=("$@")
    local filtered=()
    
    for test in "${tests[@]}"; do
        if has_tag "$test" "$target_tag"; then
            filtered+=("$test")
        fi
    done
    
    printf '%s\n' "${filtered[@]}"
}

# Filter out tests with tag
exclude_tag() {
    local exclude_tag="$1"
    shift
    local tests=("$@")
    local filtered=()
    
    for test in "${tests[@]}"; do
        if ! has_tag "$test" "$exclude_tag"; then
            filtered+=("$test")
        fi
    done
    
    printf '%s\n' "${filtered[@]}"
}

# Parse tag filter from environment
parse_tag_filter() {
    local include="${TEST_TAG_INCLUDE:-}"
    local exclude="${TEST_TAG_EXCLUDE:-}"
    
    if [[ -n "$include" ]]; then
        echo "include:$include"
    elif [[ -n "$exclude" ]]; then
        echo "exclude:$exclude"
    else
        echo "all"
    fi
}