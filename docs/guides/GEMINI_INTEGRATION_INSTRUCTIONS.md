# GEMINI CLI INTEGRATION INSTRUCTIONS FOR CLAUDE CODE

## 🎯 CORE PRINCIPLE: ANALYZE BEFORE IMPLEMENTING

### AUTOMATIC TRIGGERS - Use Gemini when user says:

#### 1. FEATURE REQUESTS (Most Important!)
When user says any of these, ALWAYS analyze first:
- "Add [feature]"
- "Implement [feature]"
- "Create [component]"
- "Build [functionality]"
- "Make a [thing]"
- "I need [feature]"
- "Can you add [feature]"

**REQUIRED STEPS BEFORE CODING:**
```bash
# 1. Check if it exists
gemini -p "@src/ Is there existing code for [feature]?"

# 2. Find similar patterns
HOOK_TYPE=feature ~/.claude/gemini-hooks.sh "[feature]"

# 3. Plan architecture
HOOK_TYPE=architecture ~/.claude/gemini-hooks.sh "[feature]"
```

#### 2. ANALYSIS REQUESTS
- "What is this?" → `HOOK_TYPE=overview ~/.claude/gemini-hooks.sh`
- "How does X work?" → `HOOK_TYPE=feature ~/.claude/gemini-hooks.sh "X"`
- "Explain the architecture" → `HOOK_TYPE=codebase ~/.claude/gemini-hooks.sh`
- "Show me dependencies" → `HOOK_TYPE=dependencies ~/.claude/gemini-hooks.sh`

#### 3. SEARCH REQUESTS
- "Find X" → `gemini -p "@src/ Find all instances of X"`
- "Where is Y used?" → `gemini -p "@src/ Find all usages of Y"`
- "What uses Z?" → `gemini -p "@src/ What depends on Z"`

#### 4. QUALITY CHECKS
- "Is this secure?" → `HOOK_TYPE=security ~/.claude/gemini-hooks.sh`
- "Check performance" → `HOOK_TYPE=performance ~/.claude/gemini-hooks.sh`
- "Review my code" → `HOOK_TYPE=review ~/.claude/gemini-hooks.sh`
- "What needs testing?" → Test coverage analysis

### PROJECT-SPECIFIC TRIGGERS

#### PROJECT_NAME Frontend
- "collections" → Analyze PIN security patterns first
- "reports" → Check report generation patterns
- "charts" → Review SmartChartRenderer usage
- "real-time" → Analyze Socket.IO patterns
- "dashboard" → Find existing dashboard components

#### Multi-Service (PROJECT_NAME)
- "API endpoint" → Check both backend services
- "authentication" → Trace auth across all services
- "file upload" → Review S3 patterns in all repos
- "AI/LLM" → Check AI usage in backend & python-api

### WORKFLOW EXAMPLES

#### Example 1: User wants to add a feature
**User**: "Add user notifications"

**Claude MUST**:
1. `gemini -p "@src/ Is there existing notification code?"`
2. `HOOK_TYPE=feature ~/.claude/gemini-hooks.sh "notifications"`
3. `gemini -p "@src/ How are real-time updates handled?"`
4. `HOOK_TYPE=architecture ~/.claude/gemini-hooks.sh "user notifications"`
5. THEN propose implementation based on findings

#### Example 2: User wants to modify something
**User**: "Update the login flow"

**Claude MUST**:
1. `HOOK_TYPE=feature ~/.claude/gemini-hooks.sh "authentication"`
2. `gemini -p "@src/ What components use the login flow?"`
3. Check impact before making changes
4. THEN implement with full context

### REMEMBER:
1. **ALWAYS analyze before implementing**
2. **Use specific commands for specific requests**
3. **Let automatic hooks run (don't disable them)**
4. **When in doubt, run `/gemini-help`**
5. **For new features, ALWAYS check existing code first**

### SLASH COMMANDS AVAILABLE:
- `/gemini-overview` - Quick project overview
- `/gemini-analyze` - Full codebase analysis
- `/gemini-feature [name]` - Feature deep dive
- `/gemini-deps` - Dependency analysis
- `/gemini-find [pattern]` - Find code patterns
- `/gemini-architecture [feature]` - Plan new features
- `/gemini-security` - Security audit
- `/gemini-performance` - Performance check
- `/gemini-review` - Code review
- `/gemini-help` - Show all commands