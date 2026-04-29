#!/bin/bash
# tools/tests/unit/test_tags.sh
# @tags: unit fast

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "tags"

tag "test_tags.sh" "unit fast"

run_tests() {
    tlog_section "Test 1: Individual tag sanitization"
    
    declare -a test_cases=(
        "delete me"
        "delete-me"
        "delete_me"
        "  spaced tag  "
        "UPPERCASE"
        "áéíóú"
        "c#"
    )
    
    declare -a expected=(
        "delete_me"
        "delete_me"
        "delete_me"
        "spaced_tag"
        "uppercase"
        "aeiou"
        "c"
    )
    
    for i in "${!test_cases[@]}"; do
        input="${test_cases[$i]}"
        expected_output="${expected[$i]}"
        actual_output=$(sanitize_tag "$input")
        assert_equals "$actual_output" "$expected_output" "sanitize_tag '$input'"
    done
    
    tlog_section "Test 2: parse_tags with multiple tags"
    
    INPUT_TAGS="delete me, auto, test, dev ops, draft"
    declare -a expected_tags=("delete_me" "auto" "test" "dev_ops" "draft")
    
    declare -a parsed_tags=()
    parse_tags "$INPUT_TAGS" parsed_tags
    
    assert_equals "${#parsed_tags[@]}" "${#expected_tags[@]}" "parse_tags count"
    
    for i in "${!expected_tags[@]}"; do
        assert_equals "${parsed_tags[$i]}" "${expected_tags[$i]}" "parse_tags index $i"
    done
}

run_tests