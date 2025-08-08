#!/bin/bash
# Smart session cleanup with MCP server management

SESSION_NAME="$1"
TRACKING_DIR="$HOME/.claude/sessions"
LOG_FILE="$HOME/.claude/cleanup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Kill MCP servers associated with this session
cleanup_mcp_servers() {
    local pid_file="$TRACKING_DIR/$SESSION_NAME.pids"
    
    if [ -f "$pid_file" ]; then
        log "Cleaning up MCP servers for session: $SESSION_NAME"
        while IFS= read -r pid; do
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid" 2>/dev/null && log "Killed PID $pid"
            fi
        done < "$pid_file"
        rm -f "$pid_file"
    fi
    
    # Also cleanup any orphaned servers by pattern matching
    local patterns=(
        "serena-mcp-server.*--project.*$(basename "$SESSION_NAME")"
        "mcp-sequential-thinking.*$SESSION_NAME"
    )
    
    for pattern in "${patterns[@]}"; do
        pkill -f "$pattern" 2>/dev/null || true
    done
}

# Main cleanup
log "Starting cleanup for session: $SESSION_NAME"
cleanup_mcp_servers
log "Cleanup completed for session: $SESSION_NAME"