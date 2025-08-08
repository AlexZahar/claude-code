# Gemini CLI Help

Available Gemini slash commands:

## Analysis Commands
- `/gemini-overview` - Quick project overview
- `/gemini-analyze` - Comprehensive codebase analysis
- `/gemini-feature [name]` - Analyze specific feature
- `/gemini-deps` - Dependency analysis

## Search Commands
- `/gemini-find [pattern]` - Find code patterns or usages
- `/gemini-architecture [feature]` - Plan architecture for new features

## Quality Commands
- `/gemini-security` - Security audit
- `/gemini-performance` - Performance analysis
- `/gemini-review` - AI code review

## Direct Gemini Usage
You can also use Gemini directly:
```bash
gemini -p "@src/ [YOUR QUESTION]"
```

## Examples
```bash
# Find all API calls
/gemini-find "API calls"

# Analyze authentication feature
/gemini-feature authentication

# Plan payment feature
/gemini-architecture "payment processing"

# Quick security check
/gemini-security
```

## Tips
- Use `/gemini-overview` when starting on a new project
- Run `/gemini-analyze` for deep architectural understanding
- Use `/gemini-find` before implementing to avoid duplication
- Run `/gemini-security` before deployments