# /remember - Save Important Information to Memory

Save the current context, discovery, or important information to your Graphiti knowledge graph.

## Usage
When the user invokes `/remember`, you should:

1. Summarize the current context or recent work
2. Save it using a Task subagent:
   ```
   Task: Save memory "[Summary of what to remember]" with appropriate priority
   ```

## Examples
- After solving a bug: `/remember` → Task subagent saves "Fixed authentication bug by updating JWT validation in auth.middleware.js"
- After design decision: `/remember` → Task subagent saves "Decided to use Redis for session storage due to scalability requirements"
- After discovery: `/remember` → Task subagent saves "Found that the performance issue was caused by N+1 queries in user.service.js"

**The Task subagent automatically handles timeouts, error handling, and priority determination.**

Always acknowledge what will be saved to memory.