#!/bin/bash
# Multi-MCP Proxy Service Manager
# Manages the Multi-MCP proxy as a background service for Claude Code

MULTI_MCP_DIR="/Users/zahar/Projects/multi-mcp"
CONFIG_FILE="claude-code-production.json"
PID_FILE="$HOME/.claude/multi-mcp.pid"
LOG_FILE="$HOME/.claude/multi-mcp.log"
SSE_PORT=8080
SSE_HOST="127.0.0.1"

# Check if Multi-MCP is running
is_running() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        else
            rm -f "$PID_FILE"
        fi
    fi
    return 1
}

# Start Multi-MCP service
start() {
    echo "🚀 Starting Multi-MCP proxy service..."
    
    if is_running; then
        echo "✅ Multi-MCP is already running (PID: $(cat "$PID_FILE"))"
        return 0
    fi
    
    # Change to Multi-MCP directory
    cd "$MULTI_MCP_DIR" || {
        echo "❌ Failed to change to Multi-MCP directory: $MULTI_MCP_DIR"
        return 1
    }
    
    # Start Multi-MCP in background
    nohup uv run main.py \
        --transport sse \
        --host "$SSE_HOST" \
        --port "$SSE_PORT" \
        --config "$CONFIG_FILE" \
        > "$LOG_FILE" 2>&1 &
    
    local pid=$!
    echo "$pid" > "$PID_FILE"
    
    # Wait a moment and check if it started successfully
    sleep 3
    if is_running; then
        echo "✅ Multi-MCP started successfully"
        echo "   PID: $pid"
        echo "   Endpoint: http://$SSE_HOST:$SSE_PORT/sse"
        echo "   Log: $LOG_FILE"
        return 0
    else
        echo "❌ Failed to start Multi-MCP"
        echo "Check log file: $LOG_FILE"
        return 1
    fi
}

# Stop Multi-MCP service
stop() {
    echo "🛑 Stopping Multi-MCP proxy service..."
    
    if ! is_running; then
        echo "✅ Multi-MCP is not running"
        return 0
    fi
    
    local pid=$(cat "$PID_FILE")
    
    # Try graceful shutdown first
    if kill "$pid" 2>/dev/null; then
        echo "⏳ Waiting for graceful shutdown..."
        for i in {1..10}; do
            if ! is_running; then
                echo "✅ Multi-MCP stopped successfully"
                return 0
            fi
            sleep 1
        done
        
        # Force kill if graceful shutdown failed
        echo "⚠️  Graceful shutdown failed, force killing..."
        kill -9 "$pid" 2>/dev/null
    fi
    
    rm -f "$PID_FILE"
    echo "✅ Multi-MCP stopped"
}

# Restart Multi-MCP service
restart() {
    echo "🔄 Restarting Multi-MCP proxy service..."
    stop
    sleep 2
    start
}

# Show Multi-MCP status
status() {
    echo "📊 Multi-MCP Proxy Status:"
    echo
    
    if is_running; then
        local pid=$(cat "$PID_FILE")
        echo "  Status: ✅ Running (PID: $pid)"
        echo "  Endpoint: http://$SSE_HOST:$SSE_PORT/sse"
        echo "  Config: $MULTI_MCP_DIR/$CONFIG_FILE"
        echo "  Log: $LOG_FILE"
        
        # Test endpoint
        if curl -s -f "http://$SSE_HOST:$SSE_PORT/mcp_servers" >/dev/null 2>&1; then
            echo "  Endpoint: ✅ Responding"
        else
            echo "  Endpoint: ❌ Not responding"
        fi
        
        # Show recent log entries
        echo
        echo "Recent log entries:"
        tail -5 "$LOG_FILE" 2>/dev/null || echo "  No log entries found"
    else
        echo "  Status: ❌ Not running"
    fi
}

# Show service logs
logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "📋 Multi-MCP Logs (last 50 lines):"
        echo "────────────────────────────────────────"
        tail -50 "$LOG_FILE"
    else
        echo "❌ No log file found: $LOG_FILE"
    fi
}

# Test MCP servers endpoint
test() {
    echo "🧪 Testing Multi-MCP proxy..."
    
    if ! is_running; then
        echo "❌ Multi-MCP is not running"
        return 1
    fi
    
    echo "Testing HTTP endpoints:"
    
    # Test server list endpoint
    echo -n "  /mcp_servers: "
    if curl -s -f "http://$SSE_HOST:$SSE_PORT/mcp_servers" >/dev/null; then
        echo "✅ OK"
    else
        echo "❌ Failed"
    fi
    
    # Test tools endpoint
    echo -n "  /mcp_tools: "
    if curl -s -f "http://$SSE_HOST:$SSE_PORT/mcp_tools" >/dev/null; then
        echo "✅ OK"
    else
        echo "❌ Failed"
    fi
    
    # Test SSE endpoint (just connection, not full SSE stream)
    echo -n "  /sse endpoint: "
    if curl -s -f --max-time 2 "http://$SSE_HOST:$SSE_PORT/sse" >/dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "⚠️  Cannot test SSE endpoint with curl"
    fi
}

# Main command handler
case "${1:-help}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    logs)
        logs
        ;;
    test)
        test
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|test}"
        echo
        echo "Commands:"
        echo "  start   - Start Multi-MCP proxy service"
        echo "  stop    - Stop Multi-MCP proxy service" 
        echo "  restart - Restart Multi-MCP proxy service"
        echo "  status  - Show service status and health"
        echo "  logs    - Show recent service logs"
        echo "  test    - Test proxy endpoints"
        echo
        echo "Multi-MCP Proxy Service for Claude Code"
        echo "Aggregates multiple MCP servers into single SSE endpoint"
        echo "Endpoint: http://$SSE_HOST:$SSE_PORT/sse"
        ;;
esac