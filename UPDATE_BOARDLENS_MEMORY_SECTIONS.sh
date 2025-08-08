#!/bin/bash

# Script to update memory sections in all BoardLens CLAUDE.md files
# This script replaces outdated memory documentation with corrected version

CORRECTED_MEMORY_SECTION='## 🧠 Memory System Integration

### Overview
Claude Code sessions have persistent memory via Graphiti knowledge graph backed by Neo4j. The system automatically captures significant changes, commands, and discoveries using intelligent filtering.

### Prerequisites ✅
- **Neo4j**: Automatically started via SessionStart hook  
- **Graphiti Core**: Direct Python integration (no MCP needed)
- **Smart Filtering**: Automatic importance assessment

### Working Memory Commands (TESTED)

#### Core Operations
```bash
# Search memories across all BoardLens projects
~/.claude/graphiti-hook.sh search "query terms"
~/.claude/graphiti-hook.sh search "technology patterns" 
~/.claude/graphiti-hook.sh search "integration flows"

# View recent activity  
~/.claude/graphiti-hook.sh recent 20

# Manual memory addition (subject to smart filtering)
~/.claude/graphiti-hook.sh add "Important discovery or decision"

# Memory subagent request (for complex content)
~/.claude/memory-subagent-request.sh "Content to save" high
```

#### Slash Commands
- `/remember` - Save current context to memory
- `/recall [query]` - Search memories (or show recent if no query)

### Automatic Memory Capture

#### What Gets Saved Automatically
- **Significant file changes** (>5 lines changed)
- **Failed commands** (non-zero exit codes)  
- **Git operations** (commits, merges, branch operations)
- **Build failures** and error resolutions
- **Cross-service integration patterns**

#### What Gets Filtered Out  
- **Routine navigation** (ls, cd, pwd commands)
- **Trivial edits** (formatting, typos <5 lines)
- **Temporary files** (.log, .tmp, cache files)
- **Cache operations** and routine maintenance

### Memory Usage

#### Common Memory Queries
- **Cross-Service**: "frontend backend integration", "API endpoints", "service communication"
- **Bug Fixes**: "error handling", "authentication issues", "performance problems"
- **Architecture**: "design decisions", "technology choices", "refactoring patterns"
- **Development**: "build issues", "deployment", "configuration"

### Manual Memory Usage

#### When to Save Memories Manually
- **Bug fixes and solutions**: "Remember this specific bug fix..."
- **Architecture decisions**: "Decided to use X technology because..."
- **Performance optimizations**: "Fixed performance issue by..."
- **Integration discoveries**: "Found that service A needs service B for..."

#### Natural Language Memory Saves
Just say naturally:
- "Remember this integration pattern: Frontend calls Backend which delegates to Python API"
- "Save this decision: Moved functionality to separate service for better isolation"  
- "Note this bug: Authentication fails due to token expiry timing"

### Memory Best Practices

#### Effective Memory Queries
✅ **Good**: "authentication flow between services"
✅ **Good**: "performance optimization patterns" 
✅ **Good**: "error handling strategies"

❌ **Too broad**: "authentication"
❌ **Too specific**: "line 42 in file.js"

#### Cross-Project Context
- Memories are **shared across all BoardLens repositories**
- Search from any project to find patterns in others
- Use project-specific and technology-specific keywords

### Memory System Architecture

```
Direct Integration (Current):
User Action → Hook Trigger → Smart Assessment → Direct Graphiti Save → Neo4j Storage

No queue manager or external workers required.
```

### Troubleshooting Memory

#### If Memory Search Fails
1. Check Neo4j status: `curl -s http://localhost:7474`
2. Verify script permissions: `ls -la ~/.claude/graphiti-hook.sh`
3. Check recent logs: `tail ~/.claude/graphiti-hook.log`'

# Files to update
FILES=(
    "/Users/USERNAME/Projects/project/project-python-api/CLAUDE.md"
    "/Users/USERNAME/Projects/project/project-rag/docs/implementation-history/CLAUDE.md"
    "/Users/USERNAME/Projects/project/landing-page/CLAUDE.md"
    "/Users/USERNAME/Projects/projecte_rag_chatbot/CLAUDE.md"
    "/Users/USERNAME/Projects/projecte_simple_rag/CLAUDE.md"
)

echo "Updating BoardLens CLAUDE.md memory sections..."

for file in "${FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "Processing: $file"
        
        # Create backup
        cp "$file" "$file.backup-$(date +%Y%m%d_%H%M%S)"
        
        # Use python to do complex text replacement
        python3 << EOF
import re

file_path = "$file"
with open(file_path, 'r') as f:
    content = f.read()

# Find memory system section and replace it
# Look for patterns like "Memory System", "memory", etc. and replace entire section
memory_patterns = [
    r'## 🧠 Memory System.*?(?=##\s+[^🧠]|\Z)',
    r'## Memory System.*?(?=##\s+|\Z)',
    r'### Memory.*?(?=###\s+|\Z)',
    r'# Memory Integration.*?(?=##\s+|\Z)'
]

corrected_section = '''$CORRECTED_MEMORY_SECTION'''

# Try each pattern
for pattern in memory_patterns:
    if re.search(pattern, content, re.DOTALL | re.IGNORECASE):
        content = re.sub(pattern, corrected_section, content, flags=re.DOTALL | re.IGNORECASE)
        break

with open(file_path, 'w') as f:
    f.write(content)
EOF
        
        echo "✅ Updated: $file"
    else
        echo "❌ File not found: $file"
    fi
done

echo "Memory section updates complete!"