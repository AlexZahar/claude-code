# Architecture Planning

Plan the architecture for a new feature. Usage:
- `/gemini-architecture "user authentication"`
- `/gemini-architecture "payment processing"`
- `/gemini-architecture "real-time notifications"`

```bash
# Get architecture recommendations for new feature
HOOK_TYPE=architecture ~/.claude/gemini-hooks.sh "[FEATURE_NAME]"

# Or ask directly
gemini -p "@src/ How should I architect [FEATURE]? Consider existing patterns, suggest file structure, identify reusable components"
```

Provides:
- Best architecture approach
- File structure suggestions
- Existing patterns to follow
- Reusable components to leverage
- Integration points
- Data flow design
- Security considerations