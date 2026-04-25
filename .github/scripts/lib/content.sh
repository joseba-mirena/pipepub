#!/bin/bash
# .github/scripts/lib/content.sh - Content extraction processor

extract_title() {
    local content="$1"
    local title=""
    
    # Try to find first # heading
    title=$(echo "$content" | grep -m1 '^# ' | sed 's/^# //')
    
    # If no markdown heading, try any heading
    if [[ -z "$title" ]]; then
        title=$(echo "$content" | grep -m1 '^#\{1,6\} ' | sed 's/^#\{1,6\} //')
    fi
    
    # Trim whitespace
    title=$(echo "$title" | xargs)
    
    echo "$title"
}

extract_tags() {
    local frontmatter_tags="$1"
    local content="$2"
    local -a tags_array=()
    
    # Priority 1: Tags from frontmatter
    if [[ -n "$frontmatter_tags" ]]; then
        # Handle array format: ["tag1", "tag2"] or "tag1, tag2"
        if [[ "$frontmatter_tags" =~ ^\[.*\]$ ]]; then
            tags_array=($(echo "$frontmatter_tags" | jq -r '.[]' 2>/dev/null | tr '\n' ' '))
        else
            IFS=',' read -ra tags_array <<< "$frontmatter_tags"
        fi
    else
        # Priority 2: Extract hashtags from content
        while IFS= read -r tag; do
            tag=$(echo "$tag" | sed 's/^#//' | tr -d '()[]{}' | xargs)
            if [[ -n "$tag" ]]; then
                # Replace spaces with underscores
                tag=$(echo "$tag" | tr ' ' '_')
                tags_array+=("$tag")
            fi
        done < <(echo "$content" | grep -o '#[a-zA-Z0-9_-]\+' | sort -u)
    fi
    
    # Remove duplicates and clean
    local unique_tags=($(printf "%s\n" "${tags_array[@]}" | sort -u))
    
    # Convert array to comma-separated string
    local tags_string=$(IFS=,; echo "${unique_tags[*]}")
    echo "$tags_string"
}

# Extract content without frontmatter (preserving ALL other --- in the document)
extract_clean_content() {
    local file_path="$1"
    
    # Remove ONLY the first frontmatter block (between first two ---)
    # Preserve all other --- that appear in code blocks or content
    awk '
        BEGIN { in_frontmatter=0; frontmatter_ended=0; }
        {
            if (frontmatter_ended) {
                print;
                next;
            }
            if ($0 == "---" && in_frontmatter == 0) {
                in_frontmatter=1;
                next;
            }
            if ($0 == "---" && in_frontmatter == 1) {
                frontmatter_ended=1;
                next;
            }
            if (in_frontmatter == 0) {
                print;
            }
        }
    ' "$file_path"
}