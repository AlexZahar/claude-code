#!/bin/bash
# Memory Subagent Request Script
# Queues memory operations for batch processing
# Usage: memory-subagent-request.sh "message" "priority"

set -e

# Configuration
MEMORY_QUEUE_DIR="$HOME/.claude/memory-queue"
GRAPHITI_HOOK="$HOME/.claude/graphiti-hook.sh"
DEBUG_LOG="$HOME/.claude/memory-subagent.log"

# Ensure queue directory exists
mkdir -p "$MEMORY_QUEUE_DIR"

# Function to log debug messages
log_debug() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [MEMORY-SUBAGENT] $*" >> "$DEBUG_LOG"
}

# Get arguments
MESSAGE="$1"
PRIORITY="${2:-normal}"

if [ -z "$MESSAGE" ]; then
    log_debug "Error: No message provided"
    exit 1
fi

log_debug "Queueing memory request: $MESSAGE (priority: $PRIORITY)"

# Smart filtering - ignore trivial operations
if echo "$MESSAGE" | grep -qE "^\[File (edited|created)\].*\.(log|tmp|pyc|map|cache)$"; then
    log_debug "Skipping trivial file: $MESSAGE"
    exit 0
fi

if echo "$MESSAGE" | grep -qE "^\[Command\].*\b(ls|cd|pwd|echo|cat|which|clear)\b"; then
    log_debug "Skipping trivial command: $MESSAGE"
    exit 0
fi

# Create unique queue file
TIMESTAMP=$(date '+%Y%m%d_%H%M%S_%N')
QUEUE_FILE="$MEMORY_QUEUE_DIR/${PRIORITY}_${TIMESTAMP}.queue"

# Write to queue file
cat > "$QUEUE_FILE" << EOF
{
    "timestamp": "$(date -u '+%Y-%m-%d %H:%M:%S UTC')",
    "message": "$MESSAGE",
    "priority": "$PRIORITY",
    "session_id": "${CLAUDE_SESSION_ID:-unknown}",
    "tmux_session": "${TMUX_SESSION:-$(tmux display-message -p '#S' 2>/dev/null || echo 'none')}"
}
EOF

log_debug "Queued to: $QUEUE_FILE"

# For high priority, try immediate processing
if [ "$PRIORITY" = "high" ]; then
    log_debug "High priority - attempting immediate processing"
    if command -v timeout >/dev/null 2>&1; then
        timeout 5 "$GRAPHITI_HOOK" add "$MESSAGE" >/dev/null 2>&1 &
    else
        "$GRAPHITI_HOOK" add "$MESSAGE" >/dev/null 2>&1 &
    fi
fi

# Return success immediately (non-blocking)
exit 0