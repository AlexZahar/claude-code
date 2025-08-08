# Feature Analysis

Analyze a specific feature in depth. Usage:
- `/gemini-feature authentication`
- `/gemini-feature shopping-cart`
- `/gemini-feature user-dashboard`

```bash
# Replace [FEATURE_NAME] with the feature to analyze
HOOK_TYPE=feature ~/.claude/gemini-hooks.sh "[FEATURE_NAME]"
```

This analyzes:
- Which files implement the feature
- All dependencies
- Data flow through the feature
- External services/APIs used
- Main components and functions
- Testing coverage
- Security considerations
- Performance characteristics
- Related features