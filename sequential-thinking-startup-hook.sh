#!/bin/bash
# Sequential Thinking Bridge Auto-Start Hook
# ==========================================
# This hook automatically starts the sequential-graphiti bridge when Claude Code starts

BRIDGE_SCRIPT="/Users/USERNAME/.claude/start-sequential-graphiti-bridge.sh"
LOG_FILE="/Users/USERNAME/.claude/sequential-thinking-startup.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Check if bridge management script exists
if [ ! -f "$BRIDGE_SCRIPT" ]; then
    log_message "Bridge script not found: $BRIDGE_SCRIPT"
    exit 0
fi

# Check if already running
if $BRIDGE_SCRIPT status > /dev/null 2>&1; then
    log_message "Sequential-Graphiti bridge already running"
else
    log_message "Starting Sequential-Graphiti bridge..."
    $BRIDGE_SCRIPT start >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        log_message "Sequential-Graphiti bridge started successfully"
    else
        log_message "Failed to start Sequential-Graphiti bridge"
    fi
fi

log_message "Sequential thinking integration ready"