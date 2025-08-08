# Security Audit

Run a comprehensive security audit:

```bash
# Full project security scan
HOOK_TYPE=security ~/.claude/gemini-hooks.sh

# Or analyze specific file/directory
gemini -p "@[PATH] Check for: SQL injection, XSS, exposed secrets, unsafe dependencies, missing auth checks, CSRF"
```

Checks for:
- OWASP Top 10 vulnerabilities
- Exposed secrets and API keys
- SQL injection risks
- XSS vulnerabilities
- Missing authentication checks
- CSRF protection
- Unsafe dependencies
- Security misconfigurations