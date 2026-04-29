#!/bin/bash
# tools/tests/unit/test_frontmatter.sh
# @tags: unit fast

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "frontmatter"

tag "test_frontmatter.sh" "unit fast"

run_tests() {
    tlog_section "Test 1: Parse full frontmatter"
    
    mkdir -p posts
    
    use_fixture "posts/full.md" "posts/full.md"
    
    # Read file content and pass as string
    local content=$(cat "posts/full.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_TAGS" "full, complete, demo, test" "tags"
    assert_equals "$FRONTMATTER_TITLE" "Full Featured Post" "title"
    assert_equals "$FRONTMATTER_STATUS" "public" "status"
    
    tlog_section "Test 2: Parse minimal frontmatter"
    
    use_fixture "posts/minimal.md" "posts/minimal.md"
    
    content=$(cat "posts/minimal.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_TITLE" "Minimal Post" "title"
    assert_equals "$FRONTMATTER_TAGS" "" "tags should be empty"
}

run_tests