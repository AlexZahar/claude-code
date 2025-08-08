# Find Code Patterns

Find specific patterns or usages across the codebase. Usage examples:
- `/gemini-find "useState hook"`
- `/gemini-find "API calls"`
- `/gemini-find "error handling"`

```bash
# Find all usages of a component/function/pattern
gemini -p "@src/ Find all usages of [PATTERN]"

# Find similar code to avoid duplication
gemini -p "@src/ Is there existing code similar to [DESCRIPTION]?"

# Find files implementing specific functionality
gemini -p "@src/ Which files implement [FUNCTIONALITY]?"

# Find anti-patterns
gemini -p "@src/ Find code that violates [BEST_PRACTICE]"
```

Examples:
```bash
gemini -p "@src/ Find all usages of SmartChartRenderer component"
gemini -p "@src/ Is there existing code for file upload with progress?"
gemini -p "@src/ Which files implement authentication?"
gemini -p "@src/ Find code that violates React best practices"
```