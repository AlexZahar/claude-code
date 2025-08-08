#!/bin/bash
# Multi-MCP Session Hook - Updated for proxy mode
# No longer tracks individual MCP server PIDs since we use shared proxy

# Check if Multi-MCP proxy is running, start if needed
if ! ~/.claude/multi-mcp-service.sh status | grep -q "✅ Running"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Multi-MCP proxy not running, starting..." >> ~/.claude/mcp-session.log
    ~/.claude/multi-mcp-service.sh start >> ~/.claude/mcp-session.log 2>&1
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Multi-MCP proxy already running, session will share MCP servers" >> ~/.claude/mcp-session.log
fi

# Log session info for debugging
if [ -n "$TMUX" ]; then
    session_id=$(tmux display-message -p '#S')
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Claude Code session in tmux: $session_id (using Multi-MCP proxy)" >> ~/.claude/mcp-session.log
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Claude Code session (using Multi-MCP proxy)" >> ~/.claude/mcp-session.log
fi