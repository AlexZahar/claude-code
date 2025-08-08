#!/bin/bash

# Documentation Search Hook for Claude Code
# Redirects documentation queries to context7 MCP instead of web search

set -e

HOOK_TYPE="${HOOK_TYPE:-unknown}"
TOOL_INPUT="${TOOL_INPUT:-{}}"
TOOL_OUTPUT="${TOOL_OUTPUT:-}"
TOOL_NAME="${TOOL_NAME:-}"
USER_MESSAGE="${USER_MESSAGE:-}"

# Configuration
MEMORY_SCRIPT="$HOME/.claude/graphiti-hook.sh"
LOG_FILE="$HOME/.claude/documentation-hook.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE" >&2
}

# Documentation detection patterns
is_documentation_query() {
    local query="$1"
    
    # Convert to lowercase for matching
    query_lower=$(echo "$query" | tr '[:upper:]' '[:lower:]')
    
    # Documentation keywords
    if echo "$query_lower" | grep -qE '\b(docs?|documentation|api|reference|guide|tutorial|how to|manual|readme|examples?|usage)\b'; then
        return 0
    fi
    
    # Framework/library documentation patterns
    if echo "$query_lower" | grep -qE '\b(react|vue|angular|nextjs|nuxt|svelte|express|fastapi|django|flask|laravel|rails|spring)\s+(docs?|documentation|api|guide)\b'; then
        return 0
    fi
    
    # Technology + "how to" patterns
    if echo "$query_lower" | grep -qE '\b(javascript|typescript|python|java|go|rust|php|ruby|node)\s+(how to|guide|tutorial)\b'; then
        return 0
    fi
    
    # Specific documentation sites
    if echo "$query_lower" | grep -qE '\b(mdn|developer\.mozilla|stackoverflow|github\.com.*readme)\b'; then
        return 0
    fi
    
    return 1
}

extract_search_query() {
    local input="$1"
    
    # Try to extract from various tool inputs
    local query=""
    
    # WebSearch tool
    query=$(echo "$input" | jq -r '.query // empty' 2>/dev/null || echo "")
    if [ -n "$query" ]; then
        echo "$query"
        return
    fi
    
    # WebFetch tool
    query=$(echo "$input" | jq -r '.url // empty' 2>/dev/null || echo "")
    if [ -n "$query" ]; then
        echo "$query"
        return
    fi
    
    # Brave search
    query=$(echo "$input" | jq -r '.query // empty' 2>/dev/null || echo "")
    if [ -n "$query" ]; then
        echo "$query"
        return
    fi
    
    echo ""
}

suggest_context7_usage() {
    local query="$1"
    local tool_name="$2"
    
    log "🚫 Blocked $tool_name for documentation query: $query"
    
    cat << EOF

🔍 DOCUMENTATION SEARCH DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Query: "$query"
Tool Attempted: $tool_name

💡 RECOMMENDATION: Use context7 MCP instead for better documentation results!

🎯 SUGGESTED CONTEXT7 COMMANDS:
   
   Search docs:     mcp__context7-mcp__search_knowledge("$query")
   Add new docs:    mcp__context7-mcp__add_knowledge(title, content, metadata)
   List all docs:   mcp__context7-mcp__list_knowledge()
   Get specific:    mcp__context7-mcp__get_knowledge(id)

🔧 CONTEXT7 ADVANTAGES:
   ✅ Curated, high-quality documentation
   ✅ Structured content (vs. random web results) 
   ✅ Always up-to-date official sources
   ✅ Better context understanding
   ✅ No rate limiting or web scraping issues

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Use context7 for documentation, web search for general queries!

EOF
    
    # Save to memory for learning
    if [ -x "$MEMORY_SCRIPT" ]; then
        timeout 600 "$MEMORY_SCRIPT" add "Documentation Search: Redirected '$query' from $tool_name to context7 for better results" 2>/dev/null || true
    fi
}

generate_context7_suggestion() {
    local query="$1"
    
    # Extract main technology/framework from query
    local tech=""
    query_lower=$(echo "$query" | tr '[:upper:]' '[:lower:]')
    
    # Common technologies
    if echo "$query_lower" | grep -q "react"; then tech="React"; fi
    if echo "$query_lower" | grep -q "vue"; then tech="Vue.js"; fi
    if echo "$query_lower" | grep -q "angular"; then tech="Angular"; fi
    if echo "$query_lower" | grep -q "nextjs\|next.js"; then tech="Next.js"; fi
    if echo "$query_lower" | grep -q "svelte"; then tech="Svelte"; fi
    if echo "$query_lower" | grep -q "express"; then tech="Express.js"; fi
    if echo "$query_lower" | grep -q "django"; then tech="Django"; fi
    if echo "$query_lower" | grep -q "flask"; then tech="Flask"; fi
    if echo "$query_lower" | grep -q "fastapi"; then tech="FastAPI"; fi
    if echo "$query_lower" | grep -q "laravel"; then tech="Laravel"; fi
    if echo "$query_lower" | grep -q "rails"; then tech="Ruby on Rails"; fi
    if echo "$query_lower" | grep -q "spring"; then tech="Spring"; fi
    if echo "$query_lower" | grep -q "typescript"; then tech="TypeScript"; fi
    if echo "$query_lower" | grep -q "javascript"; then tech="JavaScript"; fi
    if echo "$query_lower" | grep -q "python"; then tech="Python"; fi
    if echo "$query_lower" | grep -q "node"; then tech="Node.js"; fi
    
    cat << EOF

💡 TRY THESE CONTEXT7 COMMANDS:

1. Search existing documentation:
   mcp__context7-mcp__search_knowledge("$query")

2. List all indexed documentation:
   mcp__context7-mcp__list_knowledge()

3. Add documentation after fetching:
   # First: WebFetch the documentation
   # Then: mcp__context7-mcp__add_knowledge("$tech Documentation", content, {
     "source": "url",
     "technology": "$tech",
     "type": "official_docs"
   })

EOF
}

# Main hook logic
case "$HOOK_TYPE" in
    "pre-websearch"|"pre-webfetch"|"pre-search")
        query=$(extract_search_query "$TOOL_INPUT")
        
        if [ -n "$query" ] && is_documentation_query "$query"; then
            suggest_context7_usage "$query" "$TOOL_NAME"
            generate_context7_suggestion "$query"
            
            # Return error to block the web search
            echo "❌ Use context7 MCP for documentation instead of web search"
            exit 1
        fi
        ;;
    *)
        # Default: analyze any tool use for documentation patterns
        query=$(extract_search_query "$TOOL_INPUT")
        
        if [ -n "$query" ] && is_documentation_query "$query"; then
            case "$TOOL_NAME" in
                "WebSearch"|"WebFetch"|"mcp__brave-search__"*)
                    log "📚 Documentation query detected in $TOOL_NAME: $query"
                    suggest_context7_usage "$query" "$TOOL_NAME"
                    generate_context7_suggestion "$query"
                    exit 1
                    ;;
            esac
        fi
        ;;
esac

exit 0