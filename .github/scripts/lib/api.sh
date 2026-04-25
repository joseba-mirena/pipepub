#!/bin/bash
# .github/scripts/lib/api.sh - Generic API functions

# Guard against sourcing without logging
if ! declare -F log_error >/dev/null 2>&1; then
    echo "ERROR: logging.sh must be sourced before api.sh" >&2
    return 1 2>/dev/null || exit 1
fi

# Generic API caller with retry
call_api_with_retry() {
    local url="$1"
    local token="$2"
    local payload="$3"
    local method="${4:-POST}"
    local content_type="${5:-application/json}"
    local auth_type="${6:-Bearer}"
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_debug "DRY RUN: $method $url"
        return 0
    fi
    
    # Validate URL
    if ! validate_url "$url"; then
        return 1
    fi
    
    for i in $(seq 1 $API_RETRY_COUNT); do
        log_debug "API call $i/$API_RETRY_COUNT: $method $url"
        
        local curl_args=(
            "-s" "-S"
            "-w" "\n%{http_code}"
            "-X" "$method"
            "--connect-timeout" "${API_CONNECT_TIMEOUT:-10}"
            "--max-time" "${API_TIMEOUT:-30}"
        )
        
        # Add authorization header
        case "$auth_type" in
            "Bearer")   curl_args+=("-H" "Authorization: Bearer $token") ;;
            "api-key")  curl_args+=("-H" "api-key: $token") ;;
            "token")    curl_args+=("-H" "Authorization: Token $token") ;;
            "none")     ;;
            *)          curl_args+=("-H" "Authorization: Bearer $token") ;;
        esac
        
        curl_args+=("-H" "Content-Type: $content_type")
        curl_args+=("-H" "User-Agent: PipePub/1.0")
        
        if [[ "$method" != "GET" ]] && [[ -n "$payload" ]]; then
            curl_args+=("-d" "$payload")
        fi
        
        curl_args+=("$url")
        
        # Use temp files for output
        local stdout_file=$(mktemp)
        local stderr_file=$(mktemp)
        
        # Execute curl
        curl "${curl_args[@]}" > "$stdout_file" 2> "$stderr_file"
        local curl_exit=$?
        
        # Log stderr if any
        if [[ -s "$stderr_file" ]]; then
            local error_msg=$(cat "$stderr_file")
            log_debug "Curl stderr: $error_msg"
        fi
        
        # Read response
        local response=$(cat "$stdout_file")
        local http_code=$(echo "$response" | tail -n1)
        local body=$(echo "$response" | sed '$d')
        
        # Cleanup
        rm -f "$stdout_file" "$stderr_file"
        
        # Check curl exit code
        if [[ $curl_exit -ne 0 ]]; then
            log_warning "Curl exited with code $curl_exit"
            if [[ $i -lt $API_RETRY_COUNT ]]; then
                sleep $API_RETRY_DELAY
                continue
            fi
            return 1
        fi
        
        log_debug "HTTP $http_code"
        
        # Success on 2xx
        if [[ "$http_code" -ge 200 ]] && [[ "$http_code" -lt 300 ]]; then
            echo "$body"
            return 0
        fi
        
        # Handle specific error codes
        case "$http_code" in
            400) log_error "Bad Request (400) - Check payload"; return 1 ;;
            401) log_error "Authentication failed (401) - Check token"; return 1 ;;
            403) log_error "Forbidden (403) - Insufficient permissions"; return 1 ;;
            404) log_error "Not Found (404) - Check endpoint URL"; return 1 ;;
            409) log_error "Conflict (409) - Resource may already exist"; return 1 ;;
            429) 
                log_warning "Rate limited (429), waiting 60 seconds"
                sleep 60
                ;;
            500|502|503|504)
                log_warning "Server error ($http_code), retrying"
                if [[ $i -lt $API_RETRY_COUNT ]]; then
                    sleep $((API_RETRY_DELAY * i))
                fi
                ;;
            *)
                log_error "HTTP $http_code - Unexpected error"
                if [[ $i -lt $API_RETRY_COUNT ]]; then
                    sleep $API_RETRY_DELAY
                fi
                ;;
        esac
    done
    
    log_error "Failed after $API_RETRY_COUNT attempts"
    return 1
}

# GET request helper
api_get() {
    local url="$1"
    local token="$2"
    local auth_type="${3:-Bearer}"
    
    call_api_with_retry "$url" "$token" "" "GET" "application/json" "$auth_type"
}

# POST request helper
api_post() {
    local url="$1"
    local token="$2"
    local payload="$3"
    local auth_type="${4:-Bearer}"
    
    call_api_with_retry "$url" "$token" "$payload" "POST" "application/json" "$auth_type"
}

# PUT request helper
api_put() {
    local url="$1"
    local token="$2"
    local payload="$3"
    local auth_type="${4:-Bearer}"
    
    call_api_with_retry "$url" "$token" "$payload" "PUT" "application/json" "$auth_type"
}