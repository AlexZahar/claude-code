#!/bin/bash
# MCP Cleanup Hook for Claude Code - Original Version
# Cleans up individual MCP servers when session ends

MCP_CLEANUP_LOG="$HOME/.claude/mcp-cleanup.log"

# Function to log messages
log_cleanup() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$MCP_CLEANUP_LOG"
}

# Function to safely stop a server by PID file
stop_server() {
    local server_name="$1"
    local pid_file="$2"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            log_cleanup "Stopping $server_name MCP server (PID: $pid)"
            kill "$pid" 2>/dev/null
            sleep 2
            
            # Force kill if still running
            if kill -0 "$pid" 2>/dev/null; then
                log_cleanup "Force killing $server_name MCP server (PID: $pid)"
                kill -9 "$pid" 2>/dev/null
            fi
            
            rm -f "$pid_file"
            log_cleanup "$server_name MCP server stopped"
        else
            log_cleanup "$server_name PID file exists but process not running"
            rm -f "$pid_file"
        fi
    else
        log_cleanup "No PID file found for $server_name MCP server"
    fi
}

# Main cleanup logic
case "${1:-cleanup}" in
    cleanup)
        if [ -n "$TMUX" ]; then
            session_id=$(tmux display-message -p '#S')
            log_cleanup "Cleaning up MCP servers for tmux session: $session_id"
        else
            log_cleanup "Cleaning up MCP servers for Claude Code session"
        fi
        
        # Stop individual MCP servers
        stop_server "Graphiti" "$HOME/.claude/graphiti-mcp.pid"
        
        # Stop Serena MCP server (if running)
        if pgrep -f "serena.*mcp" >/dev/null; then
            serena_pid=$(pgrep -f "serena.*mcp")
            log_cleanup "Stopping Serena MCP server (PID: $serena_pid)"
            kill "$serena_pid" 2>/dev/null
            sleep 1
            if pgrep -f "serena.*mcp" >/dev/null; then
                kill -9 "$serena_pid" 2>/dev/null
            fi
            rm -f "$HOME/.claude/serena-mcp.pid"
            log_cleanup "Serena MCP server stopped"
        fi
        
        # Clean up any stale log files older than 7 days
        find "$HOME/.claude" -name "*mcp*.log" -mtime +7 -delete 2>/dev/null || true
        
        log_cleanup "MCP server cleanup completed"
        ;;
        
    status)
        echo "Individual MCP Server Status:"
        echo "─────────────────────────────"
        
        # Check Graphiti
        if [ -f "$HOME/.claude/graphiti-mcp.pid" ] && kill -0 "$(cat "$HOME/.claude/graphiti-mcp.pid")" 2>/dev/null; then
            echo "Graphiti MCP: ✅ Running (PID: $(cat "$HOME/.claude/graphiti-mcp.pid"))"
        else
            echo "Graphiti MCP: ❌ Not running"
        fi
        
        # Check Serena
        if pgrep -f "serena.*mcp" >/dev/null; then
            echo "Serena MCP: ✅ Running (PID: $(pgrep -f "serena.*mcp"))"
        else
            echo "Serena MCP: ❌ Not running"
        fi
        
        # Memory usage
        total_mem=$(ps aux | grep -E "(graphiti|serena).*mcp" | grep -v grep | awk '{mem+=$6} END {print mem/1024}' || echo "0")
        echo "Total Memory: ${total_mem} MB"
        ;;
        
    *)
        echo "Usage: $0 [cleanup|status]"
        exit 1
        ;;
esac