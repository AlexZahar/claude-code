# Gemini CLI + Claude Code Quick Reference

## 🤖 Automatic Hooks (No action needed)
| Event | What Happens |
|-------|-------------|
| Before Edit | Shows dependencies & impact |
| Before Write | Checks for duplicate code |
| After Edit | Reviews quality & patterns |
| Before Delete | Blocks if dependencies exist |
| Test Runs | Analyzes coverage gaps |
| Git Commit | Suggests commit message |

## 🛠️ Manual Commands (Run these yourself)

### Project Analysis Commands
```bash
# Quick project overview (what is this?)
HOOK_TYPE=overview /Users/USERNAME/.claude/gemini-hooks.sh

# Comprehensive codebase analysis
HOOK_TYPE=codebase /Users/USERNAME/.claude/gemini-hooks.sh

# Analyze specific directory
HOOK_TYPE=codebase /Users/USERNAME/.claude/gemini-hooks.sh "src/components"

# Deep dive into a feature
HOOK_TYPE=feature /Users/USERNAME/.claude/gemini-hooks.sh "authentication"

# Dependency analysis
HOOK_TYPE=dependencies /Users/USERNAME/.claude/gemini-hooks.sh
```

### Essential Commands
```bash
# What uses this component/function?
gemini -p "@src/ Find all usages of [ComponentName]"

# Architecture overview
gemini -p "@src/ Explain the architecture"

# Before implementing something new
gemini -p "@src/ Is there existing code for [feature description]?"

# Security check
gemini -p "@src/ Security audit for [specific area]"

# Performance check  
gemini -p "@src/ Find performance issues in [file/feature]"
```

### Advanced Analysis
```bash
# Cross-file refactoring impact
gemini -p "@src/ If I change [X], what else needs updating?"

# Find anti-patterns
gemini -p "@src/ Find code that violates React best practices"

# Test coverage gaps
gemini -p "@src/ @tests/ What critical paths lack tests?"

# API consistency
gemini -p "@src/api/ Are all endpoints consistent?"

# Bundle size analysis
gemini -p "@src/ What's contributing most to bundle size?"
```

### Multi-Repo Commands (PROJECT_NAME)
```bash
# Cross-service dependencies
gemini -p "@boardlens-*/src/ How do services communicate?"

# Duplicate logic check
gemini -p "@. Find duplicate business logic across repos"

# Full architecture
gemini -p "@. Explain the complete system architecture"
```

## 💡 Pro Tips

1. **Let hooks run** - They provide valuable context
2. **Use before major changes** - Run architecture analysis first
3. **Trust the warnings** - Especially delete safety checks
4. **Batch similar tasks** - Gemini excels at pattern finding

## ⚙️ Configuration

- Hooks: `~/.claude/hooks.json`
- Logic: `~/.claude/gemini-hooks.sh`
- Disable: `mv ~/.claude/hooks.json{,.disabled}`