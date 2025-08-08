# 🎭 Playwright Hooks for Claude Code

## Overview
Comprehensive automation, security, and memory integration for web workflows using Playwright MCP.

## Features Implemented

### 🛡️ Security Hooks
- **URL Validation**: Blocks dangerous protocols (`file:`, `javascript:`, `data:`)
- **Domain Safety**: Prevents navigation to suspicious domains
- **Pre-navigation Security Checks**: Validates all URLs before access

### 📸 Visual Documentation  
- **Auto-Screenshots**: Captures before/after states of all interactions
- **Error Documentation**: Screenshots of failed states for debugging
- **Organized Storage**: `~/.claude/playwright-screenshots/` with auto-cleanup (30 days)

### 🧠 Memory Integration
- **Workflow Recording**: Saves successful automation sequences to Graphiti
- **Error Learning**: Documents failures for future reference
- **Searchable History**: All interactions stored with context

### 🧪 Test Generation
- **Auto-Test Creation**: Generates Playwright test files from successful workflows
- **Error Scenarios**: Includes negative test cases
- **Reusable Scripts**: Stored in `~/.claude/generated-tests/`

## Active Hooks

### PreToolUse Hooks
- **mcp__puppeteer__mcp-puppeteer_navigate**: Security validation + pre-navigation screenshot
- **mcp__puppeteer__mcp-puppeteer_click/fill/select**: Pre-interaction screenshots

### PostToolUse Hooks  
- **mcp__puppeteer__mcp-puppeteer_navigate**: Post-navigation documentation + performance analysis
- **mcp__puppeteer__mcp-puppeteer_click/fill/select/hover**: Post-interaction analysis + test generation
- **mcp__puppeteer__mcp-puppeteer_screenshot**: Memory logging of manual screenshots

## File Structure
```
~/.claude/
├── playwright-hooks.sh              # Main hook logic
├── playwright-test-generator.sh     # Test file generation
├── playwright-screenshots/          # Screenshot storage
└── generated-tests/                 # Auto-generated test files
```

## Manual Commands

### Test Generation
```bash
# Generate test from memory
~/.claude/playwright-test-generator.sh from-memory "login workflow"

# Manual test generation
~/.claude/playwright-test-generator.sh generate "checkout" "https://shop.com" "await page.click('.buy-btn')"
```

### Memory Search
```bash
# Find Playwright workflows
~/.claude/graphiti-hook.sh search "Playwright Success"

# Find specific interactions
~/.claude/graphiti-hook.sh search "navigate login"
```

### Screenshot Management
```bash
# View recent screenshots
ls -la ~/.claude/playwright-screenshots/

# Cleanup old screenshots manually
find ~/.claude/playwright-screenshots/ -name "*.png" -mtime +30 -delete
```

## How It Works

### Navigation Flow
1. **Pre-Navigate**: URL validation + security check + screenshot
2. **Navigate**: Playwright performs navigation  
3. **Post-Navigate**: Screenshot + performance analysis + memory save

### Interaction Flow
1. **Pre-Interact**: Screenshot of current state
2. **Interact**: Playwright performs action (click, fill, etc.)
3. **Post-Interact**: Screenshot + success detection + test generation + memory save

### Error Handling
- Failed interactions trigger error documentation
- Screenshots capture error states
- Error details saved to memory for learning
- No test generation for failed interactions

## Memory Integration

All successful workflows automatically saved with format:
- **Success**: `"Playwright Success: [action] on [url] - [details]"`
- **Error**: `"Playwright Error: [action] failed on [url] - [details]"`

## Security Features

### Blocked Protocols
- `file://` - Local file access
- `javascript://` - Script injection  
- `data://` - Data URLs
- `ftp://` - File transfer

### Suspicious Domain Detection
- Basic pattern matching for malware/phishing domains
- Expandable domain blocklist

## Performance Optimizations

- **Smart Screenshots**: Only taken at meaningful moments
- **Memory Batching**: Groups related operations
- **Auto-Cleanup**: Removes old screenshots automatically
- **Timeout Protection**: 10-minute timeout for memory operations

## Configuration

Edit `~/.claude/playwright-hooks.sh` to customize:
- Screenshot retention period (default: 30 days)
- Security validation rules
- Memory save patterns
- Performance analysis depth

## Integration with Existing Hooks

Playwright hooks work alongside your existing:
- **Gemini Hooks**: Code analysis and suggestions
- **Memory Hooks**: Graphiti knowledge graph integration  
- **Git Hooks**: Commit message generation

## Usage Examples

### Automated Documentation
Every web interaction is now documented:
- URL visited ✓
- Actions performed ✓  
- Success/failure status ✓
- Visual proof (screenshots) ✓
- Searchable memory ✓

### Test-Driven Development
Successful workflows automatically become test templates:
- Navigate to page ✓
- Perform interactions ✓
- Generate test assertions ✓
- Save reusable test files ✓

### Security-First Automation
All navigation pre-validated:
- Dangerous protocols blocked ✓
- Suspicious domains flagged ✓
- Security events logged ✓

## Troubleshooting

### Memory Timeouts
If memory saves timeout, check:
- Neo4j is running: `curl -s http://localhost:7474`
- Memory script exists: `ls -la ~/.claude/graphiti-hook.sh`

### Missing Screenshots
If screenshots aren't being taken:
- Check directory exists: `ls -la ~/.claude/playwright-screenshots/`
- Verify hook permissions: `ls -la ~/.claude/playwright-hooks.sh`

### Test Generation Issues
If tests aren't generating:
- Check output directory: `ls -la ~/.claude/generated-tests/`  
- Verify successful interactions in memory: `~/.claude/graphiti-hook.sh search "Playwright Success"`

## Next Steps

Future enhancements could include:
- **Visual Regression Testing**: Compare screenshots over time
- **Performance Monitoring**: Track page load metrics
- **Accessibility Auditing**: Automated a11y checks
- **Network Monitoring**: Log API calls during automation
- **Smart Selector Generation**: Learn optimal selectors from successful interactions