#!/bin/bash

# BoardLens Development Environment Startup Hook - Multi-MCP Version
# Updated for Multi-MCP proxy architecture - no longer starts individual MCP servers
#
# Architecture (Multi-MCP Version):
# - Neo4j: Memory system backend
# - Multi-MCP Proxy: Single shared proxy for all MCP servers across sessions
# - Claude Monitor: Usage tracking  
# - Context Loading: Recent memories and development state
#
# Key Change: Uses shared Multi-MCP proxy instead of per-session MCP servers

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

# 2. Ensure Multi-MCP proxy is running (replaces individual MCP server startup)
log_message "🧠 Verifying Multi-MCP proxy integration..."
if ~/.claude/multi-mcp-service.sh status | grep -q "✅ Running"; then
    log_message "✅ Multi-MCP proxy running and accessible"
    # Get server count from proxy
    server_count=$(curl -s "http://127.0.0.1:8080/mcp_servers" | python3 -c "import sys, json; data=json.load(sys.stdin); print(len(data['active_servers']))" 2>/dev/null || echo "unknown")
    log_message "📋 Multi-MCP proxy serving $server_count MCP servers"
else
    log_message "🚀 Starting Multi-MCP proxy..."
    ~/.claude/multi-mcp-service.sh start
    if ~/.claude/multi-mcp-service.sh status | grep -q "✅ Running"; then
        log_message "✅ Multi-MCP proxy started successfully"
    else
        log_message "❌ Failed to start Multi-MCP proxy"
    fi
fi

# 3. Load development context (same as before)
log_message "🧠 Pre-loading BoardLens development context..."

# Create status summary
cat > ~/.claude/boardlens-dev-status.txt << EOF
# BoardLens Development Environment Status
Generated: $(date)

## Services Status
- Neo4j Memory System: $(curl -s http://localhost:7474 >/dev/null 2>&1 && echo "✅ Running" || echo "❌ Not running")
- Multi-MCP Proxy: $(~/.claude/multi-mcp-service.sh status | grep -q "✅ Running" && echo "✅ Running (shared across sessions)" || echo "❌ Not running")

## MCP Architecture  
- Mode: Multi-MCP Proxy (shared servers)
- Endpoint: http://127.0.0.1:8080/sse
- Servers: $(curl -s "http://127.0.0.1:8080/mcp_servers" 2>/dev/null | python3 -c "import sys, json; data=json.load(sys.stdin); print(', '.join(data['active_servers']))" 2>/dev/null || echo "Unable to fetch")

## Projects Configured
- boardlens-frontend: React/TypeScript application
- boardlens-backend: Node.js/Express API  
- boardlens-python-api: Python/FastAPI service
- boardlens-rag: RAG/LLM integration service

## Memory Integration
- Graphiti Knowledge Graph: Active (Neo4j backend)
- Auto-memory capture: Enabled via hooks
- Session continuity: Maintained across Claude sessions

## Key Benefits (Multi-MCP)
- ✅ Memory sharing across Claude Code sessions
- ✅ Single set of MCP servers (eliminates duplication)  
- ✅ Automatic proxy management
- ✅ Reduced memory footprint (~150-300MB vs 900MB+)
EOF

log_message "🎉 BoardLens Development Environment Started!"
log_message "📈 Services Status: Neo4j + Multi-MCP Proxy"
log_message "📋 Status summary saved to ~/.claude/boardlens-dev-status.txt"

# Brief delay to let services fully initialize
sleep 2

log_message "🚀 BoardLens development environment ready for coding!"

# Clean up
rm -f "$STARTUP_LOCK_FILE"