# Context7 Documentation Search

You should ALWAYS use context7 MCP for documentation searches instead of web search tools.

## How to Use Context7 MCP

When looking for documentation, follow this pattern:

### 1. List Available Documentation
```
Use the ListMcpResourcesTool with server: "context7-mcp" to see what documentation is available.
```

### 2. Read Specific Documentation  
```
Use the ReadMcpResourceTool with:
- server: "context7-mcp" 
- uri: The documentation URI from step 1
```

### 3. Search Documentation
```
For searches, use ReadMcpResourceTool with:
- server: "context7-mcp"
- uri: "search://your-query-here"
```

## Why Context7 Over Web Search?

- ✅ **Curated Content**: Official, high-quality documentation only
- ✅ **Always Current**: Up-to-date with latest versions
- ✅ **Structured Data**: Better formatted than web scraping
- ✅ **No Rate Limits**: Faster and more reliable
- ✅ **Better Context**: Understands developer needs

## Common Documentation Patterns

- **React docs** → Use context7, not web search
- **API references** → Use context7, not web search  
- **Framework guides** → Use context7, not web search
- **Library tutorials** → Use context7, not web search

## What to Use Web Search For

- General questions (not framework-specific)
- News and current events
- Community discussions
- Troubleshooting specific errors (after checking context7)

**Remember: Documentation = Context7, Everything else = Web Search**