#!/bin/bash
# MCP Optimizer - Implements the winning hybrid solution
# Ensures single Multi-MCP proxy instance with automatic cleanup

set -e

PROXY_DIR="/Users/USERNAME/Projects/multi-mcp"
PROXY_CONFIG="claude-code-production.json"
PROXY_PORT="8080"
PROXY_PID_FILE="/tmp/multi-mcp-proxy.pid"
CLAUDE_SETTINGS="/Users/USERNAME/.claude/settings.json"
LOG_FILE="/Users/USERNAME/.claude/mcp-optimizer.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to kill all duplicate MCP processes
cleanup_duplicates() {
    log "🧹 Cleaning up duplicate MCP processes..."
    
    # Get the proxy PID if it exists
    PROXY_PID=""
    if [ -f "$PROXY_PID_FILE" ]; then
        PROXY_PID=$(cat "$PROXY_PID_FILE")
    fi
    
    # Count before cleanup
    BEFORE_COUNT=$(ps aux | grep -E "mcp-server|serena-mcp|sequential|puppeteer|figma|brave|context7" | grep -v grep | wc -l)
    
    # Kill all MCP processes except the proxy
    ps aux | grep -E "mcp-server|serena-mcp|sequential-thinking|mcp-puppeteer|figma-mcp|brave-search|context7-mcp|mcp-git" | \
        grep -v grep | \
        grep -v "$PROXY_PID" | \
        awk '{print $2}' | \
        xargs -r kill -9 2>/dev/null || true
    
    # Count after cleanup
    AFTER_COUNT=$(ps aux | grep -E "mcp-server|serena-mcp|sequential|puppeteer|figma|brave|context7" | grep -v grep | wc -l)
    
    log "  Cleaned up $((BEFORE_COUNT - AFTER_COUNT)) duplicate processes"
}

# Function to check if proxy is running and healthy
check_proxy_health() {
    if [ -f "$PROXY_PID_FILE" ]; then
        PID=$(cat "$PROXY_PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            # Process exists, check if it's responding
            if curl -s -f "http://127.0.0.1:$PROXY_PORT/mcp_servers" > /dev/null 2>&1; then
                return 0
            else
                log "⚠️  Proxy process exists but not responding"
                return 1
            fi
        else
            log "⚠️  Proxy PID file exists but process is dead"
            rm -f "$PROXY_PID_FILE"
            return 1
        fi
    fi
    return 1
}

# Function to start the Multi-MCP proxy
start_proxy() {
    log "🚀 Starting Multi-MCP proxy..."
    
    cd "$PROXY_DIR"
    
    # Start the proxy in background using virtual environment
    if [ -f "$PROXY_DIR/.venv/bin/python3" ]; then
        nohup "$PROXY_DIR/.venv/bin/python3" main.py --transport sse --host 127.0.0.1 --port "$PROXY_PORT" --config "$PROXY_CONFIG" > /Users/USERNAME/.claude/multi-mcp.log 2>&1 &
    else
        log "❌ Virtual environment not found at $PROXY_DIR/.venv"
        return 1
    fi
    PROXY_PID=$!
    echo $PROXY_PID > "$PROXY_PID_FILE"
    
    # Wait for proxy to be ready
    for i in {1..10}; do
        if curl -s "http://127.0.0.1:$PROXY_PORT/mcp_servers" > /dev/null 2>&1; then
            log "✅ Multi-MCP proxy started successfully (PID: $PROXY_PID)"
            return 0
        fi
        sleep 1
    done
    
    log "❌ Failed to start Multi-MCP proxy"
    return 1
}

# Function to ensure Claude settings use proxy-only configuration
update_claude_settings() {
    log "📝 Updating Claude settings to use proxy-only configuration..."
    
    # Backup current settings
    cp "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Create new settings with proxy-only configuration
    cat > "$CLAUDE_SETTINGS.tmp" << 'EOF'
{
  "enableAllProjectMcpServers": false,
  "mcpServers": {
    "multi-mcp-proxy": {
      "url": "http://127.0.0.1:8080/sse",
      "description": "Multi-MCP Proxy aggregating all MCP servers",
      "transport": {
        "type": "sse"
      }
    }
  }
}
EOF
    
    # Merge with existing settings (preserving other configurations)
    if command -v jq >/dev/null 2>&1; then
        jq -s '.[0] * .[1]' "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.tmp" > "$CLAUDE_SETTINGS.new"
        mv "$CLAUDE_SETTINGS.new" "$CLAUDE_SETTINGS"
        rm "$CLAUDE_SETTINGS.tmp"
    else
        mv "$CLAUDE_SETTINGS.tmp" "$CLAUDE_SETTINGS"
    fi
    
    log "✅ Claude settings updated"
}

# Function to monitor and maintain proxy health
monitor_proxy() {
    while true; do
        if ! check_proxy_health; then
            log "🔄 Proxy not healthy, restarting..."
            cleanup_duplicates
            start_proxy
        fi
        
        # Check for duplicate processes every 5 minutes
        DUPLICATE_COUNT=$(ps aux | grep -E "mcp-server|serena-mcp|sequential" | grep -v grep | grep -v "multi_mcp_proxy" | wc -l)
        if [ "$DUPLICATE_COUNT" -gt 5 ]; then
            log "⚠️  Found $DUPLICATE_COUNT MCP processes, cleaning up..."
            cleanup_duplicates
        fi
        
        sleep 300  # Check every 5 minutes
    done
}

# Main execution
main() {
    case "${1:-status}" in
        start)
            echo -e "${GREEN}=== MCP Optimizer - Starting ===${NC}"
            cleanup_duplicates
            if check_proxy_health; then
                log "✅ Multi-MCP proxy already running and healthy"
            else
                start_proxy
            fi
            update_claude_settings
            echo -e "${GREEN}✅ MCP optimization complete${NC}"
            ;;
            
        stop)
            echo -e "${YELLOW}=== MCP Optimizer - Stopping ===${NC}"
            if [ -f "$PROXY_PID_FILE" ]; then
                kill $(cat "$PROXY_PID_FILE") 2>/dev/null || true
                rm -f "$PROXY_PID_FILE"
            fi
            cleanup_duplicates
            echo -e "${GREEN}✅ All MCP processes stopped${NC}"
            ;;
            
        restart)
            $0 stop
            sleep 2
            $0 start
            ;;
            
        monitor)
            echo -e "${GREEN}=== MCP Optimizer - Monitor Mode ===${NC}"
            monitor_proxy
            ;;
            
        status)
            echo -e "${GREEN}=== MCP Status Report ===${NC}"
            echo ""
            
            if check_proxy_health; then
                echo -e "${GREEN}✅ Multi-MCP Proxy: Running${NC}"
                echo "   PID: $(cat $PROXY_PID_FILE)"
                echo "   Endpoint: http://127.0.0.1:$PROXY_PORT/sse"
                
                # Show available servers
                echo ""
                echo "Available MCP Servers:"
                curl -s "http://127.0.0.1:$PROXY_PORT/mcp_servers" 2>/dev/null | jq -r 'keys[]' | sed 's/^/   - /'
            else
                echo -e "${RED}❌ Multi-MCP Proxy: Not running${NC}"
            fi
            
            echo ""
            echo "MCP Process Count:"
            TOTAL_COUNT=$(ps aux | grep -E "mcp|serena|sequential|puppeteer|figma|brave|context7" | grep -v grep | wc -l)
            echo "   Total: $TOTAL_COUNT processes"
            
            echo ""
            echo "Memory Usage:"
            MEMORY=$(ps aux | grep -E "mcp|serena|sequential|puppeteer|figma|brave|context7" | grep -v grep | awk '{sum+=$6} END {printf "%.1f", sum/1024}')
            echo "   Total: ${MEMORY} MB"
            ;;
            
        cleanup)
            echo -e "${YELLOW}=== MCP Optimizer - Cleanup ===${NC}"
            cleanup_duplicates
            echo -e "${GREEN}✅ Cleanup complete${NC}"
            ;;
            
        *)
            echo "Usage: $0 {start|stop|restart|status|monitor|cleanup}"
            echo ""
            echo "  start   - Start Multi-MCP proxy and cleanup duplicates"
            echo "  stop    - Stop all MCP processes"
            echo "  restart - Restart Multi-MCP proxy"
            echo "  status  - Show current MCP status"
            echo "  monitor - Run continuous monitoring (daemon mode)"
            echo "  cleanup - Remove duplicate MCP processes"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"