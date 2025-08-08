# /compact - Compact Conversation with Memory

Compact the conversation while automatically saving work summary to memory.

## Enhanced Behavior
When the user invokes `/compact`, you should:

1. **BEFORE compacting**, save a work summary to memory:
   ```bash
   /Users/USERNAME/.claude/graphiti-hook.sh add "Session Summary: [List key accomplishments, files edited, problems solved, decisions made]"
   ```

2. Then proceed with normal compacting behavior

## Example Memory Format
```
Session Summary (2025-07-17):
- Fixed authentication bug in auth.middleware.js
- Refactored user service to resolve N+1 queries
- Added Redis caching for session management
- Updated 5 test files for new auth flow
- Decision: Use JWT with 15-minute expiry
```

This ensures no context is lost between sessions!