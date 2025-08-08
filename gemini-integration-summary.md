# Gemini CLI + Claude Code Integration Summary

## ✅ What's Been Set Up

### 1. **Automatic Hooks** (Run automatically)
- **Pre-Edit**: Shows file dependencies before changes
- **Pre-Write**: Detects duplicate code before creation
- **Post-Edit**: Reviews code quality after changes
- **Pre-Delete**: Blocks unsafe file deletions
- **Test Runs**: Analyzes test coverage
- **Git Commits**: Suggests commit messages

### 2. **Manual Analysis Commands**
Run these using `HOOK_TYPE=X ~/.claude/gemini-hooks.sh`:
- `overview` - Quick project summary
- `codebase` - Full architecture analysis
- `feature` - Deep dive into features
- `dependencies` - Dependency audit
- `security` - Security scanning
- `performance` - Performance analysis
- `architecture` - Plan new features
- `review` - Code review

### 3. **Slash Commands** (Quick access)
Located in `~/.claude/slash-commands/`:
- `/gemini-overview` - What is this project?
- `/gemini-analyze` - Full codebase analysis
- `/gemini-feature [name]` - Feature deep dive
- `/gemini-deps` - Dependency analysis
- `/gemini-find [pattern]` - Find code patterns
- `/gemini-architecture [feature]` - Plan features
- `/gemini-security` - Security audit
- `/gemini-performance` - Performance check
- `/gemini-review` - Code review
- `/gemini-help` - Show all commands

## 📁 File Locations

- **Hooks Config**: `~/.claude/hooks.json`
- **Hook Logic**: `~/.claude/gemini-hooks.sh`
- **Slash Commands**: `~/.claude/slash-commands/`
- **Documentation**: `~/.claude/CLAUDE.md`
- **Quick Reference**: `~/.claude/gemini-hooks-quickref.md`

## 🎯 When Claude Uses Gemini Automatically

Claude recognizes these phrases and runs appropriate analysis:
- "What is this project?" → Overview
- "How does X work?" → Feature analysis
- "Find uses of Y" → Usage search
- "Is this secure?" → Security audit
- "Check performance" → Performance analysis
- "What's not tested?" → Coverage analysis

## 💡 Best Practices

1. **Start new projects** with `/gemini-overview`
2. **Before implementing**, use `/gemini-find` to check existing code
3. **Plan features** with `/gemini-architecture`
4. **Before commits**, run `/gemini-review`
5. **Before deployment**, run `/gemini-security`

## 🔧 Customization

- Edit hooks: `~/.claude/hooks.json`
- Modify logic: `~/.claude/gemini-hooks.sh`
- Add slash commands: Create `.md` files in `~/.claude/slash-commands/`

## 🚫 Disable/Enable

```bash
# Disable
mv ~/.claude/hooks.json ~/.claude/hooks.json.disabled

# Re-enable
mv ~/.claude/hooks.json.disabled ~/.claude/hooks.json
```