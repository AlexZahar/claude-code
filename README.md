# Claude Code Enhanced Configuration

Transform your Claude Code CLI into a powerful development environment with intelligent automation, persistent memory, and semantic code understanding.

## 🚀 Quick Setup

```bash
# Install to ~/.claude directory
git clone https://github.com/AlexZahar/claude-code.git ~/.claude
cd ~/.claude

# Set your API key
export OPENAI_API_KEY="your-key-here"

# Run installation
./install.sh

# Test it works
claude code
```

## ✨ What You Get

### **Smart Automation**
- **Pre-tool validation** - Prevents wrong tool usage
- **Impact analysis** - Shows dependencies before changes
- **Quality checks** - Reviews code for consistency

### **Persistent Memory**
- **Cross-session memory** - Remembers your work
- **Smart search** - Find past solutions instantly
- **Auto-capture** - No manual memory management

### **Enhanced Tools**
- **Serena MCP** - Semantic code analysis
- **Context7 MCP** - Documentation management
- **Gemini CLI** - Large-context analysis
- **Custom commands** - 13 specialized slash commands

## 📁 Structure

```
~/.claude/
├── CLAUDE.md              # Core behavior instructions
├── settings.json          # MCP server configuration
├── memory-config.json     # Memory system settings
├── install.sh            # One-click installer
├── hooks/                # Automation scripts
├── commands/             # Custom slash commands
└── slash-commands/       # Command implementations
```

## 🔧 Core Commands

```bash
/remember [text]          # Save to memory
/recall [query]           # Search memory
/gemini-overview         # Project analysis
/gemini-security         # Security audit
/context7-docs           # Search docs
```

## 🛠️ Requirements

- **Claude Code CLI** (latest version)
- **Docker** (for Neo4j memory system)
- **Python 3.8+**
- **Git**

## ⚙️ Configuration

The system works with environment variables:

```bash
export OPENAI_API_KEY="your-key"
export GEMINI_API_KEY="your-gemini-key"  # Optional
```

## 🧠 Memory System

Automatic knowledge graph that:
- Remembers all your coding sessions
- Learns from your patterns
- Provides instant search across projects
- No manual memory management needed

## 🔒 Security

- ✅ No hardcoded secrets
- ✅ Environment variables only
- ✅ No personal data in repository
- ✅ Safe for team sharing

## 📚 Documentation

- `CLAUDE.md` - Complete behavior instructions
- `memory-config.json` - Memory system tuning
- `hooks/` - Automation script documentation

## 🤝 Contributing

1. Fork the repository
2. Make your changes
3. Test with `claude code`
4. Submit a pull request

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

**Ready to supercharge your Claude Code experience!** 🚀