#!/bin/bash

# BoardLens Development Environment Startup Hook - Original Version  
# Starts individual MCP servers (pre-Multi-MCP architecture)
#
# Architecture (Original Version):
# - Neo4j: Memory system backend
# - Individual MCP servers: Per-session server instances
# - Claude Monitor: Usage tracking
# - Context Loading: Recent memories and development state

set -e

HOOK_LOG_FILE="$HOME/.claude/boardlens-startup.log"
STARTUP_LOCK_FILE="/tmp/boardlens-dev-startup.lock"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$HOOK_LOG_FILE"
}

# Prevent multiple simultaneous startups
if [ -f "$STARTUP_LOCK_FILE" ]; then
    log_message "🔒 Startup already in progress, skipping..."
    exit 0
fi
echo $$ > "$STARTUP_LOCK_FILE"
trap "rm -f '$STARTUP_LOCK_FILE'" EXIT

log_message "🚀 Starting BoardLens Development Environment..."

# 1. Start Neo4j memory system
log_message "📊 Starting Neo4j memory system..."
if curl -s http://localhost:7474 >/dev/null 2>&1; then
    log_message "✅ Neo4j already running"
else
    log_message "🔄 Starting Neo4j..."
    docker start neo4j >/dev/null 2>&1 || {
        log_message "❌ Failed to start Neo4j"
    }
fi

# 2. Start individual MCP servers (original architecture)
log_message "🧠 Starting individual MCP servers..."

# Start Graphiti MCP Server (port 8889)
if ! curl -s http://localhost:8889 >/dev/null 2>&1; then
    log_message "🔄 Starting Graphiti MCP server..."
    cd "$HOME/Projects/boardlens/boardlens-python-api" && \
    nohup uv run --project graphiti-mcp main.py --port 8889 --host 127.0.0.1 > ~/.claude/graphiti-mcp.log 2>&1 &
    echo $! > ~/.claude/graphiti-mcp.pid
    sleep 2
else
    log_message "✅ Graphiti MCP already running"
fi

# Start Serena MCP Server (if configured)
if [ -d "$HOME/Projects/serena" ]; then
    if ! pgrep -f "serena.*mcp" >/dev/null; then
        log_message "🔄 Starting Serena MCP server..."
        cd "$HOME/Projects/serena" && \
        nohup uv run serena --mcp > ~/.claude/serena-mcp.log 2>&1 &
        echo $! > ~/.claude/serena-mcp.pid
        sleep 2
    else
        log_message "✅ Serena MCP already running"
    fi
fi

# 3. Load development context
log_message "🧠 Pre-loading BoardLens development context..."

# Create status summary
cat > ~/.claude/boardlens-dev-status.txt << EOF
# BoardLens Development Environment Status
Generated: $(date)

## Services Status
- Neo4j Memory System: $(curl -s http://localhost:7474 >/dev/null 2>&1 && echo "✅ Running" || echo "❌ Not running")
- Graphiti MCP Server: $(curl -s http://localhost:8889 >/dev/null 2>&1 && echo "✅ Running (port 8889)" || echo "❌ Not running")
- Serena MCP Server: $(pgrep -f "serena.*mcp" >/dev/null && echo "✅ Running" || echo "❌ Not running")

## MCP Architecture
- Mode: Individual MCP Servers (original architecture)
- Graphiti: http://127.0.0.1:8889
- Serena: Stdio-based connection
- Memory: Direct Graphiti server connection

## Projects Configured
- boardlens-frontend: React/TypeScript application
- boardlens-backend: Node.js/Express API
- boardlens-python-api: Python/FastAPI service
- boardlens-rag: RAG/LLM integration service

## Memory Integration
- Graphiti Knowledge Graph: Active (Neo4j backend)
- Auto-memory capture: Enabled via hooks
- Session continuity: Per-session server instances

## Key Features (Original)
- ✅ Individual server instances per session
- ✅ Direct MCP server connections
- ✅ Memory capture and retrieval
- ✅ Development context loading
EOF

log_message "🎉 BoardLens Development Environment Started!"
log_message "📈 Services Status: Neo4j + Individual MCP Servers"
log_message "📋 Status summary saved to ~/.claude/boardlens-dev-status.txt"

# Brief delay to let services fully initialize
sleep 2

log_message "🚀 BoardLens development environment ready for coding!"

# Clean up
rm -f "$STARTUP_LOCK_FILE"