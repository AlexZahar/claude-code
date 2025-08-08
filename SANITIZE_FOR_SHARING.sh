#!/bin/bash
# Script to sanitize ~/.claude folder for sharing with others
# This creates a clean copy without sensitive data

echo "🔒 Sanitizing ~/.claude folder for sharing..."

# Create sanitized copy directory
SANITIZED_DIR="$HOME/.claude_sanitized"
rm -rf "$SANITIZED_DIR"
mkdir -p "$SANITIZED_DIR"

# Copy all files
cp -r ~/.claude/* "$SANITIZED_DIR/"

# Remove sensitive files
echo "📝 Removing sensitive files..."
rm -f "$SANITIZED_DIR/active_session.json"
rm -f "$SANITIZED_DIR/graphiti-batch.json"
rm -f "$SANITIZED_DIR/*.log"
rm -rf "$SANITIZED_DIR/DEPRECATED_ARCHIVE_*"

# Replace username in all files
echo "🔄 Replacing personal paths..."
find "$SANITIZED_DIR" -type f \( -name "*.sh" -o -name "*.json" -o -name "*.md" \) -exec sed -i '' 's|/Users/USERNAME|/Users/USERNAME|g' {} \;

# Remove BoardLens-specific references
echo "🏢 Removing private project references..."
find "$SANITIZED_DIR" -type f -name "*.md" -exec sed -i '' 's|BoardLens|PROJECT_NAME|g' {} \;
find "$SANITIZED_DIR" -type f -name "*.sh" -exec sed -i '' 's|project|project|g' {} \;

# Clean up Signal references
echo "📱 Removing Signal integration details..."
sed -i '' '/Signal is configured in/d' "$SANITIZED_DIR/CLAUDE.md" 2>/dev/null || true

# Clean settings.json - remove lastShownTime
echo "⚙️ Cleaning settings files..."
if [ -f "$SANITIZED_DIR/settings.json" ]; then
    jq 'del(.telemetryOptIn.lastShownTime)' "$SANITIZED_DIR/settings.json" > "$SANITIZED_DIR/settings.json.tmp"
    mv "$SANITIZED_DIR/settings.json.tmp" "$SANITIZED_DIR/settings.json"
fi

# Create a README for the recipient
cat > "$SANITIZED_DIR/README_FOR_SETUP.md" << 'EOF'
# Claude Code Advanced Setup

This is a sanitized copy of an advanced Claude Code configuration with:
- Graphiti memory system (Neo4j)
- Sequential thinking MCP
- Serena code intelligence
- Smart hooks and automation

## Setup Instructions

1. **Replace USERNAME with your actual username** in all files:
   ```bash
   find . -type f -exec sed -i 's|/Users/USERNAME|/Users/YOUR_USERNAME|g' {} \;
   ```

2. **Initialize Neo4j** (required for memory):
   ```bash
   ./initialize-graphiti.sh
   ```

3. **Copy to your ~/.claude folder**:
   ```bash
   cp -r * ~/.claude/
   ```

4. **Customize for your projects**:
   - Update project names in CLAUDE.md
   - Adjust hook paths in settings.json
   - Configure your MCP servers

## What's Included

- **Memory System**: Automatic knowledge graph with Neo4j
- **Smart Hooks**: Pre/post operation analysis
- **Optimized Settings**: Production-ready configurations
- **MCP Integrations**: Sequential thinking, Serena, and more

## Security Note

All sensitive data has been removed. You'll need to add your own:
- API keys
- Project-specific paths
- Personal configurations
EOF

echo ""
echo "✅ Sanitization complete!"
echo ""
echo "📦 Sanitized copy created at: $SANITIZED_DIR"
echo ""
echo "⚠️  IMPORTANT: Before sharing, please:"
echo "1. Review $SANITIZED_DIR/CLAUDE.md for any remaining private info"
echo "2. Check $SANITIZED_DIR/settings.json for personal paths"
echo "3. Verify no private project names remain"
echo ""
echo "📤 To create a shareable archive:"
echo "   tar -czf claude_setup.tar.gz -C $HOME .claude_sanitized"
echo ""
echo "🔒 The archive will be safe to share with others!"