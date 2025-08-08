# Claude Code Advanced Setup

This is a sanitized copy of an advanced Claude Code configuration with:
- Graphiti memory system (Neo4j)
- Sequential thinking MCP
- Serena code intelligence
- Smart hooks and automation

## Setup Instructions

1. **Replace USERNAME with your actual username** in all files:
   ```bash
   find . -type f -exec sed -i 's|/Users/USERNAME|/Users/YOUR_USERNAME|g' {} \;
   ```

2. **Initialize Neo4j** (required for memory):
   ```bash
   ./initialize-graphiti.sh
   ```

3. **Copy to your ~/.claude folder**:
   ```bash
   cp -r * ~/.claude/
   ```

4. **Customize for your projects**:
   - Update project names in CLAUDE.md
   - Adjust hook paths in settings.json
   - Configure your MCP servers

## What's Included

- **Memory System**: Automatic knowledge graph with Neo4j
- **Smart Hooks**: Pre/post operation analysis
- **Optimized Settings**: Production-ready configurations
- **MCP Integrations**: Sequential thinking, Serena, and more

## Security Note

All sensitive data has been removed. You'll need to add your own:
- API keys
- Project-specific paths
- Personal configurations
