#!/bin/bash
# tools/tests/unit/test_content.sh
# @tags: unit fast

# Source common setup (auto-isolation happens here)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/setup.sh"

# Load required pipeline libraries
load_pipeline_lib "content"

tag "test_content.sh" "unit fast"

run_tests() {
    echo "# Test 1: Basic content extraction"
    
    use_fixture "posts/basic.md" "post.md"
    
    content=$(extract_clean_content "post.md")
    title=$(extract_title "$content")
    
    assert_equals "$title" "Basic Test Post Title" "extracted title"
    
    echo ""
    echo "# Test 2: Tag extraction from content"
    
    cat > "tags_content.md" << 'EOF'
# Article
Content with #bash and #github-actions tags.
EOF
    
    content=$(cat "tags_content.md")
    tags=$(extract_tags "" "$content")
    
    assert_contains "$tags" "bash" "contains bash tag"
    assert_contains "$tags" "github-actions" "contains github-actions tag"
}

run_tests
tap_exit_code