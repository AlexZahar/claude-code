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
fi

# Install configuration
echo -e "${BLUE}📁 Installing enhanced configuration...${NC}"

# Create directory structure
mkdir -p "$CLAUDE_DIR"/{hooks,config,local,mcp-configs,logs}

# Copy files (assuming we're running from the repo directory)
if [ -f "CLAUDE.md" ]; then
    cp -r . "$CLAUDE_DIR/"
    echo -e "${GREEN}✅ Configuration files copied${NC}"
else
    echo -e "${RED}❌ Configuration files not found. Are you running from the repository directory?${NC}"
    exit 1
fi

# Update user-specific paths in configuration
echo -e "${BLUE}🔧 Updating configuration paths...${NC}"

# Replace USERNAME placeholders with actual username
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    sed -i.bak "s|/Users/USERNAME|$HOME|g" "$CLAUDE_DIR/settings.json"
    rm "$CLAUDE_DIR/settings.json.bak"
fi

if [ -f "$CLAUDE_DIR/settings-multi-mcp.json" ]; then
    sed -i.bak "s|/Users/USERNAME|$HOME|g" "$CLAUDE_DIR/settings-multi-mcp.json"
    rm "$CLAUDE_DIR/settings-multi-mcp.json.bak"
fi

# Make scripts executable
chmod +x "$CLAUDE_DIR"/*.sh

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

# Installation complete
echo ""
echo -e "${GREEN}🎉 Installation Complete!${NC}"
echo -e "${GREEN}========================${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Set your OpenAI API key: export OPENAI_API_KEY=\"your-key\""
echo "2. Test the system: claude code"
echo "3. Try a slash command: /gemini-overview"
echo "4. Check the documentation: $CLAUDE_DIR/COMPLETE_SETUP_GUIDE.md"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo -e "${BLUE}🗂️  Your previous configuration was backed up to:${NC}"
    echo "   $BACKUP_DIR"
    echo ""
fi

echo -e "${GREEN}✨ Your Claude Code is now enhanced with professional development features!${NC}"