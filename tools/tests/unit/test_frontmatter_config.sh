#!/bin/bash
# tools/tests/unit/test_frontmatter_config.sh
# @tags: unit fast

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "frontmatter"

tag "test_frontmatter_config.sh" "unit fast"

run_tests() {
    tlog_section "Test 1: Gist enabled"
    
    mkdir -p posts
    
    use_fixture "posts/gist-true.md" "posts/gist-true.md"
    
    local content=$(cat "posts/gist-true.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_GIST" "true" "gist should be true"
    
    tlog_section "Test 2: Gist disabled (default)"
    
    use_fixture "posts/gist-false.md" "posts/gist-false.md"
    
    content=$(cat "posts/gist-false.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_GIST" "" "gist should be empty (default applied by main.sh)"
    
    tlog_section "Test 3: Status public"
    
    use_fixture "posts/status-public.md" "posts/status-public.md"
    
    content=$(cat "posts/status-public.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_STATUS" "public" "status should be public"
    
    tlog_section "Test 4: Status draft"
    
    use_fixture "posts/status-draft.md" "posts/status-draft.md"
    
    content=$(cat "posts/status-draft.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_STATUS" "draft" "status should be draft"
    
    tlog_section "Test 5: Auto false (manual publish only)"
    
    use_fixture "posts/auto-false.md" "posts/auto-false.md"
    
    content=$(cat "posts/auto-false.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_AUTO" "false" "auto should be false"
    
    tlog_section "Test 6: Auto true (default)"
    
    use_fixture "posts/auto-true.md" "posts/auto-true.md"
    
    content=$(cat "posts/auto-true.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_AUTO" "" "auto should be empty (default true applied by main.sh)"
    
    tlog_section "Test 7: Single publisher"
    
    use_fixture "posts/single-publisher.md" "posts/single-publisher.md"
    
    content=$(cat "posts/single-publisher.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_PUBLISHER" "devto" "publisher should be devto"
    
    tlog_section "Test 8: Multiple publishers"
    
    use_fixture "posts/multi-publisher.md" "posts/multi-publisher.md"
    
    content=$(cat "posts/multi-publisher.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_PUBLISHER" "devto, hashnode" "publisher should be devto, hashnode"
    
    tlog_section "Test 9: Cover image"
    
    use_fixture "posts/with-cover.md" "posts/with-cover.md"
    
    content=$(cat "posts/with-cover.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_COVER_IMAGE" "https://example.com/cover.jpg" "cover_image should be set"
    
    tlog_section "Test 10: All fields combined"
    
    use_fixture "posts/all-fields.md" "posts/all-fields.md"
    
    content=$(cat "posts/all-fields.md")
    parse_frontmatter "$content"
    
    assert_equals "$FRONTMATTER_TAGS" "full, complete, test" "tags"
    assert_equals "$FRONTMATTER_TITLE" "Complete Post" "title"
    assert_equals "$FRONTMATTER_SUBTITLE" "This is a comprehensive test" "subtitle"
    assert_equals "$FRONTMATTER_STATUS" "public" "status"
    assert_equals "$FRONTMATTER_AUTO" "false" "auto"
    assert_equals "$FRONTMATTER_GIST" "true" "gist"
    assert_equals "$FRONTMATTER_PUBLISHER" "devto, hashnode, medium" "publisher"
    assert_equals "$FRONTMATTER_COVER_IMAGE" "https://example.com/cover.jpg" "cover_image"
}

run_tests