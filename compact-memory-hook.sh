#!/bin/bash
# Compact Memory Hook for Claude Code
# ====================================
# This hook captures the compacted conversation summary and stores it as a memory
# Now runs AFTER the compact operation completes (PostToolUse)

GRAPHITI_HOOK="$HOME/.claude/graphiti-hook.sh"
DEBUG_LOG="$HOME/.claude/graphiti-debug.log"

# Function to log debug messages
log_debug() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [COMPACT] $*" >> "$DEBUG_LOG"
}

# Main logic
log_debug "Compact hook triggered (PostToolUse)"
log_debug "Tool Name: $TOOL_NAME"
log_debug "Tool Output length: ${#TOOL_OUTPUT}"
log_debug "Tool Output preview: ${TOOL_OUTPUT:0:500}..."

# Check if this is actually a Compact tool execution
if [ "$TOOL_NAME" = "Compact" ]; then
    log_debug "Detected Compact tool execution"
    
    # Extract the compacted summary from TOOL_OUTPUT
    # The TOOL_OUTPUT should contain the compacted conversation summary
    if [ -n "$TOOL_OUTPUT" ]; then
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Create memory with the compacted summary
        # Limit to reasonable length to avoid token issues
        summary="${TOOL_OUTPUT:0:3000}"
        memory="CONVERSATION COMPACTED [$timestamp]: $summary"
        
        log_debug "Storing compact summary (length: ${#memory})"
        
        # Add to Graphiti
        "$GRAPHITI_HOOK" add "$memory"
        
        # Also flush any pending batches
        $(which uv) run python $HOME/.claude/graphiti-batcher.py flush >/dev/null 2>&1
        
        echo "📝 Compacted conversation summary saved to memory"
    else
        log_debug "No output from Compact tool"
    fi
else
    log_debug "Not a Compact tool execution: TOOL_NAME='$TOOL_NAME'"
fi