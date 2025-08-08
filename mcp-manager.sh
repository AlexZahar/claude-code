#!/bin/bash
# MCP Server Manager - Smart lifecycle management

MCP_STATE_DIR="$HOME/.claude/mcp-state"
mkdir -p "$MCP_STATE_DIR"

# Global MCP servers that should run once
GLOBAL_SERVERS=(
    "filesystem:npx -y @modelcontextprotocol/server-filesystem /Users/USERNAME/ /Users/USERNAME/Projects"
    "github:npx -y @modelcontextprotocol/server-github"
    "brave-search:npx -y @modelcontextprotocol/server-brave-search"
)

# Check if global server is running
is_global_running() {
    local server_name="$1"
    local pid_file="$MCP_STATE_DIR/global-$server_name.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        else
            rm -f "$pid_file"
        fi
    fi
    return 1
}

# Start global servers if not running
start_globals() {
    echo "🚀 Starting global MCP servers..."
    
    for server_def in "${GLOBAL_SERVERS[@]}"; do
        local name="${server_def%%:*}"
        local cmd="${server_def#*:}"
        
        if ! is_global_running "$name"; then
            echo "Starting $name..."
            # Start in background and save PID
            eval "$cmd" > "$MCP_STATE_DIR/global-$name.log" 2>&1 &
            local pid=$!
            echo "$pid" > "$MCP_STATE_DIR/global-$name.pid"
            echo "✅ Started $name (PID: $pid)"
        else
            echo "✅ $name already running"
        fi
    done
}

# Stop all global servers
stop_globals() {
    echo "🛑 Stopping global MCP servers..."
    
    for pid_file in "$MCP_STATE_DIR"/global-*.pid; do
        [ -f "$pid_file" ] || continue
        local pid=$(cat "$pid_file")
        local name=$(basename "$pid_file" .pid | sed 's/global-//')
        
        if kill "$pid" 2>/dev/null; then
            echo "✅ Stopped $name"
        fi
        rm -f "$pid_file"
    done
}

# Get MCP server status
status() {
    echo "📊 MCP Server Status:"
    echo
    echo "Global Servers:"
    for server_def in "${GLOBAL_SERVERS[@]}"; do
        local name="${server_def%%:*}"
        if is_global_running "$name"; then
            local pid=$(cat "$MCP_STATE_DIR/global-$name.pid")
            echo "  ✅ $name (PID: $pid)"
        else
            echo "  ❌ $name (not running)"
        fi
    done
    
    echo
    echo "Per-Session Servers:"
    ps aux | grep -E "(serena-mcp-server|mcp-sequential-thinking|graphiti)" | grep -v grep | while read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        local cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
        echo "  • PID $pid: $cmd"
    done | head -10
}

# Clean zombie MCP processes
clean_zombies() {
    echo "🧹 Cleaning zombie MCP processes..."
    
    # Find MCP processes not associated with any tmux session
    local cleaned=0
    ps aux | grep -E "(mcp-server|serena|sequential-thinking)" | grep -v grep | while read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        local ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
        
        # Check if parent is a tmux process
        if [ -n "$ppid" ]; then
            local parent_cmd=$(ps -o comm= -p "$ppid" 2>/dev/null)
            if [[ "$parent_cmd" != *"tmux"* ]] && [[ "$parent_cmd" != *"claude"* ]]; then
                kill "$pid" 2>/dev/null && ((cleaned++))
            fi
        fi
    done
    
    echo "✅ Cleaned $cleaned zombie processes"
}

# Main command handler
case "${1:-help}" in
    start)
        start_globals
        ;;
    stop)
        stop_globals
        ;;
    restart)
        stop_globals
        sleep 2
        start_globals
        ;;
    status)
        status
        ;;
    clean)
        clean_zombies
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|clean}"
        echo
        echo "Commands:"
        echo "  start   - Start global MCP servers"
        echo "  stop    - Stop global MCP servers"
        echo "  restart - Restart global MCP servers"
        echo "  status  - Show status of all MCP servers"
        echo "  clean   - Clean up zombie MCP processes"
        ;;
esac