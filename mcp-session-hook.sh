#!/bin/bash
# MCP Session Hook - Original Version (Individual MCP Servers)
# Tracks individual MCP server PIDs and session information

MCP_SESSION_LOG="$HOME/.claude/mcp-session.log"

# Function to log messages
log_session() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$MCP_SESSION_LOG"
}

# Check and log MCP server status
check_server_status() {
    local server_name="$1"
    local pid_file="$2"
    local port="$3"
    
    if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        log_session "$server_name MCP server running (PID: $(cat "$pid_file"))"
        return 0
    elif [ -n "$port" ] && curl -s "http://localhost:$port" >/dev/null 2>&1; then
        log_session "$server_name MCP server responding on port $port"
        return 0
    else
        log_session "⚠️  $server_name MCP server not running"
        return 1
    fi
}

# Main session tracking
if [ -n "$TMUX" ]; then
    session_id=$(tmux display-message -p '#S')
    log_session "Claude Code session started in tmux: $session_id"
else
    log_session "Claude Code session started (no tmux)"
fi

# Check status of individual MCP servers
log_session "Checking MCP server status..."

# Check Graphiti MCP server
check_server_status "Graphiti" "$HOME/.claude/graphiti-mcp.pid" "8889"

# Check Serena MCP server  
if pgrep -f "serena.*mcp" >/dev/null; then
    log_session "Serena MCP server running (PID: $(pgrep -f "serena.*mcp"))"
else
    log_session "⚠️  Serena MCP server not running"
fi

# Record session environment
log_session "Environment: CLAUDE_SESSION_ID=${CLAUDE_SESSION_ID:-unknown}"
log_session "Working directory: $(pwd)"

# Log memory usage
total_mem=$(ps aux | grep -E "(graphiti|serena).*mcp" | grep -v grep | awk '{mem+=$6} END {print mem/1024}' || echo "0")
log_session "Total MCP server memory usage: ${total_mem} MB"