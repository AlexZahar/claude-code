#!/bin/bash

# Serena-first code analysis hook
# This hook reminds Claude to use Serena MCP for code tasks

HOOK_TYPE="${HOOK_TYPE:-general}"

# Check if Serena is available
SERENA_AVAILABLE=$(claude mcp list 2>/dev/null | grep "serena.*✓" | wc -l)

# If Serena is not available, allow fallback tools
if [ "$SERENA_AVAILABLE" -eq 0 ]; then
    echo "ℹ️  Serena MCP not connected - allowing fallback tools"
    echo "   To connect Serena: Check MCP configuration in Claude Code settings"
    echo "   Or restart Claude Code if Serena should be available"
    exit 0  # Allow the tool to proceed
fi

# Note: We assume if Serena is connected, Claude should activate it
echo "🔍 Serena MCP is connected - enforcing semantic code analysis"

# For Read tool, check if it's being used for code files
if [ "$HOOK_TYPE" = "wrong-tool" ] && echo "$TOOL_INPUT" | grep -q '"file_path"'; then
    FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path' 2>/dev/null)
    # Allow config files and documentation
    if echo "$FILE_PATH" | grep -qE '\.(json|md|txt|yml|yaml|env|lock|log|toml|ini|conf)$'; then
        echo "ℹ️  Allowing Read for config/doc file: $(basename "$FILE_PATH")"
        exit 0  # Allow the tool to proceed
    fi
    # Allow node_modules and .git directories
    if echo "$FILE_PATH" | grep -qE '(node_modules|\.git|\.next|dist|build)'; then
        exit 0  # Allow the tool to proceed
    fi
    echo "🔍 Detected Read tool for code file: $(basename "$FILE_PATH")"
fi

case "$HOOK_TYPE" in
  "code-search")
    echo "🔍 REMINDER: Use Serena MCP tools for code search!"
    echo "- mcp__serena__find_symbol for finding functions/classes"
    echo "- mcp__serena__search_for_pattern for code patterns"
    echo "- mcp__serena__get_symbols_overview for structure"
    echo "- mcp__serena__find_referencing_symbols for usages"
    echo ""
    echo "DO NOT use Grep, Search, Read, or Agent tools for code!"
    ;;
  "pre-edit")
    echo "✏️ REMINDER: Consider using Serena for precise edits!"
    echo "- mcp__serena__replace_symbol_body for function/class edits"
    echo "- mcp__serena__find_symbol to locate the code first"
    echo "- More accurate than line-based editing"
    ;;
  "project-start")
    echo "🚀 REMINDER: Activate project with Serena first!"
    echo "- mcp__serena__activate_project('/path/to/project')"
    echo "- mcp__serena__check_onboarding_performed()"
    echo "- mcp__serena__get_symbols_overview() for structure"
    ;;
  "wrong-tool")
    echo "⛔ STOP! You're using the wrong tool for code exploration!"
    echo ""
    echo "CRITICAL: Serena is connected but you must activate it for this project:"
    echo ""
    echo "🔧 STEP 1: Load Serena instructions (once per session)"
    echo "   /mcp__serena__initial_instructions"
    echo ""
    echo "🎯 STEP 2: Activate your current project"
    echo "   mcp__serena__activate_project('/path/to/your/project')"
    echo ""
    echo "💡 TIP: Serena needs project activation for semantic understanding!"
    echo ""
    echo "Then use Serena tools instead:"
    echo "- mcp__serena__find_symbol('symbol_name')"
    echo "- mcp__serena__search_for_pattern('pattern')"
    echo "- mcp__serena__get_symbols_overview('/path') for exploring code structure"
    echo ""
    echo "❌ AVOID: Read tool for code exploration (misses context)"
    echo "❌ AVOID: Search/Grep tools (text matching only)"
    echo ""
    echo "✅ USE: Serena provides semantic code understanding!"
    echo ""
    echo "Only use Search/Grep/Read if Serena is genuinely unavailable."
    exit 1  # Block the wrong tool
    ;;
esac

# Log Serena usage reminders
echo "[$(date)] Serena hook triggered: $HOOK_TYPE" >> ~/.claude/serena-hooks.log