#!/bin/bash
# Periodic flush script for Graphiti memory batcher
# Run this periodically to ensure batches are flushed

GRAPHITI_HOOK="$HOME/.claude/graphiti-hook.sh"
UV_PYTHON="$(which uv) run python"
BATCHER="$HOME/.claude/graphiti-batcher.py"
DEBUG_LOG="$HOME/.claude/graphiti-debug.log"

# Log debug message
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FLUSH] Running periodic flush" >> "$DEBUG_LOG"

# Check batcher status
status=$($UV_PYTHON "$BATCHER" status 2>&1)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FLUSH] Batcher status: $status" >> "$DEBUG_LOG"

# Attempt to flush
flush_result=$($UV_PYTHON "$BATCHER" flush 2>&1)

if [[ "$flush_result" == "Flushed:"* ]]; then
    summary="${flush_result#Flushed: }"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FLUSH] Flushing: $summary" >> "$DEBUG_LOG"
    
    # Add to graphiti
    "$GRAPHITI_HOOK" add "$summary"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FLUSH] Nothing to flush" >> "$DEBUG_LOG"
fi