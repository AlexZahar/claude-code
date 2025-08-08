- Allowed action: Saving current context as a memory to avoid repeated requests

# 🔍 CRITICAL: Check Serena MCP First for ALL Code Analysis

## ⛔ Code Search Priority:
1. **FIRST**: Check if Serena is available: `claude mcp list | grep serena`
2. **IF CONNECTED**: You MUST activate Serena for the current project
3. **IF NOT CONNECTED**: Use fallback tools and document the issue

## ⚠️ CRITICAL: Serena Connection ≠ Project Activation
**Just because Serena MCP is connected doesn't mean it's active for your project!**
- Serena needs **project-specific activation** for semantic understanding
- Without activation, it cannot provide code intelligence
- Hooks will block code tools until proper activation

## 📋 Mandatory Serena Workflow (When Connected):

### 1. Activate Serena immediately:
```bash
# STEP 1: Load instructions (required once per session)
/mcp__serena__initial_instructions

# STEP 2: Activate your current project (CRITICAL!)
mcp__serena__activate_project("/path/to/your/project")

# STEP 3: Verify activation
mcp__serena__get_current_config()
```

**🚨 IMPORTANT**: Replace `/path/to/your/project` with the actual project path!
**💡 TIP**: Without project activation, Serena cannot understand your codebase!

### 2. Use ONLY these tools for code:
- ✅ `mcp__serena__find_symbol` - Find classes, functions, methods by name
- ✅ `mcp__serena__search_for_pattern` - Search code patterns with context
- ✅ `mcp__serena__get_symbols_overview` - Understand file/directory structure
- ✅ `mcp__serena__find_referencing_symbols` - Find all usages of a symbol
- ✅ `mcp__serena__replace_symbol_body` - Edit functions/classes precisely

## ❌ NEVER use these for code when Serena is available:
- ❌ **Search** - Text matching lacks semantic understanding
- ❌ **Grep** - Missing code context and relationships
- ❌ **Read** - For code exploration (misses semantic context)
- ❌ **Glob + Read** - Inefficient compared to Serena's indexing
- ❌ **Agent tool** - Use Serena's specialized code tools instead

## 🛡️ Intelligent Hook Protection:
**Hooks automatically block code exploration tools when Serena is available:**
- ✅ **Blocks**: Read/Search/Grep/Glob for .js/.ts/.tsx/.py files
- ✅ **Allows**: Config files (.json/.md/.yml/.env)
- ✅ **Allows**: Dependencies (node_modules, .git, dist)
- ✅ **Smart**: Only blocks when Serena is actually connected

## 🚨 Only Use Fallback If Serena Fails:
- Hooks automatically allow fallback when Serena is disconnected
- Document why Serena isn't working in memory
- Try to fix Serena connection for next session

**Setup Guide**: See ~/.claude/SERENA_MCP_SETUP.md for configuration

# 📚 Use Context7 MCP for Documentation Searches

## ⚡ PREFER Context7 over WebSearch/WebFetch for:
- ✅ Framework documentation (React, Vue, Angular, etc.)
- ✅ API references and guides
- ✅ Library documentation
- ✅ Tutorial and how-to content
- ✅ Frequently accessed technical docs

## 🔧 Context7 MCP Tools:
- `mcp__context7-mcp__search_knowledge` - Search indexed documentation
- `mcp__context7-mcp__add_knowledge` - Index new documentation
- `mcp__context7-mcp__list_knowledge` - View all indexed docs
- `mcp__context7-mcp__get_knowledge` - Get specific doc by ID
- `mcp__context7-mcp__update_knowledge` - Update existing docs
- `mcp__context7-mcp__delete_knowledge` - Remove outdated docs

## 📋 Documentation Workflow:

### 1. Always search Context7 first:
```python
# Before: WebSearch("React hooks documentation")
# After: mcp__context7-mcp__search_knowledge("React hooks documentation")
```

### 2. If not found in Context7, fetch and index:
```python
# Step 1: Fetch documentation
response = WebFetch(url, "Extract main documentation content")

# Step 2: Index in Context7
mcp__context7-mcp__add_knowledge(
    title="React Hooks Documentation",
    content=response,
    metadata={
        "source": url,
        "technology": "React",
        "type": "official_docs",
        "version": "18.2"
    }
)
```

### 3. Benefits over WebSearch:
- 🚀 Instant access (no network delays)
- 🎯 Semantic search across docs
- 📦 Version-controlled documentation
- 🔒 No rate limits or scraping issues
- 💾 Persistent knowledge base

## 🚨 When to still use WebSearch:
- General web queries (non-documentation)
- Current events or news
- Finding documentation URLs initially
- Non-technical content

# 🎯 PROACTIVE ANALYSIS GUIDELINES FOR CLAUDE CODE

## When to Check Memories BEFORE Taking Action

**ALWAYS search memories first when users ask:**
- Questions about past work: "What did we do before?", "How did we solve X?"
- Debugging familiar issues: "This error looks familiar", "We've seen this before"
- Architecture questions: "How does X work?", "Show me the structure"
- Performance/security concerns: "Is this secure?", "Any performance issues?"
- Feature requests: "Add Y feature", "Implement Z functionality"

**Memory Search Pattern:**
```bash
# Search for relevant context before proceeding
~/.claude/graphiti-hook.sh search "[key terms from user request]"
```

## When to Use Gemini CLI BEFORE Taking Action

**ALWAYS run Gemini analysis for:**

### 🔍 Before Implementation Tasks
- **"Add [feature]"** → First check: `gemini -p "@. Is there existing code for [feature]?"`
- **"Implement [functionality]"** → First run: `HOOK_TYPE=architecture ~/.claude/gemini-hooks.sh "[functionality]"`
- **"Create [component]"** → First check: `gemini -p "@. Find similar [component] implementations"`
- **"Fix [issue]"** → First run: `gemini -p "@. Analyze codebase for [issue] patterns"`

### 🏗️ Before Architecture Changes
- **"Refactor [area]"** → First run: `HOOK_TYPE=codebase ~/.claude/gemini-hooks.sh "[area]"`
- **"Optimize [feature]"** → First run: `HOOK_TYPE=performance ~/.claude/gemini-hooks.sh`
- **"Update [system]"** → First check: `gemini -p "@. What components depend on [system]?"`

### 🔒 Before Security/Critical Operations
- **"Delete [file/component]"** → First run: `gemini -p "@. Find all usages of [file/component]"`
- **"Change [API/interface]"** → First run: `gemini -p "@. What depends on [API/interface]?"`
- **"Deploy/Release"** → First run: `HOOK_TYPE=security ~/.claude/gemini-hooks.sh`

### 📚 Before Providing Information
- **"Explain [feature]"** → First run: `HOOK_TYPE=feature ~/.claude/gemini-hooks.sh "[feature]"`
- **"How does [system] work?"** → First run: `gemini -p "@. Trace [system] data flow and architecture"`
- **"What's the structure?"** → First run: `HOOK_TYPE=overview ~/.claude/gemini-hooks.sh`

## Decision Tree for Proactive Analysis

```
User Request → 
├─ Asking about past? → Search memories first
├─ Implementing new? → Check duplicates with Gemini
├─ Changing existing? → Analyze impact with Gemini  
├─ Deleting/removing? → Find dependencies with Gemini
├─ Need explanation? → Run feature analysis with Gemini
└─ General question? → Search memories + overview with Gemini
```

## Universal Commands (Tech-Stack Agnostic)

### Memory Commands
```bash
# Search project memories
~/.claude/graphiti-hook.sh search "[technology/feature/error]"
~/.claude/graphiti-hook.sh recent 10

# Save discoveries
~/.claude/graphiti-hook.sh add "[Context]: [Discovery/Solution/Decision]"
```

### Gemini Analysis Commands  
```bash
# Project overview (any tech stack)
HOOK_TYPE=overview ~/.claude/gemini-hooks.sh

# Architecture analysis (any language)
HOOK_TYPE=codebase ~/.claude/gemini-hooks.sh

# Find existing code (any framework)
gemini -p "@. Is there existing code for [functionality]?"

# Dependency analysis (any ecosystem)
gemini -p "@. What depends on [component/file/API]?"

# Security audit (any technology)
HOOK_TYPE=security ~/.claude/gemini-hooks.sh

# Performance analysis (any platform)
HOOK_TYPE=performance ~/.claude/gemini-hooks.sh
```

## Automatic Triggers (Tech-Stack Agnostic)

When users say these phrases, Claude should automatically run analysis:

### Memory Triggers
- "We did this before" → `~/.claude/graphiti-hook.sh search "[task/technology]"`
- "Remember when" → `~/.claude/graphiti-hook.sh search "[context]"`
- "Last time we" → `~/.claude/graphiti-hook.sh recent 20`
- "How did we solve" → `~/.claude/graphiti-hook.sh search "[problem]"`

### Gemini Triggers  
- "What is this project?" → `HOOK_TYPE=overview ~/.claude/gemini-hooks.sh`
- "Add [X] feature" → `gemini -p "@. Check for existing [X] implementations"`
- "How does [Y] work?" → `HOOK_TYPE=feature ~/.claude/gemini-hooks.sh "[Y]"`
- "What uses [Z]?" → `gemini -p "@. Find all usages of [Z]"`
- "Is this secure?" → `HOOK_TYPE=security ~/.claude/gemini-hooks.sh`
- "Any performance issues?" → `HOOK_TYPE=performance ~/.claude/gemini-hooks.sh`
- "What needs refactoring?" → `HOOK_TYPE=codebase ~/.claude/gemini-hooks.sh`

## Best Practices

1. **Memory First**: Always search memories before providing answers about past work
2. **Analysis Before Action**: Use Gemini to understand before implementing
3. **Save Discoveries**: Capture important findings for future sessions
4. **Context Matters**: Include project/technology context in memory searches
5. **Be Thorough**: Better to over-analyze than break existing functionality

This ensures Claude Code provides informed, context-aware assistance regardless of technology stack.

## 🚀 Neo4j Auto-Initialization

Neo4j (required for memory system) starts automatically when you open Claude Code.

### First-Time Setup
If you haven't set up Neo4j yet, run once:
```bash
~/.claude/initialize-graphiti.sh
```

This will:
- Install Neo4j via Docker
- Configure it for Graphiti
- Set up Python dependencies
- Start Neo4j with auto-restart enabled

### Manual Controls
```bash
# Check if Neo4j is running
curl -s http://localhost:7474 || echo "Neo4j not running"

# Start Neo4j manually if needed
docker start neo4j

# View Neo4j logs
docker logs neo4j

# Check startup hook logs
tail -f ~/.claude/neo4j-startup.log
```

### How It Works
1. When Claude Code starts, the SessionStart hook runs `neo4j-startup-hook.sh`
2. The hook checks if Neo4j is running
3. If not running but Docker container exists, it starts it
4. If no container exists, it prompts to run the initialization script
5. Once running, memory system is fully operational

No manual intervention needed after initial setup!

# Gemini CLI Integration for Enhanced Code Analysis

## Overview
Claude Code is enhanced with Gemini CLI hooks that provide codebase-wide analysis capabilities. These hooks automatically run during various operations to provide context and prevent issues.

## Active Hooks

### 1. **Impact Analysis** (Pre-Edit)
- **When**: Before editing any file
- **Purpose**: Shows what depends on the file you're changing
- **Benefit**: Prevents breaking changes by showing all imports and usages

### 2. **Duplicate Detection** (Pre-Write)
- **When**: Before creating new code
- **Purpose**: Finds similar existing code
- **Benefit**: Avoids reinventing the wheel

### 3. **Quality & Consistency Check** (Post-Edit)
- **When**: After successful edits
- **Purpose**: Ensures code follows project patterns
- **Reviews**: Performance, security, error handling

### 4. **Delete Safety** (Pre-Delete)
- **When**: Before deleting files
- **Purpose**: Blocks deletion if dependencies exist
- **Benefit**: Prevents accidental breaking deletions

### 5. **Test Coverage** (Test Runs)
- **When**: Running test commands
- **Purpose**: Identifies gaps in test coverage
- **Output**: Missing tests, untested edge cases

### 6. **Commit Helper** (Git Commits)
- **When**: Running git commit
- **Purpose**: Suggests conventional commit messages
- **Format**: type(scope): description

## Manual Gemini Commands

### 🔬 Project Analysis (Start Here!)
```bash
# Quick overview - What is this project?
HOOK_TYPE=overview ~/.claude/gemini-hooks.sh

# Comprehensive codebase analysis
HOOK_TYPE=codebase ~/.claude/gemini-hooks.sh

# Analyze specific directory
HOOK_TYPE=codebase ~/.claude/gemini-hooks.sh "src/components"

# Deep dive into a feature
HOOK_TYPE=feature ~/.claude/gemini-hooks.sh "user authentication"

# Dependency analysis
HOOK_TYPE=dependencies ~/.claude/gemini-hooks.sh
```

### 🔍 Specific Analysis Commands
```bash
# Architecture overview
gemini -p "@src/ Explain the architecture and design patterns"

# Find all usages of a component/function
gemini -p "@src/ Find all usages of ComponentName"

# Security audit
gemini -p "@src/ Perform security audit focusing on OWASP top 10"

# Performance analysis
gemini -p "@src/ Identify performance bottlenecks and optimization opportunities"

# Migration planning
gemini -p "@src/ List files using pattern X that need migration to pattern Y"

# Code review
gemini -p "@modified-files Perform detailed code review"

# Architecture planning for new features
HOOK_TYPE=architecture ~/.claude/gemini-hooks.sh "user authentication feature"
```

## When Claude Should Use These Commands

### 🎯 Automatic Triggers (Claude will recognize these scenarios)

1. **"I'm new to this codebase"** → Run overview & codebase analysis
2. **"Explain how X feature works"** → Run feature analysis
3. **"I want to add Y feature"** → Check for duplicates, then architecture planning
4. **"What dependencies do we use?"** → Run dependency analysis
5. **"Is this secure?"** → Run security audit
6. **"Find performance issues"** → Run performance analysis
7. **"What needs refactoring?"** → Run codebase analysis + quality check
8. **"Can I delete this?"** → Automatic pre-delete hook will check
9. **"What's not tested?"** → Run test coverage analysis
10. **"Review my changes"** → Run code review

### 📋 Specific Phrases That Trigger Analysis

When users say these phrases, Claude should run Gemini analysis:

- **"What is this project about?"** → `HOOK_TYPE=overview ~/.claude/gemini-hooks.sh`
- **"Show me the architecture"** → `HOOK_TYPE=codebase ~/.claude/gemini-hooks.sh`
- **"How does [feature] work?"** → `HOOK_TYPE=feature ~/.claude/gemini-hooks.sh "[feature]"`
- **"Analyze dependencies"** → `HOOK_TYPE=dependencies ~/.claude/gemini-hooks.sh`
- **"Find security issues"** → `HOOK_TYPE=security ~/.claude/gemini-hooks.sh`
- **"Check performance"** → `HOOK_TYPE=performance ~/.claude/gemini-hooks.sh`
- **"What uses [component]?"** → `gemini -p "@src/ Find all usages of [component]"`
- **"Find similar code"** → `gemini -p "@src/ Find code similar to [description]"`
- **"What's outdated?"** → `HOOK_TYPE=migration ~/.claude/gemini-hooks.sh`

## When to Use Manual Commands

1. **Starting New Project**: First run overview, then codebase analysis
2. **Before Major Refactoring**: Run architecture analysis + impact check
3. **Adding New Features**: Use duplicate check + architecture planning
4. **Performance Issues**: Run performance analysis on specific areas
5. **Security Concerns**: Run full security audit
6. **Code Quality**: Request code review before commits
7. **Finding Patterns**: Search across entire codebase
8. **Debugging Issues**: Use feature analysis to understand data flow

## Hook Configuration

- **Config**: `~/.claude/hooks.json`
- **Logic**: `~/.claude/gemini-hooks.sh`
- **Guide**: `~/.claude/gemini-hooks-guide.md`

## Disable/Enable Hooks

```bash
# Disable temporarily
mv ~/.claude/hooks.json ~/.claude/hooks.json.disabled

# Re-enable
mv ~/.claude/hooks.json.disabled ~/.claude/hooks.json
```

## 🚀 Slash Commands for Gemini

Quick access to Gemini analysis via slash commands:

### Analysis Commands
- `/gemini-overview` - Quick project overview (what is this?)
- `/gemini-analyze` - Comprehensive codebase analysis
- `/gemini-feature [name]` - Deep dive into specific feature
- `/gemini-deps` - Analyze all dependencies

### Search & Planning
- `/gemini-find [pattern]` - Find code patterns or component usages
- `/gemini-architecture [feature]` - Plan architecture for new features

### Quality & Security
- `/gemini-security` - Run security audit
- `/gemini-performance` - Find performance bottlenecks
- `/gemini-review` - AI-powered code review

### Help
- `/gemini-help` - Show all available Gemini commands

### Usage Examples
```bash
# When starting on a project
/gemini-overview

# Before implementing login
/gemini-find "authentication"
/gemini-architecture "two-factor authentication"

# Before deployment
/gemini-security
/gemini-performance

# Analyzing a feature
/gemini-feature "shopping cart"
```

# Signal Notifications for Claude Code Sessions

## Auto-notification Setup
Claude Code will automatically send Signal notifications for:
- Session start (when you open a new chat)
- Task completions
- Permission requests for sensitive operations

## How to Enable
2. The integration will auto-detect and use your Signal setup

## Usage in Sessions
When starting a new session with Claude Code:
1. Neo4j automatically starts via SessionStart hook
2. Signal notifications are sent (if configured)
3. Memory system is ready to capture all work

No manual steps needed!

## Permission Requests
For sensitive operations, I'll ask permission via Signal:
- Database migrations
- Production deployments  
- File deletions
- System configuration changes

Reply Y to allow, N to deny.

# Memory System Integration

## 🧠 Graphiti Knowledge Graph - ALWAYS ACTIVE

Your coding sessions now have persistent memory via Graphiti (Neo4j backend). Memory is **automatically enabled** for all sessions.

### 🎯 Prerequisites
- **Neo4j must be running** for memory to work
- Neo4j starts automatically via SessionStart hook
- If not initialized, run: `~/.claude/initialize-graphiti.sh`

### 🚀 Optimized Performance (v2.0)
- **Smart Filtering**: Ignores trivial commands (ls, cd, pwd) and files (.pyc, .log, node_modules)
- **Intelligent Batching**: Groups operations within 30-second windows
- **Context Detection**: Identifies work type (tests, refactoring, features)
- **Meaningful Summaries**: "Refactored auth module (5 files)" vs "[File Edit] edited auth.js"
- **Reduced Load**: From 100+ to 5-10 memories/hour

### Automatic Memory Capture (✅ ENABLED)

**IMPORTANT: Memory hooks are now active and automatically capture significant changes**

The following are intelligently captured to your knowledge graph:
- **Significant File Edits**: Groups related changes, ignores trivial edits
- **Important Commands**: Git, npm, deploy commands (skips ls, cd, pwd)
- **Failed Operations**: Any command with non-zero exit code
- **Test & Build Results**: Captured when state changes
- **Git Operations**: Commits, merges, branch operations

**How it works:**
1. Hooks detect important events (file edits, commands, etc.)
2. Smart Python assessor evaluates importance (50ms, inline)
3. Important items queued for batch processing
4. Cron job saves batches to Graphiti every 15 minutes

### When to Manually Save Memories

Use natural language to save important context - system will queue and batch save automatically:

**Just say naturally:**
- "Remember this bug fix: JWT tokens were expiring due to timezone mismatch in token.service.js"
- "Save this decision: Switched from REST to GraphQL for better query efficiency"  
- "Note this performance issue: Found N+1 query problem in user.controller.js getAllUsers method"
- "Capture this learning: React 19 concurrent features require wrapping updates in startTransition"

**Claude should use the Task agent for complex memory saves (truly async)**

### IMPORTANT: Memory Operation Best Practices

**Lightweight system handles all memory operations with queue-based batching.**

When you request memory saves using natural language:
- ✅ Smart assessor evaluates importance instantly (50ms)
- ✅ Important items queued without blocking conversation
- ✅ Batch processing every 15 minutes via cron job
- ✅ 95% less RAM usage than subagent approach

**For complex content, use the reference file approach:**
- Long architectural analyses → Create markdown files, save short memory reference
- Comprehensive documentation → Document in files, memory points to them
- Multi-paragraph insights → Summary in memory, details in files

### CRITICAL: Automatic Chunking for Long Content

**Smart memory system automatically handles long content by breaking it into focused chunks!**

**How Auto-Chunking Works (Optimized 2025-08-07):**
1. **Content >2000 characters** triggers intelligent chunking (raised from 1000)
2. **Python sentence splitting** creates ~800 character focused chunks (doubled from 400)
3. **Non-blocking background processing** - returns immediately, saves async
4. **Each chunk saved separately** as individual memories in knowledge graph
5. **50% fewer chunks** due to larger size = faster processing

**Example Auto-Chunking:**
```
Input: "PROJECT_NAME RAG fix: resolved import error by upgrading llama-index-core from 0.12.50 to 0.12.52.post1. The upgrade fixed multiple test failures due to outdated API calls and deprecated method signatures. The fix involved updating dependency configurations..."

Output:
📝 Memory content long (1025 characters) - breaking into smaller memories
💾 Saving 3 smaller memories...
  📌 Memory 1/3: PROJECT_NAME RAG fix: resolved import error by upgrading llama-index-core...
  📌 Memory 2/3: The upgrade fixed multiple test failures due to outdated API calls...
  📌 Memory 3/3: All CI/CD pipelines now pass, enabling next phase of development...
✅ Completed: Saved 3 focused memories
```

**Benefits:**
- ✅ **No timeouts** - Each chunk stays under token limits
- ✅ **Better searchability** - Focused memories easier to find
- ✅ **Preserved context** - All information captured and linked
- ✅ **Automatic** - No user intervention required
- ✅ **Natural language preserved** - Just say "Remember..." as usual

### Programmatic Memory Usage (Queue-Based)

**Claude Code automatically queues memories when:**

1. **After /compact command**: Save session summary before compacting
   - System automatically captures conversation summary
   - Queued with normal priority for batch processing

2. **When user says "remember this"**: Save the current context
   - Smart assessor evaluates content importance
   - High-priority items queued immediately

3. **After fixing bugs**: Save the solution  
   - Bug fixes automatically detected as high-importance
   - Solution details captured and queued

4. **On important discoveries**: Save insights
   - Discovery patterns detected by smart assessor
   - Automatically prioritized and queued

**For complex saves, use the graphiti-memory-manager Task agent**

### Memory Search & Recall

```bash
# Search for specific topics
~/.claude/graphiti-hook.sh search "authentication"
~/.claude/graphiti-hook.sh search "performance issue"
~/.claude/graphiti-hook.sh search "bug fix"

# View recent activity
~/.claude/graphiti-hook.sh recent 20
```

### Slash Commands

- **/remember** - Save current context to memory
- **/recall [query]** - Search memories (or show recent if no query)
- **/compact** - Compacted conversation summary is automatically saved as memory after compacting

### Memory-Aware Responses

When users ask questions like:
- "What did we work on last week?"
- "Have we seen this error before?"
- "What was that solution we found?"
- "When did we change the auth system?"

**Always search memories first:**
```bash
~/.claude/graphiti-hook.sh search "[relevant keywords]"
```

### Session Best Practices

1. **Start of Session**: Check recent memories for context
   ```bash
   ~/.claude/graphiti-hook.sh recent 10
   ```

2. **During Work**: Let automatic capture handle routine edits

3. **Important Moments**: Manually save discoveries, decisions, solutions

4. **After Compact**: Compacted conversation summary is automatically saved as a memory

5. **Complex Problems**: Save step-by-step progress

### The Knowledge Graph Advantage

Your memories create relationships:
- Files relate to bugs they fixed
- Commands relate to their outcomes  
- Errors relate to their solutions
- Decisions relate to their context

Over time, this builds a powerful project knowledge base that grows smarter with every session.

## Performance Optimizations (Added 2025-07-18)

Memory system now includes smart filtering and batching:

1. **Smart Filtering**: Ignores trivial operations
   - Trivial commands: ls, cd, pwd, echo, cat, which, clear
   - Ignored file patterns: .pyc, .log, __pycache__, node_modules, .git

2. **Intelligent Batching**: Groups related operations
   - 30-second time windows
   - Context detection (test development, refactoring, feature work)
   - Meaningful summaries instead of individual logs

3. **Rate Limiting**: Reduced from 100+/hour to 5-10 meaningful memories/hour

4. **Automatic Compact Memory**: When you run `/compact`, the compacted conversation summary is automatically saved as a memory
   - Captures what was discussed and accomplished in the session
   - No manual intervention needed - happens automatically after compacting
   - Stored with timestamp for easy retrieval
   - Helps maintain continuity between sessions

Configuration: `~/.claude/memory-config.json`

# 🪝 COMPREHENSIVE HOOKS SYSTEM (FROM BOARDLENS)

## Overview of Active Hooks System

Claude Code uses a comprehensive hooks system that automatically enhances your workflow by running targeted analysis and checks at key moments. These hooks are **automatically active** and provide intelligent assistance without interrupting your flow.

## 🎯 Core Hook Types & Triggers

### 1. **SessionStart Hooks**
**Triggers**: When Claude Code starts
**Purpose**: Initialize development environment

```json
"SessionStart": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "/Users/USERNAME/.claude/boardlens-dev-startup-hook.sh"
      },
      {
        "type": "command", 
        "command": "/Users/USERNAME/.claude/mcp-session-hook.sh"
      }
    ]
  }
]
```

**What it does:**
- Starts Neo4j memory system
- Activates Serena MCP integration
- Loads PROJECT_NAME development context
- Configures multi-project environment

### 2. **PreToolUse Hooks** 
**Triggers**: Before Claude uses specific tools
**Purpose**: Prevent mistakes, provide guidance, run analysis

#### A. **Serena-First Code Search Protection**
```json
"matcher": "Grep|Search|Glob",
"hooks": [
  {
    "type": "command",
    "command": "HOOK_TYPE=wrong-tool /Users/USERNAME/.claude/serena-hooks.sh"
  }
]
```

**What it does:**
- **BLOCKS** Grep, Search, Glob tools for code search
- Forces Claude to use Serena MCP tools instead
- Provides specific instructions on proper Serena usage
- Only allows fallback tools if Serena is genuinely unavailable

#### B. **Pre-Edit Impact Analysis (Gemini)**
```json
"matcher": "Edit|MultiEdit",
"hooks": [
  {
    "type": "command",
    "command": "HOOK_TYPE=pre-edit /Users/USERNAME/.claude/gemini-hooks.sh"
  }
]
```

**What it does:**
- Analyzes what depends on the file before editing
- Shows all imports, usages, and potential breaking changes
- Prevents accidental breaking changes
- Suggests Serena tools for precise edits

#### C. **Pre-Write Duplicate Detection**
```json
"matcher": "Write",
"hooks": [
  {
    "type": "command", 
    "command": "HOOK_TYPE=pre-write /Users/USERNAME/.claude/gemini-hooks.sh"
  }
]
```

**What it does:**
- Scans codebase for similar existing functionality
- Prevents code duplication
- Suggests reusing existing components/functions
- Maintains consistent patterns

#### D. **Documentation Search Redirection**
```json
"matcher": "WebSearch|WebFetch",
"hooks": [
  {
    "type": "command",
    "command": "HOOK_TYPE=pre-websearch /Users/USERNAME/.claude/documentation-hooks.sh" 
  }
]
```

**What it does:**
- Detects documentation queries (React docs, API references, etc.)
- **BLOCKS** web search for documentation
- Redirects to Context7 MCP for better, curated results
- Provides specific Context7 usage instructions

### 3. **PostToolUse Hooks**
**Triggers**: After successful tool execution
**Purpose**: Capture results, run quality checks, save memories

#### A. **Post-Edit Quality Analysis**
```json
"matcher": "Edit|MultiEdit|Write",
"hooks": [
  {
    "type": "command",
    "command": "sh -c 'if echo \"$TOOL_OUTPUT\" | grep -q \"successfully\"; then HOOK_TYPE=post-edit /Users/USERNAME/.claude/gemini-hooks.sh; fi'"
  }
]
```

**What it does:**
- Reviews code for consistency with project patterns
- Checks performance, security, error handling
- Validates against established conventions
- Suggests improvements

#### B. **Automatic Memory Capture (✅ ACTIVE)**
```json
// Memory hooks are ACTIVE in settings.json PostToolUse section
// Automatically captures file edits and command executions
// Uses smart filtering to ignore trivial operations
```

**What it does:**
- Automatically saves significant file changes to memory
- Captures important command executions
- Filters out trivial operations (ls, cd, pwd, small edits)
- Builds project knowledge graph over time

#### C. **Command Result Capture (✅ ACTIVE)**
```json
// Command capture hooks are ACTIVE in settings.json
// Automatically captures non-trivial commands with exit codes
```

**What it does:**
- Captures important command executions
- Prioritizes failed commands (high priority memory)
- Ignores trivial commands (ls, cd, pwd, echo, cat, which, clear)
- Saves git operations, npm commands, deploy scripts

### 4. **Stop Hooks**
**Triggers**: When conversation ends
**Purpose**: Cleanup and helpful tips

```json
"Stop": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "echo \"💡 Tip: Use 'gemini -p' for analysis or '~/.claude/graphiti-hook.sh search' for memories!\""
      }
    ]
  }
]
```

### 5. **UserPromptSubmit Hooks** 
**Triggers**: On specific user commands
**Purpose**: Special command handling

```json
"matcher": "/compact",
"hooks": [
  {
    "type": "command",
    "command": "/Users/USERNAME/.claude/compact-memory-hook.sh"
  }
]
```

**What it does:**
- Automatically saves conversation summary to memory when you use `/compact`
- Preserves context between sessions
- No manual intervention needed

## 🛠️ Individual Hook System Details

### Serena Hooks (`serena-hooks.sh`)
**Purpose**: Enforce Serena-first approach for code operations

**Hook Types:**
- `wrong-tool`: **BLOCKS** Search/Grep tools, forces Serena usage
- `code-search`: Reminds about proper Serena tools
- `pre-edit`: Suggests Serena for precise symbol editing
- `project-start`: Guides through Serena project activation

**Key Features:**
- Prevents inefficient text-based search
- Enforces semantic code understanding
- Provides specific Serena command examples
- Logs usage reminders

### Memory Hooks (`graphiti-hook.sh`)
**Purpose**: Intelligent, automatic memory capture to knowledge graph

**Core Functions:**
```bash
# Add memories (with smart filtering)
~/.claude/graphiti-hook.sh add "Important discovery"

# Search memories
~/.claude/graphiti-hook.sh search "authentication bug"

# View recent activity
~/.claude/graphiti-hook.sh recent 20

# Async memory saving (non-blocking)
~/.claude/graphiti-hook.sh add_async "Complex content" normal
```

**Smart Filtering:**
- **Ignores**: Trivial commands (ls, cd, pwd), temp files, cache files
- **Captures**: Git operations, build commands, failed operations, significant file changes
- **Batches**: Groups related operations within 30-second windows
- **Prioritizes**: High priority for errors, normal for routine changes

**Context Detection:**
- Automatically detects project context from git repository
- Groups related file changes into meaningful summaries
- Identifies work patterns (testing, refactoring, feature development)

### Documentation Hooks (`documentation-hooks.sh`)
**Purpose**: Redirect documentation queries to Context7 MCP

**Detection Patterns:**
- Framework docs: "React documentation", "Vue API", "Next.js guide"
- Technical queries: "JavaScript how to", "Python tutorial"
- Official sites: "MDN", "developer.mozilla", "official docs"

**When Triggered:**
1. Analyzes the search query
2. Blocks WebSearch/WebFetch for documentation
3. Shows Context7 usage instructions
4. Logs the redirection to memory

**Example Output:**
```
🔍 DOCUMENTATION SEARCH DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Query: "React hooks documentation"
Tool Attempted: WebSearch

💡 RECOMMENDATION: Use Context7 MCP instead for better documentation results!

🎯 SUGGESTED CONTEXT7 COMMANDS:
   
   For framework docs:    Use ReadMcpResourceTool with context7 server
   For API references:    Use ListMcpResourcesTool to find available docs
   For specific guides:   Use context7's curated documentation database
```

### Gemini Analysis Hooks (`gemini-hooks.sh`)
**Purpose**: Automated codebase analysis with large context windows

**Hook Types & Functions:**

#### Pre-Edit Impact Analysis
```bash
impact_analysis() {
    local file="$1"
    echo "🔍 Analyzing impact of changes to $file..."
    gemini -p "@src/ What files and components depend on $file? List all imports and usages. Be specific about function names and potential breaking changes."
}
```

#### Duplicate Detection
```bash
duplicate_check() {
    local content="$1"
    echo "🔎 Checking for similar code..."
    gemini -p "@src/ Is there existing code similar to this? Focus on avoiding duplication: ${content:0:200}..."
}
```

#### Quality & Security Checks
```bash
quality_check() {
    local file="$1"
    echo "✅ Reviewing code quality..."
    gemini -p "@src/ Review $file for: 1) Consistency with project patterns 2) Performance issues 3) Security concerns 4) Missing error handling"
}

security_scan() {
    local file="$1"
    echo "🔒 Security scan for $file..."
    gemini -p "@$file Check for: SQL injection risks, XSS vulnerabilities, exposed secrets, unsafe dependencies, missing auth checks, CSRF protection"
}
```

## 🔧 Hook Configuration Files

### Main Configuration (`~/.claude/hooks.json`)
The central configuration file that defines all hook triggers and commands. Uses JSON format with matchers for different tools.

### Memory Configuration (`~/.claude/memory-config.json`)
Controls intelligent batching and filtering:

```json
{
  "batching": {
    "enabled": true,
    "window_seconds": 30,
    "min_batch_size": 2,
    "max_batch_size": 50
  },
  "filtering": {
    "min_file_change_lines": 5,
    "ignore_patterns": [
      "*.log", "*.tmp", "__pycache__", ".git", "node_modules"
    ],
    "trivial_commands": [
      "ls", "cd", "pwd", "echo", "cat", "which", "clear"
    ]
  },
  "importance_rules": {
    "high": ["git commit", "npm publish", "deploy", "migration", "hotfix"],
    "medium": ["test", "refactor", "feature", "npm install", "pip install"],
    "low": ["style", "typo", "format", "lint"]
  }
}
```

## 🚀 Advanced Hook Usage

### Manual Hook Testing
```bash
# Test individual hooks
HOOK_TYPE=pre-edit ~/.claude/gemini-hooks.sh
HOOK_TYPE=wrong-tool ~/.claude/serena-hooks.sh
HOOK_TYPE=pre-websearch ~/.claude/documentation-hooks.sh

# Test memory operations
~/.claude/graphiti-hook.sh add "Test memory"
~/.claude/graphiti-hook.sh search "test"
```

### Hook Customization
Edit individual hook scripts to:
- Adjust detection patterns
- Modify analysis prompts
- Change filtering rules
- Add new hook types

### Debugging Hooks
```bash
# Check hook logs
tail -f ~/.claude/graphiti-hook.log
tail -f ~/.claude/serena-hooks.log
tail -f ~/.claude/documentation-hook.log

# Verify hook configuration
cat ~/.claude/hooks.json | jq .

# Test hook permissions
ls -la ~/.claude/*hooks.sh
```

## 🎯 Hook Benefits Summary

1. **Automatic Quality Assurance**: Every edit gets impact analysis and quality checks
2. **Prevents Common Mistakes**: Blocks wrong tools, prevents code duplication
3. **Builds Project Knowledge**: Automatically captures and indexes all work
4. **Enforces Best Practices**: Guides toward proper tool usage (Serena, Context7)
5. **Non-Blocking Intelligence**: All analysis runs in background without delays
6. **Context-Aware**: Understands project patterns and maintains consistency
7. **Continuous Learning**: Memory system gets smarter with every session

The hooks system transforms Claude Code from a reactive tool into a proactive development partner that anticipates needs, prevents mistakes, and builds institutional knowledge automatically.