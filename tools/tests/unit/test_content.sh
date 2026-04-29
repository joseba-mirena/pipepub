#!/bin/bash
# tools/tests/unit/test_content.sh
# @tags: unit fast

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "content"

tag "test_content.sh" "unit fast"

run_tests() {
    tlog_section "Test 1: Basic content extraction"
    
    use_fixture "posts/basic.md" "post.md"
    content=$(cat "post.md")
    clean_content=$(extract_clean_content "$content")
    title=$(extract_title "$clean_content")
    
    assert_equals "$title" "Basic Test Post Title" "extracted title"
    
    tlog_section "Test 2: Tag extraction from content"
    
    use_fixture "posts/with-tags.md" "posts/with-tags.md"
    content=$(cat "posts/with-tags.md")
    tags=$(extract_tags "" "$content")
    
    assert_contains "$tags" "bash" "contains bash tag"
    assert_contains "$tags" "github-actions" "contains github-actions tag"
}

run_tests