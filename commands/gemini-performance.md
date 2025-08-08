# Performance Analysis

Analyze performance issues in the codebase:

```bash
# Full performance analysis
gemini -p "@src/ Identify performance bottlenecks: N+1 queries, unnecessary re-renders, large bundles, memory leaks"

# Analyze specific area
HOOK_TYPE=performance ~/.claude/gemini-hooks.sh "[FILE_OR_FEATURE]"
```

Checks for:
- N+1 query problems
- Unnecessary React re-renders
- Large bundle sizes
- Inefficient algorithms
- Memory leaks
- Blocking operations
- Missing optimizations (memoization, lazy loading)
- Database query performance