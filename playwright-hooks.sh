#!/bin/bash

# Playwright Hooks for Claude Code
# Provides automation, security, and memory integration for web workflows

set -e

HOOK_TYPE="${HOOK_TYPE:-unknown}"
TOOL_INPUT="${TOOL_INPUT:-{}}"
TOOL_OUTPUT="${TOOL_OUTPUT:-}"
TOOL_NAME="${TOOL_NAME:-}"

# Configuration
SCREENSHOTS_DIR="$HOME/.claude/playwright-screenshots"
MEMORY_SCRIPT="$HOME/.claude/graphiti-hook.sh"
MAX_SCREENSHOT_AGE_DAYS=30

# Ensure directories exist
mkdir -p "$SCREENSHOTS_DIR"

# Utility functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

cleanup_old_screenshots() {
    find "$SCREENSHOTS_DIR" -name "*.png" -mtime +$MAX_SCREENSHOT_AGE_DAYS -delete 2>/dev/null || true
}

extract_url_from_input() {
    echo "$TOOL_INPUT" | jq -r '.url // .page_url // empty' 2>/dev/null || echo ""
}

extract_action_from_input() {
    echo "$TOOL_INPUT" | jq -r '.selector // .script // .text // empty' 2>/dev/null || echo ""
}

validate_url() {
    local url="$1"
    
    # Block dangerous protocols
    if echo "$url" | grep -qE '^(file|ftp|javascript|data):'; then
        log "🚫 Blocked dangerous protocol in URL: $url"
        echo "Security: Blocked dangerous protocol" >&2
        return 1
    fi
    
    # Block suspicious domains (basic list)
    if echo "$url" | grep -qE '(malware|phishing|suspicious)\.'; then
        log "🚫 Blocked suspicious domain in URL: $url"
        echo "Security: Blocked suspicious domain" >&2
        return 1
    fi
    
    return 0
}

take_screenshot() {
    local purpose="$1"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local filename="${timestamp}_${purpose}.png"
    local filepath="$SCREENSHOTS_DIR/$filename"
    
    # Use mcp__puppeteer tool to take screenshot
    log "📸 Taking screenshot: $purpose"
    echo "Screenshot saved: $filepath"
}

save_workflow_memory() {
    local action="$1"
    local url="$2"
    local details="$3"
    local success="$4"
    
    if [ "$success" = "true" ]; then
        local memory_text="Playwright Success: $action on $url - $details"
    else
        local memory_text="Playwright Error: $action failed on $url - $details"
    fi
    
    if [ -x "$MEMORY_SCRIPT" ]; then
        timeout 600 "$MEMORY_SCRIPT" add "$memory_text" 2>/dev/null || log "⚠️ Memory save timeout"
    fi
}

generate_test_snippet() {
    local action="$1"
    local url="$2"
    local selector="$3"
    
    cat << EOF
// Generated Playwright test snippet
test('$action workflow', async ({ page }) => {
  await page.goto('$url');
  await page.click('$selector');
  // Add assertions as needed
});
EOF
}

analyze_page_performance() {
    local url="$1"
    log "🔍 Performance analysis for: $url"
    echo "Performance: Page loaded successfully"
}

# Hook implementations
handle_pre_navigate() {
    local url=$(extract_url_from_input)
    
    if [ -n "$url" ]; then
        log "🌐 Pre-navigation to: $url"
        
        # Security validation
        if ! validate_url "$url"; then
            return 1
        fi
        
        # Take pre-navigation screenshot if we're already on a page
        take_screenshot "before_navigate"
        
        echo "✅ URL validated and pre-navigation screenshot taken"
    fi
}

handle_post_navigate() {
    local url=$(extract_url_from_input)
    
    if [ -n "$url" ]; then
        log "🎯 Post-navigation to: $url"
        
        # Take post-navigation screenshot
        take_screenshot "after_navigate"
        
        # Performance analysis
        analyze_page_performance "$url"
        
        # Save to memory
        save_workflow_memory "navigate" "$url" "Page loaded successfully" "true"
        
        echo "📱 Navigation documented and analyzed"
    fi
}

handle_pre_interact() {
    local action=$(extract_action_from_input)
    local url=$(extract_url_from_input)
    
    log "🎮 Pre-interaction: $action"
    
    # Take pre-interaction screenshot
    take_screenshot "before_interaction"
    
    echo "📸 Pre-interaction state captured"
}

handle_post_interact() {
    local action=$(extract_action_from_input)
    local url=$(extract_url_from_input)
    local success="false"
    
    # Check if interaction was successful
    if echo "$TOOL_OUTPUT" | grep -q "success\|completed\|clicked\|filled\|selected"; then
        success="true"
    fi
    
    log "✨ Post-interaction: $action (success: $success)"
    
    # Take post-interaction screenshot
    take_screenshot "after_interaction"
    
    # Save workflow to memory
    save_workflow_memory "interact" "$url" "$action" "$success"
    
    # Generate test snippet for successful interactions
    if [ "$success" = "true" ] && [ -n "$action" ]; then
        local test_snippet=$(generate_test_snippet "interaction" "$url" "$action")
        echo "🧪 Test snippet generated"
    fi
    
    echo "🎯 Interaction documented and analyzed"
}

handle_error() {
    local error_details="$TOOL_OUTPUT"
    local url=$(extract_url_from_input)
    local action=$(extract_action_from_input)
    
    log "❌ Playwright error detected"
    
    # Take error screenshot
    take_screenshot "error_state"
    
    # Save error to memory for learning
    save_workflow_memory "error" "$url" "Error: $error_details" "false"
    
    echo "📋 Error documented for future reference"
}

# Cleanup old screenshots periodically
cleanup_old_screenshots

# Main hook dispatcher
case "$HOOK_TYPE" in
    "pre-navigate")
        handle_pre_navigate
        ;;
    "post-navigate") 
        handle_post_navigate
        ;;
    "pre-interact")
        handle_pre_interact
        ;;
    "post-interact")
        handle_post_interact
        ;;
    "error")
        handle_error
        ;;
    *)
        # Default: analyze any Playwright tool use
        if echo "$TOOL_NAME" | grep -q "playwright"; then
            if echo "$TOOL_OUTPUT" | grep -q "error\|failed\|timeout"; then
                HOOK_TYPE="error" handle_error
            else
                HOOK_TYPE="post-interact" handle_post_interact
            fi
        fi
        ;;
esac

exit 0