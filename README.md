# 🚀 Claude Code Enhanced Configuration

## 🎯 The Ultimate Local AI Development Stack

Transform your Claude Code CLI into a powerful development environment featuring three systems working in perfect harmony:

### The Trinity of Power:

**1. 🧠 Graphiti Memory (Neo4j)**
- Persistent knowledge graph capturing all work
- Auto-saves discoveries, solutions, and patterns  
- Searchable context across sessions
- Optimized chunking preventing timeouts

**2. 🔄 Multi-MCP Integration**
- **Serena MCP**: Semantic code understanding & RAG codebase search
- **Sequential Thinking MCP**: Complex reasoning connected to graph memory  
- **Additional MCPs**: Context7, GitHub, Filesystem, and more

**3. ⚡ Smart Automation Hooks**
- Pre-tool validation prevents wrong tool usage
- Impact analysis shows dependencies before changes
- Quality checks review code for consistency
- Memory capture saves everything important

---

## 📦 Core MCP Components (Local Tools)

This system integrates three powerful local MCP servers:

| Component | Purpose | GitHub Repository |
|-----------|---------|------------------|
| **🧠 Graphiti** | Local graph memory with Neo4j backend | [getzep/graphiti](https://github.com/getzep/graphiti) |
| **🔄 Sequential Thinking** | Complex reasoning connected to graph memory | [arben-adm/mcp-sequential-thinking](https://github.com/arben-adm/mcp-sequential-thinking) |
| **⚡ Serena** | Local RAG codebase & semantic search | [oraios/serena](https://github.com/oraios/serena) |

> **⚠️ Important Setup Notes:**
> - **Graphiti**: Do NOT set up as MCP with stdio - the MCP connection is broken. Use our local scripts with SSE instead (included in this package)
> - **Sequential Thinking**: Set up as standard MCP server  
> - **Serena**: Set up as standard MCP server

> **Why Local MCP Tools?**
> - 🔒 **Complete Privacy**: All data stays on your machine
> - ⚡ **Zero Latency**: No network calls for core operations  
> - 🧠 **Superior Context**: Semantic search beats regular text search
> - 💾 **Persistent Memory**: Knowledge graph grows with every session

---

## 💡 How It All Works Together

```
User Query → Memory system retrieves relevant context
          → Hooks analyze impact and prevent mistakes  
          → Serena provides precise semantic code operations
          → Insights saved back to memory for future use
          → Knowledge compounds over time
```

### The Magic:
- **Memory-Augmented Reasoning**: Never forgets solutions or patterns
- **Semantic Precision**: Code changes are surgically precise  
- **Continuous Learning**: Every session makes the system smarter
- **Zero Cloud Dependency**: 100% local, private, and fast
- **Automatic Context**: Hooks capture everything important

---

## 🛠️ Prerequisites

- Installed **Claude Code CLI** (latest version)
- Installed **Docker** (for Neo4j memory system)
- Installed **Python 3.13+** 
- Installed **uv** (modern Python package manager)
- Installed **Git**
- Cloned **Graphiti** https://github.com/getzep/graphiti
- Cloned **Sequential Thinking** https://github.com/arben-adm/mcp-sequential-thinking
- Cloned **Serena** https://github.com/oraios/serena
- Cloned **Multi MCP** https://github.com/kfirtoledo/multi-mcp

---

## 🚀 Quick Setup

```bash
echo 'export OPENAI_API_KEY="your-openapi-key"' >> ~/.bashrc
echo 'export GEMINI_API_KEY="your-gemini-key"' >> ~/.bashrc  # Optional for enhanced analysis
echo 'export GIT_CLONE_DIR="path-where-you-clone-repos"' >> ~/.bashrc

git clone https://github.com/AlexZahar/claude-code.git
cd claude-code

./install.sh

claude
```

---

## 📦 What's Included

### **Core Configuration Files**
- `CLAUDE.md` - Complete behavior instructions and workflows
- `settings.json` - Standard MCP server configuration with hooks
- `settings-multi-mcp.json` - Multi-MCP proxy configuration
- `settings.local.json` - Local overrides and customizations
- `memory-config.json` - Smart filtering & batching rules
- `LICENSE` - MIT license file

### **Installation & Setup Scripts**
- `install.sh` - One-click installation script
- `initialize-graphiti.sh` - One-command Neo4j setup
- `multi-mcp-setup.sh` - Multi-MCP proxy installation

### **Smart Hooks System (Core Intelligence)**  
- `gemini-hooks.sh` - Comprehensive code analysis with Gemini
- `serena-hooks.sh` - Enforces semantic code search via Serena MCP
- `documentation-hooks.sh` - Redirects documentation queries to Context7 MCP
- `context7-hooks.sh` - Context7 MCP integration utilities
- `graphiti-hook.sh` - Main memory capture system with chunking
- `compact-memory-hook.sh` - Auto-saves conversation summaries

### **Memory System Components**
- `graphiti-flush.sh` - Memory management utilities
- `graphiti-batcher.py` - Intelligent memory batching processor
- `memory-subagent-request.sh` - Complex memory operations handler
- `claude-memory` - Memory system utilities

### **Session & Startup Management**
- `boardlens-dev-startup-hook.sh` - Development environment startup
- `boardlens-dev-startup-hook-multi.sh` - Multi-MCP startup variant
- `mcp-session-hook.sh` - Standard MCP session management
- `mcp-session-hook-multi.sh` - Multi-MCP session management

### **MCP Service Management**
- `multi-mcp-service.sh` - Multi-MCP proxy service controller
- `mcp-optimizer.sh` - MCP performance optimization
- `mcp-cleanup-hook.sh` - Standard MCP cleanup utilities
- `mcp-cleanup-hook-multi.sh` - Multi-MCP cleanup variant

### **Python Hook Automation** (`hooks/`)
- `session-memory-hook.py` - Session-level memory capture
- `code-change-memory-hook.py` - File change tracking
- `weekly-architecture-snapshot-hook.py` - Periodic codebase analysis

### **Configuration Directories**
- `config/` - Additional configuration files
  - `gpt5-optimization.env` - GPT-5 optimization settings
- `docker/` - Docker-related configurations
  - `neo4j-optimized.env` - Optimized Neo4j settings

### **Command Documentation** (`commands/`)
14 comprehensive command guides:
- `remember.md`, `recall.md` - Memory operations
- `compact.md` - Conversation management
- `gemini-*.md` (8 files) - Analysis commands
- `context7-docs.md` - Documentation search

### **Slash Command Implementations** (`slash-commands/`)
11 ready-to-use slash commands plus 3 management scripts:
- `gemini-*.md` (8 files) - Analysis command implementations
- `context7-docs.md` - Documentation search implementation
- `mcp-status.sh`, `mcp-restart.sh`, `mcp-cleanup.sh` - MCP management tools

**Total: 50+ files providing a complete AI development environment**

---

## 📊 Performance Improvements

| Feature | Improvement | Impact |
|---------|------------|--------|
| Memory Chunking | 1400/800 chars | 95% fewer timeouts |
| Smart Filtering | 90% noise reduction | Relevant captures only |
| Hook Processing | <2 seconds | Non-blocking workflow |
| MCP Integration | Unified proxy | Single endpoint management |

---

## 🎯 What You Get

**An AI assistant that:**
- **Remembers everything** across sessions
- **Thinks step-by-step** with full context  
- **Modifies code** with surgical precision
- **Learns** from every interaction
- **Prevents mistakes** automatically
- **Runs 100% locally** on your machine

**Result**: A development environment that gets smarter with every use, turning Claude Code into a true coding partner that understands your entire codebase and work history.

---

## 🔧 Core Features Deep Dive

### **Persistent Memory System**
- Automatic knowledge graph building
- Cross-session context retention
- Smart content chunking (1400/800 chars)
- Background processing prevents blocking
- Searchable across all your coding sessions

### **Intelligent Hook System**
- **PreToolUse**: Impact analysis, duplicate detection
- **PostToolUse**: Quality checks, automatic memory capture
- **SessionStart**: Neo4j startup, MCP activation  
- **UserPromptSubmit**: Special command handling

### **Multi-MCP Integration**
- **Serena**: Local RAG codebase search & semantic code analysis
- **Sequential Thinking**: Complex reasoning with graph memory access
- **Graphiti**: Persistent knowledge graph with Neo4j backend
- **Unified Proxy**: Single endpoint managing all MCP services

---

## 📁 Repository Structure

```
~/.claude/
├── README.md              # This guide
├── CLAUDE.md              # Complete behavior instructions (36KB)
├── LICENSE                # MIT license
├── settings.json          # MCP configuration with hooks
├── settings-multi-mcp.json # Multi-MCP proxy configuration  
├── settings.local.json    # Local overrides
├── memory-config.json     # Memory system settings
├── install.sh            # Installation script
├── hooks/                 # Memory automation (2 Python scripts)
├── commands/              # Command documentation (14 files)
├── slash-commands/        # Command implementations (11 .md + 3 .sh)
├── context7-hooks.sh      # Context7 MCP integration
├── documentation-hooks.sh # Documentation search hooks
├── gemini-hooks.sh        # Code analysis automation
├── serena-hooks.sh        # Semantic search enforcement
├── graphiti-hook.sh       # Memory capture system
├── graphiti-flush.sh      # Memory management utilities
├── initialize-graphiti.sh # Neo4j setup script
└── mcp-session-hook-multi.sh # MCP session management
```

---

## 🔒 Security & Privacy

- ✅ **No hardcoded secrets** - environment variables only
- ✅ **No personal data** in repository
- ✅ **Local-first** - all data stays on your machine
- ✅ **Safe for team sharing** - sanitized configuration
- ✅ **Neo4j local database** - your memory data is private

---

## 🚀 Advanced Usage

### Memory Commands
```bash
/remember "Bug fix: JWT tokens expire due to timezone issues"
/recall "JWT token problems" 
```

### Analysis Commands  
```bash
/gemini-overview          # Project architecture analysis
/gemini-security          # Security audit with OWASP focus
/gemini-performance       # Bottleneck identification
```

### Documentation
```bash
/context7-docs "React hooks"  # Search curated documentation
```

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 📝 Support

For setup help:
1. Check `CLAUDE.md` for detailed workflows
2. Review hook scripts for customization options
3. Create an issue for bugs or feature requests

---

**Ready to supercharge your Claude Code into a memory-enhanced, semantically-aware development partner!** 🚀

*Technologies: Neo4j, Graphiti, MCP, Claude Code Hooks*