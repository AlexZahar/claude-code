# Dependency Analysis

Analyze all project dependencies:

```bash
HOOK_TYPE=dependencies ~/.claude/gemini-hooks.sh
```

This checks:
- All direct dependencies and their purposes
- Unused dependencies
- Outdated packages with security issues
- Redundant packages that could be consolidated
- Bundle size impact of each dependency
- Multiple versions of same package