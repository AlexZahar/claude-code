#!/bin/bash
# Multi-MCP Cleanup Hook for Claude Code
# Updated for Multi-MCP architecture - no individual cleanup needed

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> ~/.claude/mcp-cleanup.log
}

# Main execution
case "${1:-cleanup}" in
    cleanup)
        # With Multi-MCP, there's no per-session cleanup needed
        # The proxy continues running for other sessions
        if [ -n "$TMUX" ]; then
            local session_id=$(tmux display-message -p '#S')
            log_message "Session $session_id ending - Multi-MCP proxy continues serving other sessions"
        else
            log_message "Claude Code session ending - Multi-MCP proxy continues serving other sessions"
        fi
        ;;
    status)
        echo "Multi-MCP Proxy: $(pgrep -f "multi-mcp.*main.py" | wc -l | tr -d ' ')"
        echo "MCP Backend Servers: $(ps aux | grep -E "(mcp|serena)" | grep -v grep | grep -v "multi-mcp" | wc -l)"
        echo "Total Memory: $(ps aux | grep -E "(mcp|serena)" | grep -v grep | awk '{mem+=$6} END {print mem/1024}') MB"
        ;;
    *)
        echo "Usage: $0 [cleanup|status]"
        exit 1
        ;;
esac