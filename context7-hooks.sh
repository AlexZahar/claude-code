#!/bin/bash

# Context7 MCP documentation search hook
# This hook reminds Claude to use Context7 MCP for documentation searches

HOOK_TYPE="${HOOK_TYPE:-general}"
TOOL_INPUT="${TOOL_INPUT:-}"
TOOL_NAME="${TOOL_NAME:-}"

# Extract URL from tool input if available
URL=$(echo "$TOOL_INPUT" | jq -r '.url // .query // ""' 2>/dev/null || echo "")

# Check if this is a documentation search
is_documentation_search() {
    local search_term="$1"
    local doc_patterns=(
        "docs\."
        "documentation"
        "api reference"
        "api docs"
        "guide"
        "tutorial"
        "readme"
        "npm"
        "pypi"
        "github\.com.*docs"
        "readthedocs"
        "developer\."
        "developers\."
        "learn\."
        "\\.(md|mdx|rst)$"
    )
    
    for pattern in "${doc_patterns[@]}"; do
        if echo "$search_term" | grep -iE "$pattern" > /dev/null; then
            return 0
        fi
    done
    return 1
}

case "$HOOK_TYPE" in
  "pre-websearch"|"pre-webfetch")
    # Check if this looks like a documentation search
    if is_documentation_search "$URL"; then
        echo "📚 DOCUMENTATION SEARCH DETECTED!"
        echo ""
        echo "Consider using Context7 MCP for documentation:"
        echo "- mcp__context7-mcp__search_knowledge - Search indexed documentation"
        echo "- mcp__context7-mcp__add_knowledge - Index new documentation"
        echo "- mcp__context7-mcp__list_knowledge - View indexed docs"
        echo ""
        echo "Context7 provides:"
        echo "✓ Faster access to frequently used docs"
        echo "✓ Semantic search across documentation"
        echo "✓ Persistent knowledge base"
        echo "✓ No rate limits or network delays"
        echo ""
        echo "Example usage:"
        echo "mcp__context7-mcp__search_knowledge('LlamaIndex query engine configuration')"
        echo ""
        echo "Proceeding with WebSearch/WebFetch as requested..."
    else
        echo "🔍 Web search for: $URL"
        echo "Tip: For documentation, consider Context7 MCP for faster access!"
    fi
    ;;
    
  "documentation-reminder")
    echo "📚 REMINDER: Use Context7 MCP for documentation!"
    echo ""
    echo "Available Context7 tools:"
    echo "- mcp__context7-mcp__search_knowledge - Search indexed docs"
    echo "- mcp__context7-mcp__add_knowledge - Add new documentation"
    echo "- mcp__context7-mcp__list_knowledge - List all indexed docs"
    echo "- mcp__context7-mcp__get_knowledge - Get specific doc by ID"
    echo "- mcp__context7-mcp__update_knowledge - Update existing doc"
    echo "- mcp__context7-mcp__delete_knowledge - Remove outdated docs"
    echo ""
    echo "Benefits over WebSearch:"
    echo "- Instant access (no network delays)"
    echo "- Semantic search capabilities"
    echo "- Version-controlled documentation"
    echo "- No rate limits"
    ;;
    
  "index-documentation")
    echo "📖 How to index documentation with Context7:"
    echo ""
    echo "1. For web documentation:"
    echo "   - First fetch with WebFetch"
    echo "   - Then: mcp__context7-mcp__add_knowledge(title, content, metadata)"
    echo ""
    echo "2. For local documentation:"
    echo "   - Read with filesystem tools"
    echo "   - Then: mcp__context7-mcp__add_knowledge(title, content, metadata)"
    echo ""
    echo "3. Metadata suggestions:"
    echo "   - source: URL or file path"
    echo "   - version: Documentation version"
    echo "   - type: 'api', 'guide', 'tutorial', 'reference'"
    echo "   - technology: Framework/library name"
    echo "   - last_updated: Timestamp"
    ;;
esac

# Log Context7 usage suggestions
echo "[$(date)] Context7 hook triggered: $HOOK_TYPE for $URL" >> ~/.claude/context7-hooks.log