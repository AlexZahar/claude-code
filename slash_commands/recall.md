# /recall - Search Your Memories

Search through your Graphiti knowledge graph for relevant memories.

## Usage
When the user invokes `/recall [query]`, you should:

1. Search for memories related to the query:
   ```bash
   /Users/USERNAME/.claude/graphiti-hook.sh search "[query]"
   ```

2. Present the results in a helpful format

## Examples
- `/recall authentication bug` → Search for all memories about authentication bugs
- `/recall performance` → Find all performance-related discoveries
- `/recall redis` → Retrieve all memories mentioning Redis

If no query is provided, show recent memories:
```bash
/Users/USERNAME/.claude/graphiti-hook.sh recent 10
```