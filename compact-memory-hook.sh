#!/bin/bash
# Compact Memory Hook for Claude Code
# ====================================
# This hook captures the compacted conversation summary and stores it as a memory

GRAPHITI_HOOK="/Users/USERNAME/.claude/graphiti-hook.sh"
DEBUG_LOG="/Users/USERNAME/.claude/graphiti-debug.log"

# Function to log debug messages
log_debug() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [COMPACT] $*" >> "$DEBUG_LOG"
}

# Extract compact summary from the assistant's response
# When /compact is run, we need to wait and capture the assistant's response
extract_compact_summary() {
    # Since we trigger on "/compact", we need to wait for the assistant's response
    # The response will be in the next message after the user types /compact
    # For now, we'll save a placeholder that indicates a compact was run
    echo "Compact operation executed - conversation summary stored"
    return 0
}

# Main logic
log_debug "Compact hook triggered"
log_debug "Environment: USER_MESSAGE='${USER_MESSAGE:0:100}...', PROMPT='${PROMPT:0:100}...'"
log_debug "All env vars: $(env | grep -E 'USER_|PROMPT|CLAUDE|HOOK' | head -20)"

# When user types /compact, we detect it and save a memory
if [ "$USER_MESSAGE" = "/compact" ] || [ "$PROMPT" = "/compact" ]; then
    log_debug "Detected /compact command"
    
    # Create a memory indicating compact was triggered
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    memory="CONVERSATION COMPACTED [$timestamp]: Session compacted at user request. The compacted summary will be available in the next message."
    
    log_debug "Storing compact trigger: ${memory:0:200}..."
    
    # Add to Graphiti
    "$GRAPHITI_HOOK" add "$memory"
    
    # Also flush any pending batches
    /opt/homebrew/bin/uv run python /Users/USERNAME/.claude/graphiti-batcher.py flush >/dev/null 2>&1
else
    log_debug "Not a /compact command: USER_MESSAGE='$USER_MESSAGE', PROMPT='$PROMPT'"
fi