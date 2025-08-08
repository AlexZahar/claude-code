#!/bin/bash
# Multi-MCP Setup and Configuration Manager for Claude Code
# Switches between individual MCP servers and Multi-MCP proxy

SETTINGS_FILE="$HOME/.claude/settings.json"
MULTI_MCP_SETTINGS="$HOME/.claude/settings-multi-mcp.json"
BACKUP_DIR="$HOME/.claude/settings-backups"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Create timestamped backup
backup_settings() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/settings-$timestamp.json"
    
    if [ -f "$SETTINGS_FILE" ]; then
        cp "$SETTINGS_FILE" "$backup_file"
        echo "✅ Settings backed up to: $backup_file"
        return 0
    else
        echo "❌ No settings file found to backup"
        return 1
    fi
}

# Switch to Multi-MCP configuration
enable_multi_mcp() {
    echo "🔄 Switching to Multi-MCP proxy configuration..."
    
    # Backup current settings
    backup_settings || return 1
    
    # Check if Multi-MCP service is running
    if ! ~/.claude/multi-mcp-service.sh status | grep -q "✅ Running"; then
        echo "🚀 Starting Multi-MCP service..."
        ~/.claude/multi-mcp-service.sh start || {
            echo "❌ Failed to start Multi-MCP service"
            return 1
        }
    fi
    
    # Copy Multi-MCP settings
    if [ -f "$MULTI_MCP_SETTINGS" ]; then
        cp "$MULTI_MCP_SETTINGS" "$SETTINGS_FILE"
        echo "✅ Multi-MCP configuration activated"
        echo "📋 Configuration:"
        echo "   - All MCP servers accessed via proxy at http://127.0.0.1:8080/sse"
        echo "   - Memory sharing enabled across multiple Claude Code instances"
        echo "   - Auto-start Multi-MCP service on Claude Code session start"
        return 0
    else
        echo "❌ Multi-MCP settings file not found: $MULTI_MCP_SETTINGS"
        return 1
    fi
}

# Restore original settings (disable Multi-MCP)
disable_multi_mcp() {
    echo "🔄 Switching back to individual MCP servers..."
    
    # Find most recent backup (excluding multi-mcp backups)
    local latest_backup=$(ls -1t "$BACKUP_DIR"/settings-*.json 2>/dev/null | head -1)
    
    if [ -n "$latest_backup" ] && [ -f "$latest_backup" ]; then
        # Create backup of current Multi-MCP settings
        backup_settings
        
        # Restore original settings
        cp "$latest_backup" "$SETTINGS_FILE"
        echo "✅ Original settings restored from: $latest_backup"
        
        # Stop Multi-MCP service
        echo "🛑 Stopping Multi-MCP service..."
        ~/.claude/multi-mcp-service.sh stop
        
        echo "📋 Configuration:"
        echo "   - Individual MCP servers will be spawned per Claude Code instance"  
        echo "   - Multi-MCP proxy service stopped"
    else
        echo "❌ No backup settings found to restore"
        echo "You may need to manually configure your MCP servers"
        return 1
    fi
}

# Show current configuration status
status() {
    echo "📊 Multi-MCP Configuration Status:"
    echo
    
    # Check if current settings use Multi-MCP
    if [ -f "$SETTINGS_FILE" ] && grep -q "multi-mcp-proxy" "$SETTINGS_FILE"; then
        echo "  Configuration: ✅ Multi-MCP Proxy Mode"
        echo "  Settings: Using shared MCP proxy"
        
        # Check service status
        if ~/.claude/multi-mcp-service.sh status | grep -q "✅ Running"; then
            echo "  Service: ✅ Multi-MCP proxy running"
            echo "  Endpoint: http://127.0.0.1:8080/sse"
        else
            echo "  Service: ❌ Multi-MCP proxy not running"
            echo "  ⚠️  Start with: ~/.claude/multi-mcp-service.sh start"
        fi
    else
        echo "  Configuration: ⚙️  Individual MCP Servers Mode"
        echo "  Settings: Each Claude Code instance spawns own MCP servers"
        
        # Check if service is still running (should be stopped)
        if ~/.claude/multi-mcp-service.sh status | grep -q "✅ Running"; then
            echo "  Service: ⚠️  Multi-MCP proxy still running (not needed)"
            echo "  💡 Stop with: ~/.claude/multi-mcp-service.sh stop"
        else
            echo "  Service: ✅ Multi-MCP proxy stopped (as expected)"
        fi
    fi
    
    echo
    echo "Available backups:"
    ls -1t "$BACKUP_DIR"/settings-*.json 2>/dev/null | head -5 | while read backup; do
        local timestamp=$(basename "$backup" | sed 's/settings-//' | sed 's/.json//')
        echo "  - $backup ($(date -r "$backup" '+%Y-%m-%d %H:%M:%S'))"
    done || echo "  No backups found"
}

# Test Multi-MCP configuration
test_config() {
    echo "🧪 Testing Multi-MCP Configuration..."
    echo
    
    # Check if service is running
    if ! ~/.claude/multi-mcp-service.sh status | grep -q "✅ Running"; then
        echo "❌ Multi-MCP service is not running"
        echo "Start with: ~/.claude/multi-mcp-service.sh start"
        return 1
    fi
    
    # Test endpoints
    ~/.claude/multi-mcp-service.sh test
    
    # Check memory usage
    echo
    echo "Current memory usage:"
    local mcp_count=$(ps aux | grep -E "(mcp|serena)" | grep -v grep | wc -l)
    local mcp_memory=$(ps aux | grep -E "(mcp|serena)" | grep -v grep | awk '{mem+=$6} END {print mem/1024}')
    echo "  MCP Processes: $mcp_count"
    echo "  MCP Memory: ${mcp_memory} MB"
    
    if [ "$mcp_count" -lt 15 ] && [ "$(echo "$mcp_memory < 300" | bc -l 2>/dev/null || echo 1)" -eq 1 ]; then
        echo "  Status: ✅ Memory usage optimal"
    else
        echo "  Status: ⚠️  High memory usage - multiple Claude instances may be running"
    fi
}

# Memory usage comparison
memory_report() {
    echo "📊 Memory Usage Report:"
    echo
    
    local mcp_count=$(ps aux | grep -E "(mcp|serena)" | grep -v grep | wc -l)
    local mcp_memory=$(ps aux | grep -E "(mcp|serena)" | grep -v grep | awk '{mem+=$6} END {print mem/1024}')
    local claude_count=$(ps aux | grep claude | grep -v grep | wc -l)
    
    echo "Current Usage:"
    echo "  Claude Code Instances: $claude_count"
    echo "  MCP Processes: $mcp_count"
    echo "  MCP Memory: ${mcp_memory} MB"
    echo
    
    echo "Expected Usage:"
    if grep -q "multi-mcp-proxy" "$SETTINGS_FILE" 2>/dev/null; then
        echo "  Multi-MCP Mode: 8-12 processes, 150-300 MB"
        if [ "$mcp_count" -lt 15 ]; then
            echo "  Status: ✅ Within expected range"
        else
            echo "  Status: ⚠️  Above expected range"
        fi
    else
        echo "  Individual Mode: 8-12 processes per Claude instance"
        local expected_processes=$((claude_count * 10))
        echo "  Expected: ~$expected_processes processes"
        if [ "$mcp_count" -lt "$((expected_processes + 5))" ]; then
            echo "  Status: ✅ Within expected range for $claude_count instances"
        else
            echo "  Status: ⚠️  Above expected range"
        fi
    fi
}

# Main command handler
case "${1:-help}" in
    enable)
        enable_multi_mcp
        ;;
    disable)
        disable_multi_mcp
        ;;
    status)
        status
        ;;
    test)
        test_config
        ;;
    memory)
        memory_report
        ;;
    service)
        shift
        ~/.claude/multi-mcp-service.sh "$@"
        ;;
    *)
        echo "Usage: $0 {enable|disable|status|test|memory|service}"
        echo
        echo "Commands:"
        echo "  enable   - Switch to Multi-MCP proxy configuration"
        echo "  disable  - Switch back to individual MCP servers"
        echo "  status   - Show current configuration status"
        echo "  test     - Test Multi-MCP configuration and endpoints"
        echo "  memory   - Show memory usage report and analysis"
        echo "  service  - Pass commands to Multi-MCP service (start|stop|restart|logs)"
        echo
        echo "Multi-MCP Setup Manager for Claude Code"
        echo "Enables sharing MCP servers across multiple Claude Code instances"
        echo "Prevents memory leaks by eliminating duplicate MCP server processes"
        ;;
esac