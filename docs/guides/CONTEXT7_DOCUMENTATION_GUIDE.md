# Context7 MCP Documentation Search Guide

## Overview

Context7 MCP provides a persistent, searchable knowledge base for technical documentation. It's configured to intercept WebSearch/WebFetch requests for documentation and suggest using Context7 instead.

## Configuration Status ✅

1. **Context7 MCP Server**: Already configured in Claude Code config
2. **Documentation Hooks**: Updated to suggest Context7 tools
3. **CLAUDE.md**: Updated with Context7 workflow instructions
4. **Hook Triggers**: Set to activate on WebSearch/WebFetch

## How It Works

### 1. Automatic Detection
When you attempt to search for documentation using WebSearch or WebFetch, the hook:
- Detects documentation-related queries (docs, API, guide, tutorial, etc.)
- Suggests using Context7 MCP instead
- Provides specific tool recommendations

### 2. Documentation Patterns Detected
- Framework names + "docs" (e.g., "React docs")
- API references
- Tutorials and guides
- How-to content
- README files
- Developer documentation sites

### 3. Workflow

#### First Time Documentation Access:
```python
# 1. Search Context7 first
results = mcp__context7-mcp__search_knowledge("LlamaIndex query engine")

# 2. If not found, fetch and index
if not results:
    # Fetch from web
    content = WebFetch(url, "Extract documentation")
    
    # Index in Context7
    mcp__context7-mcp__add_knowledge(
        title="LlamaIndex Query Engine Guide",
        content=content,
        metadata={
            "source": url,
            "technology": "LlamaIndex",
            "type": "guide",
            "last_updated": "2024-07-24"
        }
    )
```

#### Subsequent Access:
```python
# Direct search - instant results!
mcp__context7-mcp__search_knowledge("query engine configuration")
```

## Available Context7 Tools

### Core Tools:
- `mcp__context7-mcp__search_knowledge(query)` - Search all indexed docs
- `mcp__context7-mcp__add_knowledge(title, content, metadata)` - Add new docs
- `mcp__context7-mcp__list_knowledge()` - List all indexed documentation
- `mcp__context7-mcp__get_knowledge(id)` - Get specific doc by ID

### Management Tools:
- `mcp__context7-mcp__update_knowledge(id, updates)` - Update existing docs
- `mcp__context7-mcp__delete_knowledge(id)` - Remove outdated docs

## Metadata Best Practices

When indexing documentation, include:
```python
metadata = {
    "source": "https://docs.example.com/guide",  # Original URL
    "technology": "React",                       # Framework/library
    "type": "guide",                            # guide/api/tutorial/reference
    "version": "18.2",                          # Version number
    "last_updated": "2024-07-24",               # Date
    "tags": ["hooks", "state", "effects"]       # Searchable tags
}
```

## Hook Behavior

### When WebSearch/WebFetch is Used:
1. Hook checks if query is documentation-related
2. If yes, displays Context7 suggestions
3. Blocks the request with exit code 1
4. Forces you to use Context7 instead

### Override Hook (Emergency Only):
If you absolutely need to use WebSearch for docs:
```bash
# Temporarily disable hook
mv ~/.claude/hooks.json ~/.claude/hooks.json.backup
# Use WebSearch
# Re-enable hook
mv ~/.claude/hooks.json.backup ~/.claude/hooks.json
```

## Benefits

1. **Speed**: No network latency, instant results
2. **Reliability**: No rate limits or blocked requests
3. **Searchability**: Semantic search across all docs
4. **Persistence**: Build a knowledge base over time
5. **Versioning**: Track documentation versions
6. **Offline Access**: Works without internet

## Common Use Cases

### 1. Framework Documentation
```python
# First time
content = WebFetch("https://react.dev/learn/hooks", "Extract hooks guide")
mcp__context7-mcp__add_knowledge("React Hooks Guide", content, {...})

# Later
mcp__context7-mcp__search_knowledge("useEffect cleanup")
```

### 2. API References
```python
# Index API docs
mcp__context7-mcp__add_knowledge("Stripe API Reference", api_content, {
    "source": "https://stripe.com/docs/api",
    "type": "api_reference",
    "version": "2024-07-24"
})

# Search later
mcp__context7-mcp__search_knowledge("stripe payment intent")
```

### 3. Library Guides
```python
# Index multiple related docs
for doc in library_docs:
    mcp__context7-mcp__add_knowledge(doc.title, doc.content, {
        "technology": "LlamaIndex",
        "type": doc.type
    })

# Comprehensive search
mcp__context7-mcp__search_knowledge("vector store configuration")
```

## Maintenance

### Regular Tasks:
1. **Update outdated docs**: Use `update_knowledge` when versions change
2. **Remove old versions**: Use `delete_knowledge` for deprecated docs
3. **Review indexed docs**: Use `list_knowledge` periodically
4. **Tag consistently**: Use consistent metadata for better search

### Storage Location:
Context7 stores data in its own persistent storage, separate from file system.

## Troubleshooting

### If Context7 tools don't appear:
1. Restart Claude Code
2. Check config: `cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | grep context7`
3. Verify server is configured correctly

### If searches return no results:
1. Check if docs are indexed: `mcp__context7-mcp__list_knowledge()`
2. Try broader search terms
3. Verify metadata is correct

### If indexing fails:
1. Check content size (may have limits)
2. Ensure metadata is valid JSON
3. Try smaller chunks of documentation

## Summary

Context7 MCP transforms documentation access from:
- ❌ Slow web searches → ✅ Instant local search
- ❌ Rate-limited APIs → ✅ Unlimited queries
- ❌ Scattered results → ✅ Curated knowledge base
- ❌ Network dependent → ✅ Always available

Use Context7 for all documentation needs!