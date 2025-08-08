# Memory System Clarification & Configuration Guide

## ✅ Current State (As of 2025-08-07)

### 1. **Hooks Configuration Location**
- **CORRECT**: `~/.claude/settings.json` (user settings)
- **INCORRECT**: `~/.claude/hooks.json` (now deprecated/renamed)
- **Official docs**: https://docs.anthropic.com/en/docs/claude-code/hooks

### 2. **Memory System Status**
- ✅ Neo4j automatically starts via SessionStart hook
- ✅ Graphiti knowledge graph is functional
- ✅ Manual memory commands work (`~/.claude/graphiti-hook.sh`)
- ❌ Automatic memory capture hooks NOT configured
- ❌ `memory-subagent-request.sh` is a no-op (just outputs text)

### 3. **Available Memory Components**
- `graphiti-hook.sh` - Direct Python integration (blocking, but fast ~50ms)
- `memory-hook-lightweight.sh` - Queue-based hook (non-blocking)
- `graphiti-memory-manager` agent - Task agent for async operations
- `memory-queue-manager.sh` - Batch processing system
- `smart-memory-assessor.py` - Importance filtering

## 🔧 To Enable Automatic Memory Capture

Add these hooks to your `~/.claude/settings.json` in the PostToolUse section:

```json
{
  "hooks": {
    "PostToolUse": [
      // ... existing hooks ...
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "sh -c 'FILE=$(echo \"$TOOL_INPUT\" | jq -r .file_path 2>/dev/null); if [ -n \"$FILE\" ]; then HOOK_TYPE=file_edit /Users/USERNAME/.claude/memory-hook-lightweight.sh; fi'"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "sh -c 'HOOK_TYPE=command /Users/USERNAME/.claude/memory-hook-lightweight.sh'"
          }
        ]
      }
    ]
  }
}
```

## 📋 How Memory System Should Work

### For Claude Code (You):

1. **Simple memory saves** (< 1000 chars):
   ```bash
   ~/.claude/graphiti-hook.sh add "Memory content"
   ```

2. **Complex/long memory saves** (> 1000 chars):
   Use the Task agent:
   ```python
   Task(
       description="Save memory",
       prompt="Save this to Graphiti: [content]",
       subagent_type="graphiti-memory-manager"
   )
   ```

3. **Search memories**:
   ```bash
   ~/.claude/graphiti-hook.sh search "query"
   ~/.claude/graphiti-hook.sh recent 20
   ```

### For Automatic Capture:
- Hooks trigger on file edits and commands
- Smart assessor filters trivial operations
- Important changes queued for batch processing
- Cron job processes queue every 15 minutes

## ❌ Common Misconceptions

1. **"memory-subagent-request.sh triggers Task agents"** - FALSE
   - It just outputs text: "SUBAGENT_MEMORY_REQUEST: Please save..."
   - Claude must manually recognize and act on this

2. **"Hooks are in hooks.json"** - FALSE
   - Hooks must be in settings.json
   - hooks.json is not used by Claude Code

3. **"All memory saves use subagents"** - FALSE
   - Direct Python saves are fast enough for most cases
   - Only complex operations need Task agents

## ✅ Best Practices

1. **Use direct saves for simple memories** - Fast, synchronous
2. **Use Task agent for complex operations** - Truly async
3. **Let automatic hooks capture routine changes** - Non-blocking
4. **Search memories before implementing features** - Avoid duplication

## 🚀 Recommended Configuration

The optimal setup is:
1. Enable lightweight memory hooks in settings.json
2. Use direct graphiti-hook.sh for manual saves
3. Use Task agent only for heavy operations
4. Let queue manager handle batching

This provides the best balance of performance and functionality.