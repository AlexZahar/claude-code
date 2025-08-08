# Claude Code Environment Migration Guide

Complete guide for moving your Claude Code environment from one machine to another.

## Overview

Your Claude Code environment consists of:
1. **~/.claude directory** - Configuration, hooks, memories, tools
2. **~/projects/mcp/** - MCP servers (Graphiti, Sequential Thinking)  
3. **Docker Neo4j** - Memory system backend
4. **Global settings** - API keys and model configurations

## Recommended: Simple Copy Approach

### Source Machine (Export)
```bash
# 1. Stop any running services
docker stop neo4j 2>/dev/null || true

# 2. Simple copy approach - much easier!
# Copy entire .claude folder
scp -r ~/.claude/ new-machine:~/

# Copy entire MCP projects folder  
scp -r ~/projects/mcp/ new-machine:~/projects/

# That's it! Much simpler than archiving.
```

### Target Machine (Setup)

```bash
# 1. Install dependencies
# Install Docker, Python 3.9+, UV package manager
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Install Claude Code
# Follow official installation instructions

# 3. Files already copied via scp above

# 4. Fix permissions (may be needed)
chmod +x ~/.claude/*.sh
find ~/.claude -name "*.py" -exec chmod +x {} \;

# 5. Fresh memory setup (wipe old memories)
# Stop any existing Neo4j
docker stop neo4j 2>/dev/null || true
docker rm neo4j 2>/dev/null || true
docker volume rm neo4j_data 2>/dev/null || true

# Initialize fresh memory system
~/.claude/initialize-graphiti.sh
```

## MCP Server Setup

Since you're copying the entire MCP folder, the virtual environments should transfer too. Just verify they work:

### Sequential Thinking MCP
```bash
cd ~/projects/mcp/mcp-sequential-thinking

# Test if existing .venv works
.venv/bin/mcp-sequential-thinking --help

# If above fails, reinstall dependencies
uv sync
```

### Graphiti MCP  
```bash
cd ~/projects/mcp/graphiti

# Test existing installation
python -c "import graphiti; print('Graphiti installed successfully')"

# If above fails, reinstall
uv sync
cd server && uv sync
```

## Memory System Setup

### Fresh Memory Start (Recommended)
Since you want to wipe old memories anyway:

```bash
# Run initialization script (already done above)
~/.claude/initialize-graphiti.sh

# This will:
# - Install Neo4j via Docker
# - Configure it for Graphiti  
# - Set up Python dependencies
# - Start with auto-restart
# - Fresh, empty memory system
```

## Configuration Validation

### Test Basic Setup
```bash
# 1. Check Claude Code works
claude --version

# 2. Test MCP servers
cd ~/projects/mcp/mcp-sequential-thinking
.venv/bin/mcp-sequential-thinking --help

cd ~/projects/mcp/graphiti/server  
python -c "import graphiti; print('OK')"

# 3. Test Neo4j
curl -s http://localhost:7474 && echo "Neo4j running"

# 4. Test memory system
~/.claude/graphiti-hook.sh add "Migration test - $(date)"
~/.claude/graphiti-hook.sh search "migration"
```

### Test Hooks
```bash
# Test memory hooks
python3 ~/.claude/claude_memory_hook.py test

# Test Gemini hooks (if configured)
~/.claude/gemini-hooks.sh help

# Test startup hooks
~/.claude/neo4j-startup-hook.sh
```

## Troubleshooting

### Common Issues

1. **Permission Errors**
   ```bash
   chmod +x ~/.claude/*.sh
   chmod +x ~/.claude/**/*.py
   ```

2. **Python Environment Issues**
   ```bash
   cd ~/projects/mcp/mcp-sequential-thinking
   rm -rf .venv
   uv sync
   ```

3. **Neo4j Connection Issues**
   ```bash
   docker logs neo4j
   docker restart neo4j
   ~/.claude/initialize-graphiti.sh
   ```

4. **MCP Server Issues**
   ```bash
   # Test individually
   cd ~/projects/mcp/mcp-sequential-thinking
   uv run python -m mcp_sequential_thinking.server
   ```

### Path Updates Needed

Update these paths in settings if different:
- `~/.claude/settings.local.json` - MCP server paths
- Hook scripts - Any hardcoded paths
- Memory system - Database connection strings

## Verification Steps

1. **Start new Claude Code session**
2. **Test memory search**: `/recall migration`
3. **Test sequential thinking**: Use MCP tools
4. **Test hooks**: Edit a file, check if memory captures
5. **Test Gemini integration**: Run analysis commands

## What NOT to Transfer

- **Docker containers** - Rebuild fresh
- **Virtual environments** - Recreate with uv
- **API keys** - Set up fresh (security)
- **Temporary files** - .pyc, logs, caches

## Selective Migration (Alternative)

If full migration is complex, you can set up fresh and only transfer:

1. **Essential memories**: Export key memories from Graphiti
2. **Custom hooks**: Copy only your custom hook scripts  
3. **Project-specific configs**: Copy CLAUDE.md and project files
4. **Slash commands**: Copy ~/.claude/slash-commands/

## Security Notes

- Never transfer API keys in plain text
- Regenerate authentication tokens
- Update any hardcoded paths
- Review hook permissions on new machine
- Verify Docker container security settings

## Performance Optimization

After migration:
1. **Test memory performance**: Large query response times
2. **Monitor hook execution**: Check hook logs for timeouts
3. **Verify MCP responsiveness**: Test sequential thinking speed
4. **Check Docker resources**: Ensure adequate memory/CPU

This guide ensures complete environment portability while maintaining security and performance.