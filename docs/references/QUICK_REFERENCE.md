# Claude Code Enhanced - Quick Reference
# Essential Commands and Configuration

## 🚀 Quick Start
```bash
export OPENAI_API_KEY="your-key-here"
cd ~/.claude/memory && ./initialize-graphiti.sh
claude code
```

## 📝 Memory Commands
```bash
/remember [text]                    # Save to memory
/recall [query]                     # Search memory
~/.claude/memory/graphiti-hook.sh recent 10         # Recent memories
~/.claude/memory/graphiti-hook.sh search-type bug_fix    # Search by type
```

## ⚡ Slash Commands
```
/remember [text]        /recall [query]         /compact
/gemini-overview       /gemini-analyze         /gemini-security
/gemini-performance    /gemini-feature [name]  /gemini-find [pattern]
/context7-docs [query] /gemini-architecture    /gemini-review
```

## 🔧 System Management
```bash
# Memory System
docker start neo4j                              # Start Neo4j
curl http://localhost:7474                      # Check Neo4j status
~/.claude/memory/graphiti-hook.sh add "test"    # Test memory

# MCP Management  
~/.claude/mcp/mcp-manager.sh status            # Check MCP status
~/.claude/mcp/mcp-manager.sh restart           # Restart MCP services

# Hook System
tail -f ~/.claude/*.log                        # Monitor hook activity
~/.claude/hooks/gemini-hooks.sh test           # Test Gemini hooks
```

## 🚨 Troubleshooting
```bash
# Neo4j Issues
docker logs neo4j                              # Check Neo4j logs
docker restart neo4j                           # Restart Neo4j

# API Key Issues  
echo $OPENAI_API_KEY                           # Verify API key
source ~/.zshrc                                # Reload environment

# Hook Issues
chmod +x ~/.claude/hooks/*.sh                  # Fix permissions
python3 -c "import json; json.load(open('~/.claude/hooks.json'))"  # Validate JSON
```

## 📂 Key Files
```
~/.claude/
├── COMPLETE_SETUP_GUIDE.md    # Full setup instructions
├── hooks.json                 # Hook configuration
├── memory-config.json         # Memory settings
├── settings.json              # MCP settings
├── hooks/                     # Hook scripts
├── memory/                    # Memory system
└── docs/                      # Documentation
```

## 🔍 What the System Does Automatically
- **Prevents Search/Grep on code files** → Forces Serena usage
- **Redirects doc searches** → Uses Context7 instead of web
- **Captures file changes** → Builds memory automatically  
- **Analyzes code quality** → Reviews after edits
- **Provides impact analysis** → Shows dependencies before changes

## 📋 Essential Environment Variables
```bash
export OPENAI_API_KEY="your-key-here"
export NEO4J_PASSWORD="demodemo"
export NEO4J_URI="bolt://localhost:7687"
```

## ✅ Health Check
```bash
# All should return success:
curl -s http://localhost:7474 && echo "✅ Neo4j"
echo $OPENAI_API_KEY | grep -q "sk-" && echo "✅ API Key"  
[ -f ~/.claude/hooks.json ] && echo "✅ Hooks Config"
~/.claude/memory/graphiti-hook.sh recent 1 > /dev/null && echo "✅ Memory"
```

**Need help?** See `COMPLETE_SETUP_GUIDE.md` for detailed instructions.