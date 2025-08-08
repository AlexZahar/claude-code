#!/bin/bash
# Optimized MCP Session Hook - Prevents duplicate MCP server spawning
# This replaces the existing session hooks to ensure proxy-only usage

PROXY_PORT="8080"
PROXY_ENDPOINT="http://127.0.0.1:$PROXY_PORT"
LOG_FILE="/Users/USERNAME/.claude/mcp-session.log"
OPTIMIZER="/Users/USERNAME/.claude/mcp-optimizer.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if Multi-MCP proxy is running
check_proxy() {
    curl -s -f "$PROXY_ENDPOINT/mcp_servers" > /dev/null 2>&1
}

# Main logic
log "🚀 Claude Code session starting..."

# Check proxy status
if check_proxy; then
    log "✅ Multi-MCP proxy already running and healthy"
    
    # Quick cleanup check for any rogue processes
    DUPLICATE_COUNT=$(ps aux | grep -E "mcp-server|serena-mcp|sequential" | grep -v grep | grep -v "multi_mcp_proxy" | wc -l)
    if [ "$DUPLICATE_COUNT" -gt 10 ]; then
        log "⚠️  Found $DUPLICATE_COUNT duplicate MCP processes, cleaning up..."
        $OPTIMIZER cleanup
    fi
else
    log "🔄 Multi-MCP proxy not running, starting..."
    $OPTIMIZER start
fi

# Verify connection
if check_proxy; then
    echo "✅ MCP services ready via proxy at $PROXY_ENDPOINT"
    log "✅ Session ready with proxy connection"
else
    echo "⚠️  Warning: MCP proxy not responding. Run: ~/.claude/mcp-optimizer.sh start"
    log "❌ Failed to establish proxy connection"
fi

# Show quick status
echo "📊 MCP Status: $(ps aux | grep -E "mcp|serena|sequential" | grep -v grep | wc -l) processes, $(ps aux | grep -E "mcp|serena|sequential" | grep -v grep | awk '{sum+=$6} END {printf "%.0f", sum/1024}') MB"