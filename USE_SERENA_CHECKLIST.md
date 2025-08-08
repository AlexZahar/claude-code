# ✅ Serena MCP Setup Checklist & Usage Guide

## Setup Status

- [x] Serena installed at `/Users/USERNAME/Projects/mcp/serena/`
- [x] Serena MCP server added to `claude_desktop_config.json`
- [x] CLAUDE.md updated with Serena-first instructions
- [x] Hooks added to remind about Serena usage
- [x] Serena hooks script created at `~/.claude/serena-hooks.sh`
- [x] Projects configured in `~/.serena/serena_config.yml`

## 🚀 Quick Start

### 1. Restart Claude Code
```bash
# Quit Claude Code completely (Cmd+Q)
# Then restart it
# Serena tools should now be available
```

### 2. Verify Serena Tools
In a new chat, type:
```
What MCP tools starting with mcp__serena are available?
```

You should see:
- mcp__serena__activate_project
- mcp__serena__find_symbol
- mcp__serena__search_for_pattern
- mcp__serena__get_symbols_overview
- mcp__serena__find_referencing_symbols
- mcp__serena__replace_symbol_body
- And more...

### 3. Activate a Project
```
mcp__serena__activate_project("boardlens-rag")
# or full path:
mcp__serena__activate_project("/Users/USERNAME/Projects/boardlens/boardlens-rag")
```

## 📚 Common Serena Workflows

### Finding Functions/Classes
```python
# Find a specific function
mcp__serena__find_symbol("execute_rag_query")

# Find with more context
mcp__serena__find_symbol("execute_rag_query", relative_path="services/")

# Find classes
mcp__serena__find_symbol("RAGQueryParameters")
```

### Understanding Code Structure
```python
# Get overview of a directory
mcp__serena__get_symbols_overview("services/")

# Get overview of a specific file
mcp__serena__get_symbols_overview("services/rag_query_service.py")
```

### Finding All Usages
```python
# Find who calls a function
mcp__serena__find_referencing_symbols(
    "execute_rag_query",
    "services/rag_query_service.py"
)
```

### Code Search with Context
```python
# Search for patterns
mcp__serena__search_for_pattern("alpha.*0.5")

# Search in specific area
mcp__serena__search_for_pattern(
    "hybrid.*search",
    relative_path="services/",
    context_lines_before=3,
    context_lines_after=3
)
```

### Precise Code Editing
```python
# Replace entire function body
mcp__serena__replace_symbol_body(
    "function_name",
    "path/to/file.py",
    "new function body here"
)
```

## 🚨 What NOT to Do

### ❌ Don't use these for code:
- `Grep` - Text search without understanding
- `Search` - Generic file search
- `Agent` - For code navigation
- `Glob` + `Read` - For finding code

### ✅ Always use Serena for:
- Finding functions, classes, methods
- Understanding code structure
- Finding all usages/references
- Making precise edits
- Navigating large codebases

## 🔧 Troubleshooting

### If Serena tools don't appear:
1. Check MCP logs: `tail -f ~/Library/Logs/Claude/mcp*.log`
2. Verify server exists: `ls -la /Users/USERNAME/Projects/mcp/serena/.venv/bin/serena-mcp-server`
3. Try manual test: `/Users/USERNAME/Projects/mcp/serena/.venv/bin/serena-mcp-server --help`

### If project activation fails:
1. Check project name in `~/.serena/serena_config.yml`
2. Use full path instead of project name
3. Check Serena logs: `tail -f ~/.claude/serena-*.log`

### If symbol search fails:
1. Ensure project is activated first
2. Check language server is running
3. Try simpler symbol names
4. Use `get_symbols_overview` first

## 📊 Performance Tips

1. **Activate project once** at session start
2. **Use symbol names** not text patterns when possible
3. **Start broad** with overview, then narrow down
4. **Cache is your friend** - repeated searches are fast
5. **Language servers** may need initial indexing time

## 🎯 Key Benefits

1. **Accuracy**: Finds exact symbols, not text matches
2. **Context**: Understands imports, inheritance, references
3. **Speed**: Indexed lookups beat text search
4. **Safety**: Symbol-aware edits prevent breaking changes
5. **Scale**: Works efficiently on massive codebases

## 📝 Example Session

```python
# 1. Start with project activation
mcp__serena__activate_project("boardlens-rag")

# 2. Get overview
mcp__serena__get_symbols_overview("services/")

# 3. Find specific function
mcp__serena__find_symbol("execute_rag_query")

# 4. Check its usages
mcp__serena__find_referencing_symbols(
    "execute_rag_query",
    "services/rag_query_service.py"
)

# 5. Make precise edit
mcp__serena__replace_symbol_body(
    "execute_rag_query",
    "services/rag_query_service.py",
    "updated function body..."
)
```

Remember: **Serena = Semantic Understanding > Text Matching**