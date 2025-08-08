# Serena MCP Consolidated Guide

## Current Setup (As of July 24, 2025)

### ✅ What's Working
- Serena MCP is configured with **user scope** and persists across terminal sessions
- Shows as "✓ Connected" in `claude mcp list`
- Uses **stdio transport** (not SSE) for direct Claude Code integration
- No external workers or background processes required

### 🛠️ Configuration
```bash
# Current working configuration
claude mcp add serena --scope user -- uvx --from git+https://github.com/oraios/serena serena-mcp-server --context ide-assistant --enable-web-dashboard false
```

### 📍 Key Files
- **Setup Guide**: `~/.claude/SERENA_MCP_SETUP.md` - Detailed setup instructions
- **Global Config**: `~/.serena/serena_config.yml.disabled` - Disabled to avoid bug
- **Migration Guide**: `/Users/USERNAME/Projects/boardlens/SERENA_MCP_MIGRATION_GUIDE.md` - Architecture reference
- **Project Config**: Each project needs `.serena/project.yml` file

### 🐛 Known Issue
- **Bug**: Serena crashes when loading projects from global config due to yaml parsing error
- **Location**: `serena_config.py:239` - tries to assign to string instead of dict
- **Workaround**: Global config disabled, projects activated on-demand

## Usage in Claude Code

### Per-Session Activation
1. **Verify Connection**:
   ```bash
   claude mcp list | grep serena
   ```

2. **Load Instructions** (once per session):
   ```
   /mcp__serena__initial_instructions
   ```

3. **Activate Project** (when needed):
   ```
   mcp__serena__activate_project("/path/to/project")
   ```

### Available Tools (when activated)
- `mcp__serena__find_symbol` - Find code symbols
- `mcp__serena__search_for_pattern` - Pattern search
- `mcp__serena__get_symbols_overview` - File structure
- `mcp__serena__find_referencing_symbols` - Find usages
- `mcp__serena__replace_symbol_body` - Edit code

## Project Configuration

Each project needs a `.serena/project.yml` file:
```yaml
# Required
language: typescript  # or python, java, etc.

# Recommended
ignore_all_files_in_gitignore: true
ignored_paths:
  - node_modules
  - .next
  - dist
  
read_only: false
```

## What We Removed
- ❌ Multiple SSE instances on ports 8001-8004
- ❌ boardlens-dev Serena integration
- ❌ Outdated setup guides suggesting different approaches
- ❌ References to external Redis workers

## Troubleshooting

### If Serena stops connecting:
1. Check `claude mcp list` for status
2. Ensure global config remains disabled
3. Re-add with the working command above

### If you need multiple projects:
1. Don't use global config (it's buggy)
2. Activate projects individually per session
3. Or fix all project.yml files and re-enable global config

## Memory References
- **Key Memory**: "Serena MCP Fix: Solved connection failure... documented in SERENA_MCP_WORKING_SETUP.md"
- Search memories: `~/.claude/graphiti-hook.sh search "serena"`

## Important Notes
- This setup bypasses the multi-project loading bug
- Projects are activated on-demand, not preloaded
- No background processes or external workers needed
- Uses Claude's Task subagents for all operations