#!/bin/bash
# Migration script for optimized tmux/MCP setup

echo "🔄 Migrating to Optimized tmux/MCP Setup"
echo "========================================"

# Step 1: Clean current mess
echo -e "\n1️⃣  Cleaning current environment..."
echo "   Killing all tmux sessions..."
tmux kill-server 2>/dev/null || echo "   No tmux server running"

echo "   Killing all MCP processes..."
pkill -f "mcp-server" 2>/dev/null || true
pkill -f "serena" 2>/dev/null || true
pkill -f "sequential-thinking" 2>/dev/null || true
pkill -f "graphiti" 2>/dev/null || true
pkill -f "firecrawl" 2>/dev/null || true

echo "   Cleaning session files..."
rm -rf "$HOME/.claude/sessions" 2>/dev/null
mkdir -p "$HOME/.claude/sessions"

# Step 2: Create necessary directories
echo -e "\n2️⃣  Setting up directories..."
mkdir -p "$HOME/.claude/mcp-state"
mkdir -p "$HOME/.claude/sessions"

# Step 3: Verify scripts are executable
echo -e "\n3️⃣  Verifying scripts..."
chmod +x "$HOME/.claude/cleanup-session.sh"
chmod +x "$HOME/.claude/mcp-manager.sh"
chmod +x "$HOME/.claude/migrate-tmux-setup.sh"

# Step 4: Show current memory
echo -e "\n4️⃣  Current Memory Status:"
ps aux | grep -E "(uv|python|node|npm|mcp)" | grep -v grep | awk '{mem+=$6} END {
    printf "   Total development processes: %.1f GB\n", mem/1024/1024
}'

# Step 5: Instructions
echo -e "\n✅ Migration Complete!"
echo -e "\n📋 Next Steps:"
echo "1. Reload your shell configuration:"
echo "   source ~/.zshrc"
echo ""
echo "2. Test the new setup:"
echo "   cd ~/Projects/your-project"
echo "   tm              # Create/attach session"
echo "   mcps            # Check MCP status"
echo "   mem             # Check memory usage"
echo ""
echo "3. Quick Command Reference:"
echo "   tm    - Smart tmux (reuses sessions)"
echo "   tma   - Attach with fuzzy search"
echo "   tmk   - Kill current session + cleanup"
echo "   mcps  - MCP status"
echo "   mem   - Memory analysis"
echo ""
echo "📖 Full guide: ~/.claude/TMUX_MCP_GUIDE.md"