# AI Code Review

Get an AI-powered code review of your changes:

```bash
# Review specific files
HOOK_TYPE=review ~/.claude/gemini-hooks.sh "[FILES]"

# Review recent changes
gemini -p "@modified-files Perform code review: bugs, logic errors, edge cases, performance, security"

# Review before commit
gemini -p "Review my staged changes for: correctness, performance, security, best practices"
```

Reviews for:
- Bugs and logic errors
- Missing edge cases
- Performance issues
- Security vulnerabilities
- Code style consistency
- Best practices
- Error handling
- Test coverage