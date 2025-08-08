#!/bin/bash
# Script to deprecate the Python background worker system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/deprecated-memory-system-$(date +%Y%m%d)"

echo "🔄 Deprecating Python worker-based memory system..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Stop the Python worker if running
echo "Stopping Python worker process..."
pkill -f "memory-background-worker.py" || echo "Worker not running"

# Backup old files
echo "Backing up deprecated files to $BACKUP_DIR..."
[ -f "$SCRIPT_DIR/memory-background-worker.py" ] && mv "$SCRIPT_DIR/memory-background-worker.py" "$BACKUP_DIR/"
[ -f "$SCRIPT_DIR/memory-queue.jsonl" ] && mv "$SCRIPT_DIR/memory-queue.jsonl" "$BACKUP_DIR/"
[ -f "$SCRIPT_DIR/memory-worker.log" ] && mv "$SCRIPT_DIR/memory-worker.log" "$BACKUP_DIR/"

# Update memory-queue-manager.sh to remove worker functionality
if [ -f "$SCRIPT_DIR/memory-queue-manager.sh" ]; then
    echo "Updating memory-queue-manager.sh to remove worker code..."
    cp "$SCRIPT_DIR/memory-queue-manager.sh" "$BACKUP_DIR/memory-queue-manager.sh.backup"
    
    # Create simplified version that only does direct saves
    cat > "$SCRIPT_DIR/memory-queue-manager.sh" << 'EOF'
#!/bin/bash
# Simplified memory manager - direct saves only (no queue, no worker)
# Kept for backward compatibility - redirects to subagent save script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# For backward compatibility, handle old command format
case "$1" in
    queue)
        # Redirect to new subagent save
        shift
        exec "$SCRIPT_DIR/graphiti-subagent-save.sh" save "$@"
        ;;
    status|start|stop|start_worker)
        echo "⚠️  Worker commands are deprecated. Memory saves now use Claude Task subagents."
        echo "No worker process needed - memories are saved directly."
        exit 0
        ;;
    *)
        echo "Usage: $0 queue \"content\" [priority]"
        echo "Note: This script is deprecated. Use graphiti-subagent-save.sh directly."
        exit 1
        ;;
esac
EOF
    chmod +x "$SCRIPT_DIR/memory-queue-manager.sh"
fi

# Backup current hooks.json and activate new one
if [ -f "$SCRIPT_DIR/hooks.json" ]; then
    echo "Backing up current hooks.json..."
    cp "$SCRIPT_DIR/hooks.json" "$BACKUP_DIR/hooks.json.backup"
fi

if [ -f "$SCRIPT_DIR/hooks-subagent.json" ]; then
    echo "Activating new subagent-based hooks..."
    cp "$SCRIPT_DIR/hooks-subagent.json" "$SCRIPT_DIR/hooks.json"
fi

# Create deprecation notice
cat > "$BACKUP_DIR/DEPRECATION_NOTICE.md" << 'EOF'
# Memory System Deprecation Notice

As of $(date +"%Y-%m-%d"), the Python worker-based memory system has been deprecated
in favor of Claude Task subagent-based saves.

## What Changed
- No more Python background worker process
- No more queue files
- Direct saves via graphiti-subagent-save.sh
- All memory operations use Claude's built-in Task subagents

## Deprecated Files (backed up here)
- memory-background-worker.py
- memory-queue.jsonl
- memory-worker.log
- Old hooks.json configuration

## New System
- graphiti-subagent-save.sh - Direct memory saves
- memory-subagent-request.sh - Hook integration
- Updated hooks.json - Uses subagent requests

## Migration Complete
The system now uses a simpler, more reliable approach with Claude Task subagents.
EOF

echo "✅ Deprecation complete!"
echo "📁 Old files backed up to: $BACKUP_DIR"
echo "🚀 New subagent-based memory system is now active"