# Claude Code Migration Checklist
*Last Updated: 2025-08-07*

## ✅ Pre-Migration Cleanup Complete

### Files Cleaned Up:
- ✅ Removed all test files (test-*.sh)
- ✅ Archived deprecated directories to `DEPRECATED_ARCHIVE_20250807/`
- ✅ Consolidated old documentation files
- ✅ Updated CLAUDE.md with latest chunking optimizations

## 📦 Essential Files to Migrate

### Core Memory System:
```
~/.claude/
├── graphiti-hook.sh              # Main memory interface (UPDATED with chunking)
├── graphiti-direct-hook.py       # Python Graphiti integration
├── graphiti-batcher.py           # Batch processing
├── smart_memory_assessor.py      # Importance filtering
├── memory-preprocessor.sh        # Large content handler
├── memory-config.json            # Configuration
└── compact-memory-hook.sh        # /compact command handler
```

### Configuration:
```
~/.claude/
├── settings.json                 # Hooks and MCP configuration (ACTIVE)
├── CLAUDE.md                     # Main documentation (UPDATED)
└── PROPOSED_MEMORY_HOOKS.json    # Reference (already applied)
```

### Essential Documentation:
```
~/.claude/
├── MEMORY_SYSTEM_CLARIFICATION.md    # Current system docs
├── MEMORY_SYSTEM_ANALYSIS.md         # Chunking analysis
├── MEMORY_CHUNKING_OPTIMIZATION.md   # Optimization guide
├── MEMORY_SYSTEM_ACTIVE_FILES.md     # What's active
└── MEMORY_SYSTEM_FINAL_ARCHITECTURE.md
```

### MCP & Integration:
```
~/.claude/
├── Multi-MCP setup files
├── Serena hooks and guides
├── Gemini hooks and integration
└── Context7 documentation hooks
```

### Utilities:
```
~/.claude/
├── initialize-graphiti.sh        # Neo4j setup
├── graphiti-flush.sh             # Manual flush
└── neo4j-startup-hook.sh         # Auto-start Neo4j
```

## 🚀 Migration Steps

### On Current Machine:
1. ✅ Clean up deprecated files (DONE)
2. ✅ Update documentation (DONE)
3. ✅ Verify hooks in settings.json (DONE)
4. Copy entire `~/.claude/` directory (excluding DEPRECATED_ARCHIVE if desired)

### On New Machine:

#### 1. Prerequisites:
```bash
# Install required tools
brew install neo4j
brew install uv
pip install graphiti-core
pip install openai

# Set environment variables in ~/.zshrc or ~/.bashrc
export OPENAI_API_KEY="your-key"
export NEO4J_PASSWORD="demodemo"
```

#### 2. Copy Files:
```bash
# Copy from old machine
scp -r old-machine:~/.claude ~/
```

#### 3. Initialize Neo4j:
```bash
# First time setup
~/.claude/initialize-graphiti.sh

# Or just start if already configured
docker start neo4j
```

#### 4. Verify Setup:
```bash
# Test memory system
~/.claude/graphiti-hook.sh recent 5

# Check Neo4j
curl -s http://localhost:7474

# Verify hooks are loaded
cat ~/.claude/settings.json | jq '.hooks.PostToolUse'
```

## 🔧 Current System Status

### Memory System:
- **Automatic Capture**: ✅ ENABLED (hooks in settings.json)
- **Chunking**: ✅ Optimized (>2000 chars, 800 char chunks)
- **Background Processing**: ✅ Non-blocking async
- **Smart Filtering**: ✅ Active

### Key Improvements (2025-08-07):
- Chunking threshold: 1000 → 2000 characters
- Chunk size: 400 → 800 characters  
- Processing: Blocking → Async
- Result: 50% fewer chunks, faster processing

### PROJECT_NAME Projects:
- All CLAUDE.md files updated
- Memory hooks active
- Serena MCP configured
- Gemini analysis integrated

## ⚠️ Optional: Archive Cleanup

The `DEPRECATED_ARCHIVE_20250807/` directory contains:
- Old memory system implementations
- Legacy scripts
- Previous documentation versions
- ~2MB total

**You can safely exclude this from migration** if you don't need the history.

## 📝 Notes

### What's NOT Needed:
- ❌ hooks.json (use settings.json instead)
- ❌ memory-subagent-request.sh (deprecated)
- ❌ Test files
- ❌ Backup files
- ❌ Old documentation versions

### What's Critical:
- ✅ settings.json (contains hook configuration)
- ✅ graphiti-hook.sh (main memory interface)
- ✅ graphiti-direct-hook.py (Graphiti integration)
- ✅ memory-config.json (filtering config)

## ✨ Ready for Migration!

The system is now:
- Clean and organized
- Fully documented
- Optimized with latest improvements
- Ready to transfer to new machine

Simply copy `~/.claude/` (optionally excluding DEPRECATED_ARCHIVE_20250807) to your new machine and follow the setup steps above.