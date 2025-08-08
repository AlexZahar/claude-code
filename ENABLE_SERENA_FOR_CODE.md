# 🚀 Enable Serena MCP for Code Analysis in Claude Code

## Overview

Serena MCP provides powerful semantic code analysis tools that should ALWAYS be used instead of text-based search (Grep, Search) for code navigation and analysis. This guide ensures Serena is properly configured and used.

## Step 1: Add Serena to Claude Desktop Configuration

Add this to your `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
"serena": {
  "command": "/Users/USERNAME/Projects/mcp/serena/.venv/bin/serena-mcp-server",
  "args": [
    "--context", "desktop-app"
  ]
}
```

**Full example with other servers:**
```json
{
  "mcpServers": {
    "serena": {
      "command": "/Users/USERNAME/Projects/mcp/serena/.venv/bin/serena-mcp-server",
      "args": [
        "--context", "desktop-app"
      ]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/USERNAME/"]
    }
    // ... other servers
  }
}
```

## Step 2: Verify Serena Installation

1. **Check Serena is installed:**
   ```bash
   ls -la /Users/USERNAME/Projects/mcp/serena/.venv/bin/serena-mcp-server
   ```

2. **If not installed, set it up:**
   ```bash
   cd /Users/USERNAME/Projects/mcp/serena
   python -m venv .venv
   source .venv/bin/activate
   pip install -e .
   ```

## Step 3: Restart Claude Code

After updating the configuration:
1. Completely quit Claude Code (Cmd+Q)
2. Restart Claude Code
3. Serena tools should now be available

## Step 4: Verify Serena Tools Are Available

In a new Claude Code chat, ask:
"What MCP tools are available?"

You should see Serena tools like:
- `mcp__serena__find_symbol`
- `mcp__serena__search_for_pattern`
- `mcp__serena__get_symbols_overview`
- `mcp__serena__replace_symbol_body`
- etc.

## Step 5: Update CLAUDE.md Instructions

Add these instructions to `~/.claude/CLAUDE.md`:

```markdown
# 🔍 MANDATORY: Use Serena MCP for ALL Code Analysis

## NEVER use these tools for code search:
- ❌ Grep - DO NOT USE for code search
- ❌ Search - DO NOT USE for code search  
- ❌ Find - DO NOT USE for code search
- ❌ Read (for exploration) - DO NOT USE for finding code

## ALWAYS use Serena MCP tools instead:
- ✅ `mcp__serena__find_symbol` - Find classes, functions, methods by name
- ✅ `mcp__serena__search_for_pattern` - Search code with context
- ✅ `mcp__serena__get_symbols_overview` - Get file/directory structure
- ✅ `mcp__serena__find_referencing_symbols` - Find all usages
- ✅ `mcp__serena__replace_symbol_body` - Edit functions/classes

## Serena Usage Patterns:

### Finding Code:
```
# Instead of: Grep "class QueryEngine"
# Use: mcp__serena__find_symbol with name_path="QueryEngine"

# Instead of: Search for "execute_rag_query"  
# Use: mcp__serena__find_symbol with name_path="execute_rag_query"
```

### Understanding Structure:
```
# Instead of: LS + Read multiple files
# Use: mcp__serena__get_symbols_overview on directory
```

### Finding Usages:
```
# Instead of: Grep for all occurrences
# Use: mcp__serena__find_referencing_symbols
```

### Code Editing:
```
# Instead of: Edit tool with manual line finding
# Use: mcp__serena__replace_symbol_body for precise edits
```

## Workflow Rules:

1. **BEFORE any code task**: Activate the project with Serena
   ```
   mcp__serena__activate_project("/path/to/project")
   ```

2. **For code navigation**: ALWAYS use Serena symbol tools

3. **For understanding code**: Use get_symbols_overview first

4. **For editing**: Use symbol-based editing when possible

5. **Only use traditional tools when**:
   - Reading specific known file paths
   - Working with non-code files
   - File system operations
```

## Step 6: Create Serena-First Hooks

Create `/Users/USERNAME/.claude/serena-hooks.sh`:

```bash
#!/bin/bash

# Serena-first code analysis hook
# This hook reminds Claude to use Serena for code tasks

HOOK_TYPE="${HOOK_TYPE:-general}"

case "$HOOK_TYPE" in
  "code-search")
    echo "🔍 REMINDER: Use Serena MCP tools for code search!"
    echo "- mcp__serena__find_symbol for finding functions/classes"
    echo "- mcp__serena__search_for_pattern for code patterns"
    echo "- mcp__serena__get_symbols_overview for structure"
    ;;
  "pre-edit")
    echo "✏️ REMINDER: Consider using Serena for precise edits!"
    echo "- mcp__serena__replace_symbol_body for function/class edits"
    echo "- mcp__serena__find_symbol to locate the code first"
    ;;
  "project-start")
    echo "🚀 REMINDER: Activate project with Serena first!"
    echo "- mcp__serena__activate_project('/path/to/project')"
    echo "- mcp__serena__check_onboarding_performed"
    ;;
esac
```

Make it executable:
```bash
chmod +x ~/.claude/serena-hooks.sh
```

## Step 7: Update hooks.json

Add Serena reminders to `~/.claude/hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Grep|Search",
        "hooks": [
          {
            "type": "command",
            "command": "HOOK_TYPE=code-search /Users/USERNAME/.claude/serena-hooks.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "find.*function|find.*class|where.*defined|search.*code",
        "hooks": [
          {
            "type": "command",
            "command": "HOOK_TYPE=code-search /Users/USERNAME/.claude/serena-hooks.sh"
          }
        ]
      }
    ]
  }
}
```

## Step 8: Test Serena Integration

1. Start a new Claude Code session
2. Ask: "Find the execute_rag_query function"
3. Claude should use `mcp__serena__find_symbol` instead of Grep
4. Verify symbol-based navigation is working

## Troubleshooting

### If Serena tools don't appear:
1. Check Claude Desktop logs: `~/Library/Logs/Claude/mcp*.log`
2. Verify Serena server path exists
3. Test Serena manually:
   ```bash
   /Users/USERNAME/Projects/mcp/serena/.venv/bin/serena-mcp-server --help
   ```

### If Serena fails to activate projects:
1. Check project paths in `~/.serena/serena_config.yml`
2. Ensure language servers are installed for your languages
3. Check Serena logs in `~/.claude/serena-*.log`

## Benefits of Using Serena

1. **Precision**: Finds exact symbols, not text matches
2. **Context**: Understands code relationships
3. **Speed**: Indexed symbol lookup is faster
4. **Accuracy**: Avoids false positives from text search
5. **Refactoring**: Safe symbol-based code changes

## Summary

With Serena properly configured:
- Claude will use semantic code analysis instead of text search
- Code navigation will be more accurate
- Edits will be more precise
- Large codebases will be navigable efficiently

Remember: **ALWAYS use Serena MCP for code, NEVER use text-based search!**