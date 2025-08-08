#!/bin/bash
# Slash command: /mcp-cleanup
# Description: Kill all duplicate MCP processes not part of the main proxy

# Get the proxy PID
PROXY_PID=""
if [ -f "/tmp/multi-mcp-proxy.pid" ]; then
    PROXY_PID=$(cat "/tmp/multi-mcp-proxy.pid")
fi

echo "🧹 MCP Cleanup - Killing duplicate processes..."
echo ""

# Count before cleanup
BEFORE_COUNT=$(ps aux | grep -E "mcp-server|serena-mcp|sequential|puppeteer|figma|brave|context7" | grep -v grep | wc -l)
echo "Found $BEFORE_COUNT MCP-related processes"

if [ -n "$PROXY_PID" ]; then
    echo "Preserving Multi-MCP proxy (PID: $PROXY_PID)"
fi

# Kill all MCP processes except the proxy
ps aux | grep -E "mcp-server|serena-mcp|sequential-thinking|mcp-puppeteer|figma-mcp|brave-search|context7-mcp|mcp-git" | \
    grep -v grep | \
    grep -v "$PROXY_PID" | \
    awk '{print $2}' | \
    xargs -r kill -9 2>/dev/null || true

# Count after cleanup
sleep 1
AFTER_COUNT=$(ps aux | grep -E "mcp-server|serena-mcp|sequential|puppeteer|figma|brave|context7" | grep -v grep | wc -l)

echo ""
echo "✅ Cleanup complete!"
echo "   Processes before: $BEFORE_COUNT"
echo "   Processes after: $AFTER_COUNT"
echo "   Cleaned up: $((BEFORE_COUNT - AFTER_COUNT)) processes"

# Show memory usage
MEMORY=$(ps aux | grep -E "mcp|serena|sequential|puppeteer|figma|brave|context7" | grep -v grep | awk '{sum+=$6} END {printf "%.1f", sum/1024}')
echo "   Current memory: ${MEMORY} MB"

# Check proxy status
if curl -s -f "http://127.0.0.1:8080/mcp_servers" > /dev/null 2>&1; then
    echo ""
    echo "✅ Multi-MCP proxy is healthy at http://127.0.0.1:8080"
else
    echo ""
    echo "⚠️  Multi-MCP proxy not responding. Run: ~/.claude/mcp-optimizer.sh restart"
fi