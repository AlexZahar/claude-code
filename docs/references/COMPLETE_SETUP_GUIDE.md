# Claude Code Enhanced Setup Guide
# Complete Installation and Configuration

**Version:** 2.0  
**Last Updated:** August 3, 2025  
**Status:** Production Ready ✅

This guide will transform your basic Claude Code installation into a sophisticated development environment with automatic quality assurance, persistent memory, and intelligent workflow orchestration.

---

## 🎯 What You'll Get

After completing this setup, Claude Code will become a **proactive development partner** that:

- **Prevents mistakes automatically** through intelligent hooks
- **Builds persistent memory** across all your coding sessions
- **Enforces best practices** (uses Serena for code, Context7 for docs)
- **Provides 13 custom slash commands** for quick analysis
- **Works zero-configuration** once installed

**Estimated Setup Time:** 30-45 minutes  
**Skill Level:** Intermediate (command line comfortable)

---

## 📋 Prerequisites

### Required Dependencies
- **Claude Code CLI** (already installed)
- **Docker Desktop** (for Neo4j memory system)
- **Python 3.8+** with pip
- **Node.js 16+** and npm (for MCP management)
- **Git** (for version control)
- **OpenAI API Key** (for memory and analysis features)

### Optional Dependencies (Enhanced Features)
- **uv** (Python package manager - faster than pip)
- **Gemini CLI** (for advanced code analysis)
- **Serena MCP** (semantic code understanding)
- **Context7 MCP** (documentation management)

### System Requirements
- **macOS/Linux** (Windows with WSL2)
- **8GB+ RAM** (4GB for Neo4j + 4GB for development)
- **2GB+ free disk space**
- **Internet connection** (for initial setup and API calls)

---

## 🚀 Quick Start (15 Minutes)

If you're in a hurry, follow these essential steps:

### 1. Set Environment Variables
```bash
# Add to your ~/.zshrc or ~/.bashrc
export OPENAI_API_KEY="your-openai-api-key-here"
export NEO4J_PASSWORD="demodemo"  # Change this for production
```

### 2. Install Core Dependencies
```bash
# Install Docker (if not already installed)
# macOS: Download Docker Desktop from docker.com
# Linux: sudo apt install docker.io docker-compose

# Install Python package manager (recommended)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Verify installations
docker --version
python3 --version
```

### 3. Initialize Memory System
```bash
cd ~/.claude/memory
./initialize-graphiti.sh
```

### 4. Configure Settings
```bash
cd ~/.claude
cp settings.json.template settings.json
# Edit settings.json to update paths for your system
```

### 5. Test Installation
```bash
claude code
# You should see memory system initializing automatically
```

**Success?** Skip to [Usage Examples](#-usage-examples)  
**Issues?** Continue with the full setup below.

---

## 🔧 Complete Installation

### Step 1: Environment Setup

#### 1.1 Create Environment Variables
```bash
# Create environment file
cat >> ~/.zshrc << 'EOF'

# Claude Code Enhanced Configuration
export OPENAI_API_KEY="your-openai-api-key-here"
export NEO4J_URI="bolt://localhost:7687"
export NEO4J_USER="neo4j"
export NEO4J_PASSWORD="demodemo"
export MODEL_NAME="gpt-4o-mini"
export EMBEDDER_MODEL_NAME="text-embedding-3-small"
export GROUP_ID="claude-code-hooks"

EOF

# Reload environment
source ~/.zshrc
```

#### 1.2 Verify Environment
```bash
echo "OpenAI Key: ${OPENAI_API_KEY:0:20}..."
echo "Neo4j URI: $NEO4J_URI"
```

### Step 2: Install Dependencies

#### 2.1 Install Docker (if needed)
```bash
# macOS with Homebrew
brew install --cask docker

# Linux (Ubuntu/Debian)
sudo apt update
sudo apt install docker.io docker-compose

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

#### 2.2 Install Python Dependencies
```bash
# Install uv (recommended Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.zshrc

# Alternative: use pip
# pip3 install --upgrade pip
```

#### 2.3 Install Node.js (if needed)
```bash
# macOS with Homebrew
brew install node

# Linux (Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

### Step 3: Configure Claude Code Settings

#### 3.1 Update Settings Configuration
```bash
cd ~/.claude

# If settings.json.template exists, use it as base
if [ -f "settings.json.template" ]; then
    cp settings.json.template settings.json
else
    # Create basic settings file
    cat > settings.json << 'EOF'
{
  "mcpServers": {
    "multi-mcp-proxy": {
      "command": "node",
      "args": ["/path/to/multi-mcp-proxy/server.js"],
      "env": {
        "OPENAI_API_KEY": ""
      }
    }
  }
}
EOF
fi

# Edit settings.json to update paths
echo "⚠️  IMPORTANT: Edit ~/.claude/settings.json to update paths for your system"
```

#### 3.2 Create Memory Configuration
```bash
# Create or update memory configuration
cat > ~/.claude/memory-config.json << 'EOF'
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
EOF
```

### Step 4: Initialize Memory System

#### 4.1 Run Memory System Setup
```bash
cd ~/.claude/memory
chmod +x initialize-graphiti.sh
./initialize-graphiti.sh
```

This script will:
- Install Neo4j via Docker
- Configure it for Graphiti
- Set up Python dependencies
- Start Neo4j with auto-restart enabled

#### 4.2 Verify Memory System
```bash
# Check if Neo4j is running
curl -s http://localhost:7474 && echo " - Neo4j is running ✅"

# Test memory system
cd ~/.claude/memory
python3 -c "
import sys
sys.path.append('/Users/$USER/.claude')
from smart_memory_assessor import MemoryAssessor
assessor = MemoryAssessor()
print('Memory assessor working ✅')
"
```

### Step 5: Set Up Hook System

#### 5.1 Verify Hooks Configuration
```bash
cd ~/.claude

# Check if hooks.json exists
if [ -f "hooks.json" ]; then
    echo "✅ Hooks configuration found"
    # Validate JSON
    python3 -c "import json; json.load(open('hooks.json')); print('Hooks JSON valid ✅')"
else
    echo "❌ hooks.json not found - you may need to create it"
fi
```

#### 5.2 Test Hook Scripts
```bash
# Make all hook scripts executable
chmod +x ~/.claude/hooks/*.sh
chmod +x ~/.claude/memory/*.sh
chmod +x ~/.claude/mcp/*.sh

# Test main memory hook
~/.claude/memory/graphiti-hook.sh add "Test setup: Memory system working"
```

### Step 6: Optional Enhancements

#### 6.1 Install Gemini CLI (Advanced Code Analysis)
```bash
# Install Gemini CLI for advanced code analysis
# Follow instructions at: https://ai.google.dev/gemini-api/docs/cli

# Test installation
gemini --version
```

#### 6.2 Set Up Multi-MCP Proxy (Optional)
```bash
# If you have multi-MCP proxy available
cd ~/.claude/mcp
chmod +x multi-mcp-setup.sh
./multi-mcp-setup.sh
```

#### 6.3 Install Serena MCP (Semantic Code Analysis)
```bash
# Follow Serena setup guide
cat ~/.claude/docs/SERENA_MCP_SETUP.md
```

#### 6.4 Install Context7 MCP (Documentation Management)
```bash
# Follow Context7 setup guide  
cat ~/.claude/docs/CONTEXT7_DOCUMENTATION_GUIDE.md
```

---

## 🧪 Testing and Verification

### Test 1: Basic Functionality
```bash
# Start Claude Code
claude code

# In Claude Code session, test memory:
/remember This is a test memory for setup verification

# Test search:
/recall test

# You should see your test memory returned
```

### Test 2: Hook System
```bash
# Test that hooks are working
cd ~/.claude

# This should trigger memory capture hooks
echo "console.log('test');" > test-file.js
rm test-file.js

# Check memory logs
tail -5 ~/.claude/memory/*.log
```

### Test 3: Advanced Features (If Installed)
```bash
# Test Gemini integration (if available)
cd ~/.claude
HOOK_TYPE=overview ~/.claude/hooks/gemini-hooks.sh

# Test Serena (if available)
# Should block search tools and suggest Serena instead
```

### Test 4: Memory Persistence
```bash
# Exit Claude Code and restart
# Previous memories should be available with /recall
```

---

## 🎮 Usage Examples

### Basic Memory Commands
```bash
# Save important discoveries
/remember Fixed authentication bug by updating JWT expiration logic

# Search your memory
/recall authentication
/recall bug fix
/recall last week

# Recent memories
~/.claude/memory/graphiti-hook.sh recent 10
```

### Advanced Memory Queries
```bash
# Search by type
~/.claude/memory/graphiti-hook.sh search-type bug_fix

# Search with filters
~/.claude/memory/graphiti-hook.sh search-filtered feature high

# Recent features only
~/.claude/memory/graphiti-hook.sh recent-type feature 5
```

### Slash Commands Available
```
/remember [text]           - Save to memory
/recall [query]           - Search memory  
/compact                  - Summarize and save session
/gemini-overview         - Project overview
/gemini-analyze          - Comprehensive analysis
/gemini-security         - Security audit
/gemini-performance      - Performance analysis
/context7-docs [query]   - Search documentation
```

### Hook System Benefits
The system automatically:
- **Prevents code search mistakes** (enforces Serena usage)
- **Redirects documentation queries** (uses Context7 instead of web)
- **Captures file changes** to memory
- **Analyzes code quality** after edits
- **Provides impact analysis** before changes

---

## 🚨 Troubleshooting

### Memory System Issues

#### Neo4j Won't Start
```bash
# Check Docker is running
docker ps

# Start Neo4j manually
docker start neo4j

# Check Neo4j logs
docker logs neo4j

# Reset Neo4j (last resort)
docker stop neo4j
docker rm neo4j
cd ~/.claude/memory
./initialize-graphiti.sh
```

#### Memory Hooks Not Working
```bash
# Check permissions
ls -la ~/.claude/memory/*.sh

# Make executable
chmod +x ~/.claude/memory/*.sh

# Test directly
~/.claude/memory/graphiti-hook.sh add "Test direct call"

# Check logs
tail -20 ~/.claude/memory/*.log
```

### API Key Issues

#### OpenAI API Key Not Found
```bash
# Verify environment variable
echo $OPENAI_API_KEY

# Re-source environment
source ~/.zshrc

# Test API key
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/models | head -20
```

### Hook System Issues

#### Hooks Not Triggering
```bash
# Check hooks.json syntax
python3 -c "import json; json.load(open('~/.claude/hooks.json'))"

# Verify hook permissions
ls -la ~/.claude/hooks/*.sh

# Test individual hooks
HOOK_TYPE=test ~/.claude/hooks/gemini-hooks.sh
```

### MCP Issues

#### MCP Servers Not Responding
```bash
# Check Multi-MCP proxy status
curl -s http://127.0.0.1:8080/mcp_servers

# Restart MCP services
~/.claude/mcp/mcp-manager.sh restart

# Check Claude Code settings
cat ~/.claude/settings.json
```

### Performance Issues

#### System Running Slowly
```bash
# Check Docker memory usage
docker stats neo4j

# Check disk space
df -h ~/.claude

# Clean up logs
rm -f ~/.claude/*.log

# Restart memory system
docker restart neo4j
```

---

## 🔧 Configuration Customization

### Memory System Tuning
```bash
# Edit memory configuration
nano ~/.claude/memory-config.json

# Key settings to adjust:
# - window_seconds: Batching window (default: 30)
# - min_file_change_lines: Minimum lines to trigger memory (default: 5)
# - importance_rules: What commands are considered high/medium/low priority
```

### Hook System Customization
```bash
# Edit hook configuration
nano ~/.claude/hooks.json

# Add custom hooks for specific tools or workflows
# See existing hooks for examples
```

### MCP Server Configuration
```bash
# Edit MCP settings
nano ~/.claude/settings.json

# Add additional MCP servers
# Configure environment variables
# Set custom command paths
```

---

## 📚 Additional Resources

### Documentation
- **Full Audit Report:** `~/.claude/PEER_SHARING_AUDIT_REPORT.md`
- **Serena Setup:** `~/.claude/docs/SERENA_MCP_SETUP.md`
- **Context7 Setup:** `~/.claude/docs/CONTEXT7_DOCUMENTATION_GUIDE.md`
- **Gemini Integration:** `~/.claude/docs/gemini-hooks-guide.md`
- **Hook Documentation:** `~/.claude/docs/documentation-hook-guide.md`

### Log Files
- **Memory System:** `~/.claude/memory/*.log`
- **Hook Activity:** `~/.claude/*.log`
- **Neo4j Database:** `docker logs neo4j`
- **MCP Proxy:** `~/.claude/multi-mcp.log`

### Key Directories
```
~/.claude/
├── hooks/          # Hook scripts for workflow automation
├── memory/         # Memory system and Graphiti integration
├── mcp/           # MCP management and configuration
├── slash-commands/ # Custom slash command definitions
├── commands/      # Command implementations
├── docs/          # Documentation and guides
└── *.json         # Configuration files
```

---

## 🎯 What's Next?

### Immediate Next Steps
1. **Test all functionality** with the examples above
2. **Customize memory settings** for your workflow
3. **Install optional enhancements** (Gemini, Serena, Context7)
4. **Share with your team** using the cleanup script

### Advanced Usage
- **Project-specific configurations** for different codebases
- **Custom hook development** for specialized workflows
- **Memory analytics** to understand your coding patterns
- **Integration with CI/CD** for automated quality checks

### Team Deployment
- Use `~/.claude/CLEANUP_FOR_PEER_SHARING.sh` to prepare clean configs
- Share the essential files with team members
- Provide team-specific setup instructions
- Establish team conventions for memory usage

---

## 🛟 Support

### Getting Help
1. **Check logs first** - most issues are logged with helpful error messages
2. **Review troubleshooting section** above
3. **Test individual components** to isolate issues
4. **Check environment variables** and paths

### Common Success Patterns
- **Start simple:** Get basic memory working first, then add enhancements
- **Test incrementally:** Verify each component before moving to the next
- **Read the logs:** They contain valuable debugging information
- **Use the provided scripts:** They handle edge cases and error conditions

---

## ✅ Setup Checklist

Print this checklist and check off each item:

### Prerequisites
- [ ] Claude Code CLI installed and working
- [ ] Docker Desktop installed and running
- [ ] Python 3.8+ available
- [ ] OpenAI API key obtained
- [ ] Environment variables set in shell profile

### Core Installation
- [ ] Environment variables configured
- [ ] Memory system initialized (Neo4j running)
- [ ] Hooks configuration validated
- [ ] Basic memory test successful
- [ ] Claude Code session starts without errors

### Verification Tests
- [ ] `/remember` and `/recall` commands work
- [ ] Memory persists across Claude Code restarts
- [ ] Hook system captures file changes
- [ ] Slash commands available and functional

### Optional Enhancements
- [ ] Gemini CLI installed (if desired)
- [ ] Serena MCP configured (if desired)
- [ ] Context7 MCP configured (if desired)
- [ ] Multi-MCP proxy running (if desired)

### Final Validation
- [ ] All tests in "Testing and Verification" section pass
- [ ] Team members can follow this guide successfully
- [ ] System performs well under normal usage
- [ ] Troubleshooting guide is accessible

---

**🎉 Congratulations!** 

You now have a sophisticated Claude Code environment that will:
- **Automatically prevent common coding mistakes**
- **Build persistent knowledge** across all your projects
- **Enforce best practices** through intelligent tool routing
- **Provide advanced analysis capabilities** through custom commands
- **Work seamlessly** with zero day-to-day configuration

Your coding productivity and quality are about to significantly improve! 

**Happy Coding!** 🚀

---

**Document Version:** 2.0  
**Last Updated:** August 3, 2025  
**Tested On:** macOS Sonoma, Ubuntu 22.04  
**Prerequisites Version:** Claude Code CLI Latest, Docker 24+, Python 3.8+