# Claude Subagent Memory Implementation Guide

## Overview
This document describes how Claude Code should internally handle memory saves using Task subagents.

## Pattern Recognition

### Manual Memory Triggers
When users say these phrases, Claude should spawn a Task subagent:

1. **Direct requests**:
   - "Remember this..."
   - "Save this to memory..."
   - "Store this finding..."
   - "Document this..."

2. **Discovery patterns**:
   - "I found that..."
   - "The issue was..."
   - "The solution is..."
   - "It turns out..."

3. **Decision patterns**:
   - "We decided to..."
   - "Let's go with..."
   - "The approach will be..."

### Automatic Memory Triggers
Claude should automatically save memories for:

1. **Bug fixes**: After successfully fixing an error
2. **Architecture decisions**: When making design choices
3. **Performance improvements**: After optimizations
4. **Integration patterns**: When connecting services
5. **Important discoveries**: Learning something new about the codebase

## Implementation Pattern

### For Manual Saves
```python
# When user says "Remember this: X"
def handle_memory_request(user_message):
    if matches_memory_pattern(user_message):
        content = extract_memory_content(user_message)
        priority = determine_priority(content)
        
        # Spawn subagent
        Task.spawn(
            description="Save memory to Graphiti",
            prompt=f"""
            Save this memory using the graphiti-subagent-save.sh script:
            
            Content: {content}
            Priority: {priority}
            
            Run: ~/.claude/graphiti-subagent-save.sh save "{content}" {priority}
            """
        )
```

### For Automatic Saves (from hooks)
```python
# Internal batching logic
class MemoryBatcher:
    def __init__(self):
        self.batch = []
        self.timer = None
        
    def add_to_batch(self, memory_data):
        self.batch.append(memory_data)
        
        # Start timer if not running
        if not self.timer:
            self.timer = Timer(30, self.flush_batch)
            
    def flush_batch(self):
        if not self.batch:
            return
            
        # Group similar operations
        grouped = self.group_by_context(self.batch)
        
        # Create summary
        summary = self.create_batch_summary(grouped)
        
        # Spawn subagent with batch
        Task.spawn(
            description="Save batched memories",
            prompt=f"""
            Save this batched memory using graphiti-subagent-save.sh:
            
            Summary: {summary}
            
            Run: ~/.claude/graphiti-subagent-save.sh batch "{summary}" normal
            """
        )
        
        # Clear batch
        self.batch.clear()
        self.timer = None
```

## Batching Rules

### What to Batch Together
- Multiple file edits in the same directory
- Related test file changes with source changes  
- Sequential commands for the same task
- Multiple config file updates

### What NOT to Batch
- Failed commands (save immediately with high priority)
- Edits more than 30 seconds apart
- Unrelated file changes
- Different priority levels

## Priority Determination

### Immediate Priority
- System crashes
- Data corruption
- Security vulnerabilities
- Service outages

### High Priority  
- Bug fixes
- Failed commands
- Breaking changes
- Performance bottlenecks

### Normal Priority
- Feature implementations
- Refactoring
- Documentation updates
- Regular development

### Low Priority
- Style changes
- Minor optimizations
- Typo fixes

## Example Flows

### Example 1: Manual Save
```
User: "Remember this: The authentication bug was caused by timezone mismatch in JWT tokens"
Claude: [Recognizes memory pattern]
Claude: [Spawns Task subagent]
Subagent: Runs `~/.claude/graphiti-subagent-save.sh save "Bug fix: Auth bug - JWT timezone mismatch" high`
Claude: "I've saved that important finding about the JWT timezone issue to memory."
```

### Example 2: Automatic Batch
```
Hook: File edited - auth.service.ts
Hook: File edited - auth.middleware.ts  
Hook: File edited - auth.test.ts
[30 seconds pass]
Claude: [Flushes batch]
Claude: [Spawns Task subagent]
Subagent: Runs `~/.claude/graphiti-subagent-save.sh batch "[Auth] Refactored authentication - 3 files, 67 lines" normal`
```

### Example 3: Failed Command
```
Hook: Command failed - npm test
Claude: [Immediate save, no batching]
Claude: [Spawns Task subagent]
Subagent: Runs `~/.claude/graphiti-subagent-save.sh save "[Failed] npm test - TypeError: Cannot read property 'user' of undefined" high`
```

## Testing the Implementation

### Test Case 1: Manual Memory
```bash
# User says: "Remember this test"
# Expected: Subagent spawned immediately
# Verify: Check logs/subagent-memory.log
```

### Test Case 2: Batched Edits
```bash
# Edit 3 files quickly
# Expected: Single batched memory after 30s
# Verify: Only one memory saved, not three
```

### Test Case 3: Mixed Priorities
```bash
# Normal edit + Failed command
# Expected: Failed command saved immediately, edit batched
# Verify: Two separate memories with different priorities
```

## Migration Checklist

- [ ] Remove Python background worker references
- [ ] Update hooks.json to use internal handlers
- [ ] Implement batching logic in Claude
- [ ] Test manual and automatic saves
- [ ] Monitor success rates
- [ ] Update documentation
- [ ] Deprecate old scripts

## Success Metrics

- Memory save success rate > 95%
- Average save time < 30 seconds
- No external Python processes
- Reduced code complexity by 70%
- All saves through Task subagents