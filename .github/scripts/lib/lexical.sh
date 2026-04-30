#!/bin/bash
# .github/scripts/lib/lexical.sh - Markdown to Ghost Lexical

set -euo pipefail

# Format Bitmasks
F_BOLD=1; F_ITALIC=2; F_STRIKE=4; F_CODE=8

# Debug mode (set MD_DEBUG=1 to enable)
MD_DEBUG="${MD_DEBUG:-0}"
_debug() { [ "$MD_DEBUG" -eq 1 ] && echo "[DEBUG] $*" >&2; }

_json_escape() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\r'/\\r}"
    str="${str//$'\t'/\\t}"
    printf '%s' "$str"
}

# Recursive Inline Parser: Handles nested formatting and bitmasking
_p_inline() {
    local text="$1"
    local fmt="${2:-0}"
    local nodes=""

    # Prioritize regex matching to handle nested nodes
    local re_code='^([^`]*)\`([^`]+)\`(.*)$'
    local re_img='^([^!]*)!\[([^\]]*)\]\(([^)]+)\)(.*)$'
    local re_link='^([^\[]*)\[([^\]]+)\]\(([^)]+)\)(.*)$'
    local re_bold='^([^\*_]*)(\*\*|__)([^\*_]+)(\*\*|__)(.*)$'
    local re_ital='^([^\*_]*)(\*|_)([^\*_]+)(\*|_)(.*)$'
    local re_strike='^([^~]*)~~([^~]+)~~(.*)$'

    if [[ "$text" =~ $re_code ]]; then
        [ -n "${BASH_REMATCH[1]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[1]}" "$fmt"),"
        nodes+="{\"type\":\"text\",\"text\":\"$(_json_escape "${BASH_REMATCH[2]}")\",\"format\":$F_CODE},"
        [ -n "${BASH_REMATCH[3]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[3]}" "$fmt")"
    elif [[ "$text" =~ $re_img ]]; then
        [ -n "${BASH_REMATCH[1]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[1]}" "$fmt"),"
        nodes+="{\"type\":\"image\",\"version\":1,\"src\":\"${BASH_REMATCH[3]}\",\"altText\":\"$(_json_escape "${BASH_REMATCH[2]}")\"},"
        [ -n "${BASH_REMATCH[4]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[4]}" "$fmt")"
    elif [[ "$text" =~ $re_link ]]; then
        [ -n "${BASH_REMATCH[1]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[1]}" "$fmt"),"
        nodes+="{\"type\":\"link\",\"version\":1,\"url\":\"${BASH_REMATCH[3]}\",\"children\":[$(_p_inline "${BASH_REMATCH[2]}" "$fmt")]},"
        [ -n "${BASH_REMATCH[4]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[4]}" "$fmt")"
    elif [[ "$text" =~ $re_bold ]]; then
        [ -n "${BASH_REMATCH[1]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[1]}" "$fmt"),"
        nodes+="$(_p_inline "${BASH_REMATCH[3]}" $((fmt | F_BOLD))),"
        [ -n "${BASH_REMATCH[5]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[5]}" "$fmt")"
    elif [[ "$text" =~ $re_ital ]]; then
        [ -n "${BASH_REMATCH[1]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[1]}" "$fmt"),"
        nodes+="$(_p_inline "${BASH_REMATCH[3]}" $((fmt | F_ITALIC))),"
        [ -n "${BASH_REMATCH[5]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[5]}" "$fmt")"
    elif [[ "$text" =~ $re_strike ]]; then
        [ -n "${BASH_REMATCH[1]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[1]}" "$fmt"),"
        nodes+="$(_p_inline "${BASH_REMATCH[2]}" $((fmt | F_STRIKE))),"
        [ -n "${BASH_REMATCH[3]}" ] && nodes+="$(_p_inline "${BASH_REMATCH[3]}" "$fmt")"
    else
        [ -n "$text" ] && nodes+="{\"type\":\"text\",\"text\":\"$(_json_escape "$text")\",\"format\":$fmt}"
    fi
    # Use sed to clean up recursive commas that break JSON arrays
    echo "$nodes" | sed 's/,,/,/g; s/,$//; s/^,//'
}

# Block Generators with mandatory Ghost Lexical fields
_node_p() { printf '{"type":"paragraph","version":1,"children":[%s],"direction":"ltr"}' "$(_p_inline "$1")"; }
_node_h() { printf '{"type":"heading","version":1,"tag":"h%s","children":[%s],"direction":"ltr"}' "$1" "$(_p_inline "$2")"; }
_node_quote() { 
    local content="$1"
    # Split multi-line blockquotes into multiple paragraphs
    local paragraphs=""
    local IFS=$'\n'
    for para in $content; do
        [ -n "$para" ] && paragraphs+="$(_node_p "$para"),"
    done
    paragraphs="${paragraphs%,}"
    printf '{"type":"quote","version":1,"children":[%s],"direction":"ltr"}' "$paragraphs"
}
_node_code() {
    printf '{"type":"code","version":1,"language":"%s","children":[{"type":"text","text":"%s"}]}' \
        "${2:-plaintext}" "$(_json_escape "$1")"
}
_node_horizontal_rule() {
    printf '{"type":"horizontalrule","version":1}'
}

# Enhanced list generator with proper nesting support
_node_list() {
    local type="$1"
    local indent_level="$2"
    shift 2
    local items=("$@")
    local children=""
    
    for item in "${items[@]}"; do
        # Extract content and nested lists
        local content="$item"
        local nested_lists=""
        
        # Check for nested list indicator (indentation-based nesting)
        if [[ "$content" =~ \|\|\|NESTED\|(.*)\|\| ]]; then
            nested_lists="${BASH_REMATCH[1]}"
            content="${content%%|||NESTED||*}"
        fi
        
        # Task list detection
        if [[ "$content" =~ ^\[([ x])\]\ (.*)$ ]]; then
            local checked="false"
            [ "${BASH_REMATCH[1]}" = "x" ] && checked="true"
            local task_text="${BASH_REMATCH[2]}"
            
            # Build listitem with proper child structure
            local item_json
            if [ -n "$nested_lists" ]; then
                # Lexical structure: listitem -> [text_node, nested_list_node]
                item_json="{\"type\":\"listitem\",\"version\":1,\"checked\":$checked,\"children\":[$(_p_inline "$task_text"),$nested_lists]}"
            else
                item_json="{\"type\":\"listitem\",\"version\":1,\"checked\":$checked,\"children\":[$(_p_inline "$task_text")]}"
            fi
            children+="$item_json,"
        else
            # Regular list item (not a task)
            local item_json
            if [ -n "$nested_lists" ]; then
                # Lexical structure: listitem -> [text_node, nested_list_node]
                item_json="{\"type\":\"listitem\",\"version\":1,\"children\":[$(_p_inline "$content"),$nested_lists]}"
            else
                item_json="{\"type\":\"listitem\",\"version\":1,\"children\":[$(_p_inline "$content")]}"
            fi
            children+="$item_json,"
        fi
    done
    
    children="${children%,}"
    printf '{"type":"list","version":1,"listType":"%s","tag":"%s","start":1,"children":[%s]}' "$type" "$type" "$children"
}

# Enhanced table generator with better alignment handling
_node_table() {
    local header="$1" align="$2"
    shift 2
    local rows=("$@")
    
    # Parse header
    header="${header#|}"; header="${header%|}"
    local header_cells=""
    local IFS='|'
    for cell in $header; do
        cell=$(echo "$cell" | xargs)
        header_cells+="{\"type\":\"tablecell\",\"version\":1,\"header\":true,\"children\":[$(_p_inline "$cell")]},"
    done
    header_cells="${header_cells%,}"
    
    # Parse alignment
    local aligns=()
    if [ -n "$align" ]; then
        align="${align#|}"; align="${align%|}"
        for a in $align; do
            a=$(echo "$a" | xargs)
            if [[ "$a" =~ ^:.*:$ ]]; then aligns+=("center")
            elif [[ "$a" =~ ^: ]]; then aligns+=("left")
            elif [[ "$a" =~ :$ ]]; then aligns+=("right")
            else aligns+=("left")
            fi
        done
    fi
    
    # Parse body rows
    local body_rows=""
    for row in "${rows[@]}"; do
        row="${row#|}"; row="${row%|}"
        local cells=""
        local idx=0
        for cell in $row; do
            cell=$(echo "$cell" | xargs)
            local align_val="${aligns[$idx]:-left}"
            cells+="{\"type\":\"tablecell\",\"version\":1,\"header\":false,\"align\":\"$align_val\",\"children\":[$(_p_inline "$cell")]},"
            idx=$((idx+1))
        done
        cells="${cells%,}"
        body_rows+="{\"type\":\"tablerow\",\"version\":1,\"children\":[$cells]},"
    done
    body_rows="${body_rows%,}"
    
    printf '{"type":"table","version":1,"children":[{"type":"tablerow","version":1,"children":[%s]},%s]}' "$header_cells" "$body_rows"
}

# Detect indentation level for nested lists
_get_indent_level() {
    local line="$1"
    local indent=0
    while [[ "$line" =~ ^[[:space:]]{2} ]]; do
        indent=$((indent + 1))
        line="${line:2}"
    done
    echo "$indent"
}

_convert() {
    local input="${1:-/dev/stdin}"
    local children=""
    local line prev_line=""
    
    # State tracking
    local in_code=0 code_lang="" code_buffer=""
    local in_list=0 list_type="" list_items=() list_indent=0
    local in_table=0 table_header="" table_align="" table_rows=()
    local in_quote=0 quote_buffer=""
    local in_html=0 html_buffer=""

    while IFS= read -r line || [ -n "$line" ]; do
        _debug "Processing: $line"
        
        # 1. Code Blocks
        if [[ "$line" =~ ^\`\`\`([a-z]*)$ ]]; then
            if [ $in_code -eq 0 ]; then
                # Close any open blocks
                [ $in_quote -eq 1 ] && { children+="$(_node_quote "$quote_buffer"),"; in_quote=0; quote_buffer=""; }
                [ $in_list -eq 1 ] && { children+="$(_node_list "$list_type" "$list_indent" "${list_items[@]}"),"; in_list=0; list_items=(); }
                in_code=1; code_lang="${BASH_REMATCH[1]}"; code_buffer=""
                _debug "Opening code block: ${code_lang:-plaintext}"
            else
                children+="$(_node_code "$code_buffer" "$code_lang"),"
                in_code=0
                _debug "Closing code block"
            fi
            continue
        fi
        [ $in_code -eq 1 ] && { code_buffer+="$line"$'\n'; continue; }
        
        # 2. HTML Blocks (pass through as-is - Ghost handles them)
        if [[ "$line" =~ ^[[:space:]]*\<[a-zA-Z] ]]; then
            if [ $in_html -eq 0 ]; then
                in_html=1
                html_buffer=""
                _debug "Opening HTML block"
            fi
            html_buffer+="$line"$'\n'
            continue
        elif [ $in_html -eq 1 ] && [[ "$line" =~ ^[[:space:]]*\</[a-zA-Z] ]]; then
            html_buffer+="$line"
            # Ghost can handle raw HTML in paragraphs
            children+="$(_node_p "$html_buffer"),"
            in_html=0
            html_buffer=""
            continue
        elif [ $in_html -eq 1 ]; then
            html_buffer+="$line"$'\n'
            continue
        fi
        
        # 3. Tables
        if [[ "$line" =~ ^\|.*\|$ ]]; then
            if [ $in_table -eq 0 ]; then
                [ $in_list -eq 1 ] && { children+="$(_node_list "$list_type" "$list_indent" "${list_items[@]}"),"; in_list=0; list_items=(); }
                in_table=1; table_header="$line"; table_align=""; table_rows=()
                _debug "Opening table"
            elif [[ "$line" =~ ^\|[\ \:\-]+\|$ ]]; then
                table_align="$line"
                _debug "Table alignment row"
            else
                table_rows+=("$line")
            fi
            continue
        elif [ $in_table -eq 1 ]; then
            children+="$(_node_table "$table_header" "$table_align" "${table_rows[@]}"),"
            in_table=0
            _debug "Closing table"
        fi
        
        # 4. Setext Headings (must come before horizontal rule detection)
        if [[ "$line" =~ ^(=+|-+)$ ]] && [ -n "$prev_line" ] && [ ${#line} -gt 2 ]; then
            local level=1
            [[ "$line" =~ ^-+ ]] && level=2
            # Remove the previous paragraph node to promote it to a heading
            children="${children%$(_node_p "$prev_line"),}"
            children+="$(_node_h "$level" "$prev_line"),"
            prev_line=""
            _debug "Setext heading: level=$level"
            continue
        fi
        
        # 5. Horizontal Rules
        if [[ "$line" =~ ^[[:space:]]*[\-\*\_]{3,}[[:space:]]*$ ]]; then
            [ $in_list -eq 1 ] && { children+="$(_node_list "$list_type" "$list_indent" "${list_items[@]}"),"; in_list=0; list_items=(); }
            [ $in_quote -eq 1 ] && { children+="$(_node_quote "$quote_buffer"),"; in_quote=0; quote_buffer=""; }
            children+="$(_node_horizontal_rule),"
            prev_line=""
            _debug "Horizontal rule"
            continue
        fi
        
        # 6. ATX Headings
        if [[ "$line" =~ ^(#{1,6})[[:space:]]+(.*)$ ]]; then
            [ $in_list -eq 1 ] && { children+="$(_node_list "$list_type" "$list_indent" "${list_items[@]}"),"; in_list=0; list_items=(); }
            [ $in_quote -eq 1 ] && { children+="$(_node_quote "$quote_buffer"),"; in_quote=0; quote_buffer=""; }
            children+="$(_node_h "${#BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"),"
            prev_line=""
            _debug "ATX heading: level=${#BASH_REMATCH[1]}"
            continue
        fi
        
        # 7. Blockquotes (multi-line support)
        if [[ "$line" =~ ^\>[[:space:]]?(.*)$ ]]; then
            [ $in_list -eq 1 ] && { children+="$(_node_list "$list_type" "$list_indent" "${list_items[@]}"),"; in_list=0; list_items=(); }
            local quote_content="${BASH_REMATCH[1]}"
            
            if [ $in_quote -eq 0 ]; then
                in_quote=1
                quote_buffer="$quote_content"
                _debug "Opening blockquote"
            else
                quote_buffer+=$'\n'"$quote_content"
            fi
            continue
        elif [ $in_quote -eq 1 ] && [ -z "$line" ]; then
            # Blank line - keep accumulating (multi-line quote continues)
            quote_buffer+=$'\n'
            continue
        elif [ $in_quote -eq 1 ]; then
            # Non-quote line - close the quote
            children+="$(_node_quote "$quote_buffer"),"
            in_quote=0
            quote_buffer=""
            # Fall through to process current line as paragraph
        fi
        
        # 8. Lists with indentation/nesting detection
        # Check for indented lines (nested lists)
        local indent_level=$(_get_indent_level "$line")
        local trimmed_line="${line#"${line%%[![:space:]]*}"}"
        
        if [[ "$trimmed_line" =~ ^([\*\-]|[0-9]+\.)[[:space:]]+(.*)$ ]]; then
            local new_type="ul"
            [[ "$trimmed_line" =~ ^[0-9] ]] && new_type="ol"
            local content="${BASH_REMATCH[2]}"
            
            _debug "List detected: type=$new_type, indent=$indent_level, content=$content"
            
            # Handle nested lists based on indentation
            if [ $in_list -eq 0 ]; then
                # Starting a new list
                in_list=1
                list_type="$new_type"
                list_indent="$indent_level"
                list_items=("$content")
                _debug "Starting new list (type=$new_type, indent=$indent_level)"
            elif [ "$indent_level" -gt "$list_indent" ]; then
                # Nested list - mark as nested and continue
                _debug "Nested list detected (indent=$indent_level > $list_indent)"
                # Store nested indicator
                content="|||NESTED||$(_node_list "$new_type" "$indent_level" "$content")||$content"
                list_items[-1]="${list_items[-1]}$content"
            elif [ "$indent_level" -eq "$list_indent" ] && [ "$list_type" != "$new_type" ]; then
                # Different list type at same level
                children+="$(_node_list "$list_type" "$list_indent" "${list_items[@]}"),"
                list_type="$new_type"
                list_items=("$content")
                _debug "Switching list type to $new_type"
            elif [ "$indent_level" -eq "$list_indent" ]; then
                # Same level, same type - add to current list
                list_items+=("$content")
                _debug "Adding to current list"
            elif [ "$indent_level" -lt "$list_indent" ]; then
                # Less indentation - close current list
                children+="$(_node_list "$list_type" "$list_indent" "${list_items[@]}"),"
                in_list=0
                list_items=()
                _debug "Closing list (indent decreased)"
                # Don't continue - let the line be re-evaluated
            fi
            prev_line=""
            continue
        elif [ $in_list -eq 1 ] && [ -z "$line" ]; then
            # Blank line after list - close it
            children+="$(_node_list "$list_type" "$list_indent" "${list_items[@]}"),"
            in_list=0
            list_items=()
            _debug "Closing list (blank line)"
            continue
        elif [ $in_list -eq 1 ]; then
            # Non-list line - close list and process as paragraph
            children+="$(_node_list "$list_type" "$list_indent" "${list_items[@]}"),"
            in_list=0
            list_items=()
            _debug "Closing list (non-list line)"
            # Fall through to paragraph processing
        fi
        
        # 9. Regular Paragraphs (skip empty lines)
        if [[ -n "$line" ]]; then
            children+="$(_node_p "$line"),"
            prev_line="$line"
            _debug "Paragraph: ${line:0:50}..."
        else
            prev_line=""
        fi
    done < "$input"
    
    # Final block closures
    [ $in_code -eq 1 ] && children+="$(_node_code "$code_buffer" "$code_lang"),"
    [ $in_list -eq 1 ] && children+="$(_node_list "$list_type" "$list_indent" "${list_items[@]}"),"
    [ $in_table -eq 1 ] && children+="$(_node_table "$table_header" "$table_align" "${table_rows[@]}"),"
    [ $in_quote -eq 1 ] && children+="$(_node_quote "$quote_buffer"),"
    [ $in_html -eq 1 ] && children+="$(_node_p "$html_buffer"),"

    # Remove trailing comma and assemble final JSON
    children="${children%,}"
    printf '{"root":{"children":[%s],"direction":"ltr","format":"","indent":0,"type":"root","version":1}}' "$children"
}

# Public API
md_to_ghost_lexical() { 
    if [ -n "${1:-}" ] && [ -f "$1" ]; then
        _convert "$1"
    else
        _convert
    fi
}

# Debug version
md_to_ghost_lexical_debug() {
    MD_DEBUG=1 md_to_ghost_lexical "$@"
}

# Export for sourcing
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f md_to_ghost_lexical
    export -f md_to_ghost_lexical_debug
fi
