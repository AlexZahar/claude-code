---
allowed-tools: Bash
description: Run comprehensive security audit
argument-hint: [path] (optional)
---

# Security Audit Results

!`if [ -n "$ARGUMENTS" ]; then
    gemini -p "@$ARGUMENTS Check for: SQL injection, XSS, exposed secrets, unsafe dependencies, missing auth checks, CSRF, OWASP Top 10"
else
    HOOK_TYPE=security ~/.claude/gemini-hooks.sh
fi`