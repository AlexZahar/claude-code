# 📚 Documentation Search Hook

## Problem Solved
Claude Code was using web search tools (WebSearch, WebFetch, Brave Search) for documentation queries instead of the superior context7 MCP, even when explicitly told to use context7.

## Solution: Smart Documentation Hook
Automatically detects documentation queries and blocks web search tools, redirecting to context7 MCP instead.

## How It Works

### Detection Patterns
The hook detects documentation queries by looking for these keywords:
- **Direct**: `docs`, `documentation`, `api`, `reference`, `guide`, `tutorial`, `manual`, `readme`, `examples`, `usage`
- **Framework patterns**: `react docs`, `vue api`, `nextjs guide`, etc.
- **Technology patterns**: `javascript how to`, `python tutorial`, etc.
- **Documentation sites**: `mdn`, `developer.mozilla`, `stackoverflow`, etc.

### Hook Actions
1. **Pre-Tool Execution**: Analyzes the query before web search tools run
2. **Smart Blocking**: Stops web search for documentation queries
3. **Helpful Guidance**: Shows exactly how to use context7 instead
4. **Memory Integration**: Logs redirected queries for learning

## Active Hook Matchers

### PreToolUse Hooks
- **WebSearch|WebFetch**: Catches direct web search attempts
- **mcp__brave-search__***: Catches Brave search attempts

### Detection Examples

✅ **WILL BE REDIRECTED TO CONTEXT7:**
- "React documentation"
- "Express.js API reference" 
- "How to use TypeScript"
- "Next.js tutorial"
- "Python guide"
- "MDN JavaScript docs"

❌ **WILL STILL USE WEB SEARCH:**
- "Latest tech news"
- "Company information"
- "Current events"
- "General questions"

## Hook Output

When a documentation query is detected, you'll see:

```
🔍 DOCUMENTATION SEARCH DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Query: "React documentation"
Tool Attempted: WebSearch

💡 RECOMMENDATION: Use context7 MCP instead for better documentation results!

🎯 SUGGESTED CONTEXT7 COMMANDS:
   
   For framework docs:    Use ReadMcpResourceTool with context7 server
   For API references:    Use ListMcpResourcesTool to find available docs
   For specific guides:   Use context7's curated documentation database

🔧 CONTEXT7 ADVANTAGES:
   ✅ Curated, high-quality documentation
   ✅ Structured content (vs. random web results) 
   ✅ Always up-to-date official sources
   ✅ Better context understanding
   ✅ No rate limiting or web scraping issues

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 TRY THESE CONTEXT7 COMMANDS:

1. List available documentation:
   ListMcpResourcesTool → server: "context7-mcp"

2. Search for React documentation:
   ReadMcpResourceTool → server: "context7-mcp", uri: "docs://React"

3. Find specific topics:
   ReadMcpResourceTool → server: "context7-mcp", uri: "search://React documentation"
```

## Configuration

### Hook Script
- **Location**: `/Users/USERNAME/.claude/documentation-hooks.sh`
- **Permissions**: Executable
- **Log File**: `/Users/USERNAME/.claude/documentation-hook.log`

### Customization
Edit the script to:
- Add more documentation keywords
- Adjust framework detection patterns
- Modify context7 suggestions
- Change logging behavior

## Integration with Existing Hooks

Works alongside your existing hooks:
- **Gemini Hooks**: Code analysis continues to work
- **Playwright Hooks**: Web automation unaffected
- **Memory Hooks**: Documentation redirects saved to memory

## Slash Command

Use `/context7-docs` to remind Claude about proper context7 usage patterns.

## Memory Integration

Each redirected query is saved to Graphiti:
- Pattern: `"Documentation Search: Redirected '[query]' from [tool] to context7 for better results"`
- Searchable via: `~/.claude/graphiti-hook.sh search "Documentation Search"`

## Testing the Hook

Try these queries to see the hook in action:
- "Find React documentation"
- "Express.js API reference"
- "TypeScript guide"
- "Python tutorial"

The hook will block web search and suggest context7 instead.

## Benefits

1. **Consistent Documentation Source**: Always uses curated, official docs
2. **Better Results**: Context7 provides structured, up-to-date content
3. **Reduced Rate Limiting**: No web scraping limitations
4. **Learning**: Builds memory of proper tool usage patterns
5. **Guidance**: Shows exactly how to use context7 effectively

## Troubleshooting

### Hook Not Triggering
- Check hook permissions: `ls -la ~/.claude/documentation-hooks.sh`
- Verify hooks.json syntax: `cat ~/.claude/hooks.json | jq .`
- Check log file: `tail -f ~/.claude/documentation-hook.log`

### False Positives
If the hook blocks non-documentation queries:
- Edit detection patterns in `documentation-hooks.sh`
- Adjust keyword matching logic
- Add exceptions for specific terms

### Context7 Not Working
- Verify context7 MCP is configured: Check `claude_desktop_config.json`
- Test context7 manually: `ListMcpResourcesTool` with server "context7-mcp"
- Check context7 status in Claude Code

This hook ensures you always get the best documentation results by automatically steering you toward context7 instead of generic web search!