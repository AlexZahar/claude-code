---
allowed-tools: Bash
description: Search your Graphiti memory graph
argument-hint: [query] | recent
---

# Memory Search Results

!`if [ -n "$ARGUMENTS" ] && [ "$ARGUMENTS" != "recent" ]; then
    /Users/USERNAME/.claude/graphiti-hook.sh search "$ARGUMENTS"
else
    /Users/USERNAME/.claude/graphiti-hook.sh recent 10
fi`