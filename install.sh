#!/bin/bash
# Claude Code Enhanced Configuration - Installation Script
# Automated setup for professional development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude_backup_$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}🚀 Claude Code Enhanced Configuration Installer${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo -e "${RED}❌ Claude Code CLI not found. Please install Claude Code first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Claude Code CLI found${NC}"

# Check for required dependencies
echo -e "${YELLOW}🔍 Checking dependencies...${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker not found. Memory system will be disabled.${NC}"
    DOCKER_AVAILABLE=false
else
    echo -e "${GREEN}✅ Docker found${NC}"
    DOCKER_AVAILABLE=true
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 not found. Please install Python 3.8+${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Python 3 found${NC}"

# Check uv (modern Python package manager)
if ! command -v uv &> /dev/null; then
    echo -e "${RED}❌ uv not found. Please install uv for Python package management${NC}"
    exit 1
fi

echo -e "${GREEN}✅ uv found${NC}"

# Create Claude configuration directory
echo -e "${BLUE}📁 Setting up Claude configuration directory...${NC}"

# Check for existing Claude configuration
if [ -d "$CLAUDE_DIR" ]; then
    echo -e "${YELLOW}⚠️  Existing Claude configuration found${NC}"
    read -p "Create backup and continue? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}📦 Creating backup at $BACKUP_DIR${NC}"
        cp -r "$CLAUDE_DIR" "$BACKUP_DIR"
    else
        echo -e "${RED}❌ Installation cancelled${NC}"
        exit 1
    fi
else
    # Create directory structure
    mkdir -p "$CLAUDE_DIR"
fi

# Install configuration
echo -e "${BLUE}📁 Installing enhanced configuration...${NC}"

# Check if we're in the repository directory
if [ ! -f "CLAUDE.md" ] || [ ! -f "settings.json" ]; then
    echo -e "${RED}❌ Error: This script must be run from the claude-code repository directory${NC}"
    echo -e "${YELLOW}Usage: Run 'cd claude-code && ./install.sh' from the cloned repository${NC}"
    exit 1
fi

echo "  Copying core configuration..."
cp -f CLAUDE.md "$CLAUDE_DIR/"
cp -f settings.json "$CLAUDE_DIR/"
cp -f settings-multi-mcp.json "$CLAUDE_DIR/"
cp -f settings.local.json "$CLAUDE_DIR/"
cp -f memory-config.json "$CLAUDE_DIR/"
cp -f LICENSE "$CLAUDE_DIR/"

echo "  Copying hook scripts..."
cp -f gemini-hooks.sh "$CLAUDE_DIR/"
cp -f serena-hooks.sh "$CLAUDE_DIR/"
cp -f documentation-hooks.sh "$CLAUDE_DIR/"
cp -f context7-hooks.sh "$CLAUDE_DIR/"
cp -f graphiti-hook.sh "$CLAUDE_DIR/"
cp -f graphiti-flush.sh "$CLAUDE_DIR/"

echo "  Copying utility scripts..."
cp -f initialize-graphiti.sh "$CLAUDE_DIR/"
cp -f mcp-session-hook-multi.sh "$CLAUDE_DIR/"
cp -f multi-mcp-setup.sh "$CLAUDE_DIR/"
cp -f multi-mcp-service.sh "$CLAUDE_DIR/"
cp -f boardlens-dev-startup-hook-multi.sh "$CLAUDE_DIR/"
cp -f mcp-cleanup-hook-multi.sh "$CLAUDE_DIR/"

echo "  Copying directories..."
cp -rf commands/ "$CLAUDE_DIR/"
cp -rf slash-commands/ "$CLAUDE_DIR/"
cp -rf hooks/ "$CLAUDE_DIR/"

echo -e "${GREEN}✅ Configuration files copied${NC}"

# Make scripts executable
chmod +x "$CLAUDE_DIR"/*.sh
chmod +x "$CLAUDE_DIR/slash-commands"/*.sh 2>/dev/null || true
chmod +x "$CLAUDE_DIR/hooks"/*.py 2>/dev/null || true

echo -e "${GREEN}✅ Configuration paths updated${NC}"

# Set up memory system if Docker is available
if [ "$DOCKER_AVAILABLE" = true ]; then
    echo -e "${BLUE}🧠 Setting up memory system (Neo4j)...${NC}"
    cd "$CLAUDE_DIR"
    if ./initialize-graphiti.sh; then
        echo -e "${GREEN}✅ Memory system initialized${NC}"
    else
        echo -e "${YELLOW}⚠️  Memory system setup encountered issues. Check logs.${NC}"
    fi
fi

# Set up MCP proxy
echo -e "${BLUE}🔗 Setting up MCP proxy...${NC}"
cd "$CLAUDE_DIR"
if ./multi-mcp-setup.sh; then
    echo -e "${GREEN}✅ MCP proxy configured${NC}"
else
    echo -e "${YELLOW}⚠️  MCP proxy setup encountered issues. Check logs.${NC}"
fi

# Check environment variables
echo -e "${BLUE}🔑 Checking environment variables...${NC}"

if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  OPENAI_API_KEY not set${NC}"
    echo -e "${BLUE}💡 Add this to your shell profile:${NC}"
    echo -e "${BLUE}   export OPENAI_API_KEY=\"your-key-here\"${NC}"
else
    echo -e "${GREEN}✅ OPENAI_API_KEY is set${NC}"
fi

if [ -z "$GEMINI_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  GEMINI_API_KEY not set${NC}"
    echo -e "${BLUE}💡 Add this to your shell profile:${NC}"
    echo -e "${BLUE}   export GEMINI_API_KEY=\"your-key-here\"${NC}"
else
    echo -e "${GREEN}✅ GEMINI_API_KEY is set${NC}"
fi

if [ -z "$GIT_CLONE_DIR" ]; then
    echo -e "${YELLOW}⚠️  GIT_CLONE_DIR not set${NC}"
    echo -e "${BLUE}💡 Add this to your shell profile:${NC}"
    echo -e "${BLUE}   export GIT_CLONE_DIR=\"your-directory-here\"${NC}"
    exit 1
else
    echo -e "${GREEN}✅ GIT_CLONE_DIR is set${NC}"
fi

# Installation complete
echo ""
echo -e "${GREEN}🎉 Installation Complete!${NC}"
echo -e "${GREEN}========================${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. (if not done) Set your OpenAI API key: export OPENAI_API_KEY=\"your-key\""
echo "2. (if not done) Set your Gemini API key: export GEMINI_API_KEY=\"your-key\""
echo "3. Test the system: claude code"
echo "4. Try a slash command: /gemini-overview"
echo "5. Check the documentation: $CLAUDE_DIR/CLAUDE.md"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo -e "${BLUE}🗂️  Your previous configuration was backed up to:${NC}"
    echo "   $BACKUP_DIR"
    echo ""
fi

echo -e "${GREEN}✨ Your Claude Code is now enhanced with professional development features!${NC}"