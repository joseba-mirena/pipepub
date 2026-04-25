#!/bin/bash
#===============================================================================
# Library: md_to_html.sh
# Description: Pure bash Markdown to HTML converter
#===============================================================================

MD_DEBUG="${MD_DEBUG:-0}"
_debug() { [ "$MD_DEBUG" -eq 1 ] && echo "[DEBUG] $*" >&2; }

_html_escape() {
    local str="$1"
    str="${str//&/&amp;}"
    str="${str//</&lt;}"
    str="${str//>/&gt;}"
    str="${str//\"/&quot;}"
    str="${str//\'/&#39;}"
    echo "$str"
}

_parse_inline() {
    local text="$1"
    local autolink="${2:-0}"
    local mailto="${3:-0}"
    local result=""
    
    while [ -n "$text" ]; do
        case "$text" in
            \\*) result+="${text:1:1}"; text="${text:2}" ;;
            \*\**|__*)
                local delim="${text:0:2}"; local content="${text:2}"
                if [[ "$content" == *"$delim"* ]]; then
                    result+="<strong>$(_parse_inline "${content%%$delim*}" "$autolink" "$mailto")</strong>"
                    text="${content#*$delim}"
                else result+="$delim"; text="$content"; fi ;;
            \**|_*)
                local delim="${text:0:1}"; local content="${text:1}"
                if [[ "$content" == *"$delim"* ]]; then
                    result+="<em>$(_parse_inline "${content%%$delim*}" "$autolink" "$mailto")</em>"
                    text="${content#*$delim}"
                else result+="$delim"; text="$content"; fi ;;
            \`*)
                local content="${text:1}"
                if [[ "$content" == *"\`"* ]]; then
                    result+="<code>$(_html_escape "${content%%\`*}")</code>"
                    text="${content#*\`}"
                else result+="\`"; text="$content"; fi ;;
            \!\[*)
                local content="${text:2}"
                if [[ "$content" == *"]("*")"* ]]; then
                    local alt="${content%%](*}"; local rest="${content#*](}"
                    result+="<img src=\"$(_html_escape "${rest%%)*}")\" alt=\"$(_html_escape "$alt")\" />"
                    text="${rest#*)}"
                else result+="!["; text="$content"; fi ;;
            \[*)
                local content="${text:1}"
                if [[ "$content" == *"]("*")"* ]]; then
                    local link_text="${content%%](*}"; local rest="${content#*](}"
                    result+="<a href=\"$(_html_escape "${rest%%)*}")\">$(_parse_inline "$link_text" "$autolink" "$mailto")</a>"
                    text="${rest#*)}"
                else result+="["; text="$content"; fi ;;
            *) result+="${text:0:1}"; text="${text:1}" ;;
        esac
    done

    if [ "$autolink" -eq 1 ]; then
        result=$(echo "$result" | sed -E 's|(https?://[a-zA-Z0-9./?=:_#-]+)|<a href="\1">\1</a>|g')
        [ "$mailto" -eq 1 ] && result=$(echo "$result" | sed -E 's|([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})|<a href="mailto:\1">\1</a>|g')
    fi
    echo "$result"
}

_build_toc() {
    local headings="$1"
    local output="<nav class=\"toc\"><h2>Table of Contents</h2><ul>"
    local prev_level=0
    
    while IFS='|' read -r level text id; do
        [ -z "$level" ] && continue
        if [ "$level" -gt "$prev_level" ]; then
            for ((i=prev_level; i<level; i++)); do [ $i -gt 0 ] && output+="<ul>"; done
        elif [ "$level" -lt "$prev_level" ]; then
            for ((i=level; i<prev_level; i++)); do output+="</ul>"; done
        fi
        output+="<li><a href=\"#$id\">$(_html_escape "$text")</a></li>"
        prev_level=$level
    done <<< "$headings"
    
    for ((i=1; i<=prev_level; i++)); do output+="</ul>"; done
    echo -e "$output</nav>\n"
}

_process_table_row() {
    local row="$1" align_row="$2" tag="${3:-td}" add_classes="$4"
    local result="<tr>"; local IFS='|'; local cell_num=0
    row="${row#|}"; row="${row%|}"

    for cell in $row; do
        cell_num=$((cell_num + 1))
        # Trim whitespace safely
        cell=$(echo "$cell" | xargs) 2>/dev/null || cell="${cell#"${cell%%[![:space:]]*}"}"
        
        local style=""
        if [ -n "$align_row" ]; then
            local align_part=$(echo "$align_row" | cut -d'|' -f$((cell_num+1)) | xargs) 2>/dev/null
            if [[ "$align_part" =~ ^:.*:$ ]]; then style="text-center"
            elif [[ "$align_part" =~ ^: ]]; then style="text-left"
            elif [[ "$align_part" =~ :$ ]]; then style="text-right"
            fi
        fi
        local class_attr=""
        [ "$add_classes" -eq 1 ] && [ -n "$style" ] && class_attr=" class=\"$style\""
        result+="<$tag$class_attr>$(_parse_inline "$cell")</$tag>"
    done
    echo "$result</tr>"
}

_convert_markdown_to_html() {
    local input="${1:-}" enable_tables="${2:-1}" add_bootstrap="${3:-0}" 
    local enable_toc="${4:-0}" autolink="${5:-0}" mailto="${6:-0}"
    local line in_code_block=0 in_list=0 list_type="" in_blockquote=0 in_table=0
    local output="" prev_line="" headings="" table_align_row=""

    # Debug output of flags
    _debug "Flags: tables=$enable_tables, bootstrap=$add_bootstrap, toc=$enable_toc, autolink=$autolink, mailto=$mailto"

    # Input handling
    if [ -n "$input" ] && [ -f "$input" ]; then
        exec 3< "$input"
        _debug "Reading from file: $input"
    else
        exec 3<&0
        _debug "Reading from stdin"
    fi

    while IFS= read -r line <&3 || [ -n "$line" ]; do
        _debug "Processing line: $line"
        
        # Code blocks
        if [[ "$line" =~ ^\`\`\`([a-z]*)$ ]]; then
            if [ $in_code_block -eq 0 ]; then
                local pre_class=""
                [ $add_bootstrap -eq 1 ] && pre_class=" class=\"bg-light p-3 rounded\""
                output+="<pre$pre_class><code class=\"language-${BASH_REMATCH[1]}\">"
                in_code_block=1
                _debug "Opening code block, language: ${BASH_REMATCH[1]}"
            else
                output+="</code></pre>"$'\n'
                in_code_block=0
                _debug "Closing code block"
            fi
            continue
        fi
        
        if [ $in_code_block -eq 1 ]; then
            output+="$(_html_escape "$line")"$'\n'
            continue
        fi

        # Tables
        if [[ "$line" =~ ^\|.*\|$ ]] && [ "$enable_tables" -eq 1 ]; then
            if [ $in_table -eq 0 ]; then
                output+="<table$([ "$add_bootstrap" -eq 1 ] && echo " class=\"table\"")>"$'\n'
                in_table=1
                table_align_row=""
                _debug "Opening table"
            fi
            if [[ "$line" =~ ^\|[\ \:]*-+ ]]; then
                table_align_row="$line"
                _debug "Table alignment row: $line"
                continue
            fi
            output+="$(_process_table_row "$line" "$table_align_row" "$([ -z "$table_align_row" ] && echo "th" || echo "td")" "$add_bootstrap")"$'\n'
            continue
        elif [ $in_table -eq 1 ]; then
            output+="</table>"$'\n'
            in_table=0
            _debug "Closing table"
        fi

        # Headings (ATX)
        if [[ "$line" =~ ^(#{1,6})\ (.*)$ ]]; then
            local level=${#BASH_REMATCH[1]}
            local content="${BASH_REMATCH[2]}"
            local id=$(echo "$content" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\+/-/g' | sed 's/^-//;s/-$//')
            [ "$enable_toc" -eq 1 ] && headings+="$level|$content|$id"$'\n'
            output+="<h$level id=\"$id\">$(_parse_inline "$content" "$autolink" "$mailto")</h$level>"$'\n'
            _debug "ATX heading: level=$level, id=$id"
            prev_line=""
            continue
        fi

        # Setext Headings
        if [[ "$line" =~ ^(=+|-+)$ ]] && [ -n "$prev_line" ] && [ ${#line} -gt 2 ]; then
            local level=1
            [[ "$line" =~ ^-+ ]] && level=2
            local id=$(echo "$prev_line" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\+/-/g' | sed 's/^-//;s/-$//')
            # Remove the last paragraph added in the previous iteration
            output="${output%<p>$(_parse_inline "$prev_line" "$autolink" "$mailto")</p>$'\n'}"
            [ "$enable_toc" -eq 1 ] && headings+="$level|$prev_line|$id"$'\n'
            output+="<h$level id=\"$id\">$(_parse_inline "$prev_line" "$autolink" "$mailto")</h$level>"$'\n'
            _debug "Setext heading: level=$level, id=$id"
            prev_line=""
            continue
        fi

        # Blank lines
        if [ -z "$line" ]; then
            [ $in_list -eq 1 ] && { output+="</$list_type>"$'\n'; in_list=0; _debug "Closing list"; }
            [ $in_blockquote -eq 1 ] && { output+="</blockquote>"$'\n'; in_blockquote=0; _debug "Closing blockquote"; }
            prev_line=""
            continue
        fi

        # Lists & Blockquotes
        if [[ "$line" =~ ^([\*\-]|[0-9]+\.)\ (.*)$ ]]; then
            local type="ul"
            [[ "$line" =~ ^[0-9] ]] && type="ol"
            if [ $in_list -eq 0 ] || [ "$list_type" != "$type" ]; then
                [ $in_list -eq 1 ] && output+="</$list_type>"$'\n'
                output+="<$type>"$'\n'
                in_list=1
                list_type="$type"
                _debug "Opening $type list"
            fi
            output+="<li>$(_parse_inline "${BASH_REMATCH[2]}" "$autolink" "$mailto")</li>"$'\n'
            continue
        fi

        # Blockquotes (if not a list)
        if [[ "$line" =~ ^\>\ (.*)$ ]]; then
            if [ $in_blockquote -eq 0 ]; then
                output+="<blockquote>"$'\n'
                in_blockquote=1
                _debug "Opening blockquote"
            fi
            local content="${BASH_REMATCH[1]}"
            output+="<p>$(_parse_inline "$content" "$autolink" "$mailto")</p>"$'\n'
            continue
        fi

        # Close lists before paragraphs
        if [ $in_list -eq 1 ]; then
            output+="</$list_type>"$'\n'
            in_list=0
            _debug "Closing list before paragraph"
        fi

        # Regular paragraph
        output+="<p>$(_parse_inline "$line" "$autolink" "$mailto")</p>"$'\n'
        prev_line="$line"
        _debug "Paragraph added"
    done

    # Proper file descriptor cleanup
    exec 3<&-

    # Insert TOC if enabled
    if [ $enable_toc -eq 1 ] && [ -n "$headings" ]; then
        output="$(_build_toc "$headings")$output"
        _debug "Table of Contents added with $(echo -e "$headings" | grep -c '|') entries"
    fi

    echo -e "$output"
}

#===============================================================================
# Public API
#===============================================================================

# Main conversion function
# Usage: md_to_html [file] [enable_tables] [add_bootstrap] [enable_toc] [autolink] [mailto]
md_to_html() {
    _convert_markdown_to_html "$@"
}

# Convert markdown string to HTML
# Usage: md_to_html_string "markdown text" [enable_tables] [add_bootstrap] [enable_toc] [autolink] [mailto]
md_to_html_string() {
    local markdown="$1"
    shift
    echo "$markdown" | md_to_html "" "$@"
}

# Enable debug mode
# Usage: md_to_html_debug [same flags as md_to_html]
md_to_html_debug() {
    MD_DEBUG=1 md_to_html "$@"
}

# Quick presets
md_to_html_default() {
    md_to_html "$1" 1 0 0 0 0
}

md_to_html_bootstrap() {
    md_to_html "$1" 1 1 0 0 0
}

md_to_html_full() {
    md_to_html "$1" 1 1 1 1 1
}

md_to_html_minimal() {
    md_to_html "$1" 0 0 0 0 0
}

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f md_to_html
    export -f md_to_html_string
    export -f md_to_html_debug
    export -f md_to_html_default
    export -f md_to_html_bootstrap
    export -f md_to_html_full
    export -f md_to_html_minimal
fi