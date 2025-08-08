# Gemini CLI Integration for Claude Code

## Overview
This integration enhances Claude Code with Gemini's large context window for codebase analysis.

## Installed Hooks

### 1. **Pre-Edit Impact Analysis**
- **Triggers:** Before editing files
- **Purpose:** Shows what depends on the file you're about to change
- **Example Output:** Lists all imports, function calls, and potential breaking changes

### 2. **Pre-Write Duplicate Detection**
- **Triggers:** Before creating new code
- **Purpose:** Prevents reinventing existing functionality
- **Example Output:** Shows similar code patterns already in the codebase

### 3. **Post-Edit Quality Check**
- **Triggers:** After successful edits
- **Purpose:** Ensures code follows project patterns
- **Reviews:** Consistency, performance, security, error handling

### 4. **Test Coverage Analysis**
- **Triggers:** When running tests
- **Purpose:** Identifies gaps in test coverage
- **Output:** Missing tests, untested edge cases, priority areas

## Manual Commands

Use these directly in Claude Code for deeper analysis:

```bash
# Architecture overview
gemini -p "@src/ Explain the architecture and key design patterns"

# Find all usages
gemini -p "@src/ Find all usages of ComponentName"

# Security audit
gemini -p "@src/ Perform a security audit focusing on OWASP top 10"

# Performance analysis
gemini -p "@src/ Identify performance bottlenecks and optimization opportunities"

# Migration helper
gemini -p "@src/ List all files using pattern X that need migration to pattern Y"

# Dependency graph
gemini -p "@src/ Show the dependency graph for module X"

# Code quality metrics
gemini -p "@src/ Analyze code quality: complexity, duplication, maintainability"
```

## Configuration

### Modify Hooks
Edit `/Users/USERNAME/.claude/hooks.json`

### Modify Hook Logic
Edit `/Users/USERNAME/.claude/gemini-hooks.sh`

### Disable Temporarily
```bash
mv ~/.claude/hooks.json ~/.claude/hooks.json.disabled
```

### Re-enable
```bash
mv ~/.claude/hooks.json.disabled ~/.claude/hooks.json
```

## Best Practices

1. **Let hooks run in background** - They provide valuable context
2. **Use manual commands** for deep analysis before major refactoring
3. **Trust the impact analysis** - It helps prevent breaking changes
4. **Review duplicate detection** - Saves time and maintains consistency

## Troubleshooting

- **Hooks not running:** Check if `gemini` CLI is in PATH
- **Slow performance:** Hooks timeout after 30s by default
- **Too much output:** Adjust `head -n` values in gemini-hooks.sh
- **False positives:** Refine prompts in the shell script

## Examples of Enhanced Workflow

### Refactoring with Confidence
```
1. Claude: "I'll refactor this authentication service"
2. Hook: Shows 15 files depend on auth service
3. Claude: Adjusts approach to maintain compatibility
```

### Avoiding Duplication
```
1. Claude: "I'll create a new date formatting utility"
2. Hook: Shows existing formatDate() in utils/dates.ts
3. Claude: Uses existing utility instead
```

### Comprehensive Testing
```
1. Claude: "I've implemented the new feature"
2. Claude: "Running tests..."
3. Hook: "UserProfile component lacks tests for error states"
4. Claude: Adds missing test cases
```