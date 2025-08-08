#!/bin/bash
# Simplified memory save script for Claude Task subagents
# This replaces the complex queue-based system with direct saves

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GRAPHITI_HOOK="$SCRIPT_DIR/graphiti-hook.sh"
LOG_FILE="$SCRIPT_DIR/logs/subagent-memory.log"

# Ensure log directory exists
mkdir -p "$SCRIPT_DIR/logs"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to save memory directly
save_memory() {
    local content="$1"
    local priority="${2:-normal}"
    
    log_message "Subagent saving memory (priority: $priority): ${content:0:100}..."
    
    # Save directly using graphiti-hook (no queue, no worker)
    if $GRAPHITI_HOOK add "$content"; then
        log_message "✅ Successfully saved memory"
        return 0
    else
        log_message "❌ Failed to save memory"
        return 1
    fi
}

# Function to batch save multiple memories
batch_save() {
    local batch_content="$1"
    local priority="${2:-normal}"
    
    log_message "Subagent batch saving memories (priority: $priority)"
    
    # Create a summarized memory from batch
    local summary="[Batch] $batch_content"
    
    save_memory "$summary" "$priority"
}

# Main execution
main() {
    local action="${1:-save}"
    local content="$2"
    local priority="${3:-normal}"
    
    if [ -z "$content" ]; then
        echo "Usage: $0 [save|batch] \"content\" [priority]"
        exit 1
    fi
    
    case "$action" in
        save)
            save_memory "$content" "$priority"
            ;;
        batch)
            batch_save "$content" "$priority"
            ;;
        *)
            echo "Unknown action: $action"
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"