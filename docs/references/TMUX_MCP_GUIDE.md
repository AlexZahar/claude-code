# 🚀 Optimized tmux + MCP Setup Guide

## 🎯 What Changed

### Before (Memory Leak)
- Every `tm` command created a **new unique session**
- Session names: `projectname-PID-timestamp` (always different)
- Each session spawned new MCP servers
- No cleanup on detach
- Result: 50+ MCP servers, 10-20GB RAM usage

### After (Optimized)
- One tmux session per project directory
- Session names: Just the project name
- Sessions are reused when you return to a project
- Automatic cleanup on session close
- Smart MCP server management

## 📋 New Commands Reference

### tmux Commands

| Command | Description | Example |
|---------|-------------|---------|
| `tm` | Smart session create/attach | `cd ~/Projects/myapp && tm` |
| `tma` | Attach to session with fuzzy search | `tma` → select from list |
| `tml` | List all tmux sessions | `tml` |
| `tmk` | Kill current session + cleanup | `tmk` (when inside tmux) |
| `tmka` | Kill ALL sessions (nuclear option) | `tmka` |

### MCP Management

| Command | Description | When to Use |
|---------|-------------|-------------|
| `mcp status` or `mcps` | Show all MCP servers | Check what's running |
| `mcp clean` or `mcpc` | Clean zombie processes | After crashes |
| `mcp start` | Start global MCP servers | If globals stopped |
| `mcp stop` | Stop global MCP servers | Before system shutdown |

### Memory & Cleanup

| Command | Description | What it Does |
|---------|-------------|--------------|
| `mem` | Memory usage analysis | Shows MCP, Python, Node memory |
| `cleanup` | Smart cleanup | Cleans detached sessions + zombies |
| `cleanmcp` | Clean current session MCPs | Only affects current tmux |
| `cleantmux` | Nuclear cleanup | Kills ALL tmux + ALL MCPs |

## 🎮 Daily Workflow

### Starting Work
```bash
# Go to your project
cd ~/Projects/boardlens

# Start/attach tmux session (reuses existing)
tm

# Check MCP status
mcps

# Work with Claude
claude
```

### Switching Projects
```bash
# Just run tm in new directory
cd ~/Projects/other-project
tm  # Creates or attaches to 'other-project' session
```

### Ending Work
```bash
# Option 1: Detach (keeps session alive)
# Press: Ctrl+b, then d

# Option 2: Kill session (triggers cleanup)
tmk

# Option 3: Nuclear cleanup before shutdown
tmka  # Kills everything
```

## 🔧 Troubleshooting

### High Memory Usage?
```bash
# 1. Check what's running
mem

# 2. Smart cleanup
cleanup

# 3. If still high, nuclear option
cleantmux
```

### MCP Servers Not Responding?
```bash
# 1. Check status
mcps

# 2. Clean zombies
mcpc

# 3. Restart globals if needed
mcp restart
```

### Lost tmux Sessions?
```bash
# List all sessions
tml

# Attach with fuzzy search
tma
```

## 🏗️ Architecture

### Session Structure
```
Project Directory: ~/Projects/boardlens
     ↓
tmux Session: boardlens (one per project)
     ↓
MCP Servers:
  - Global (shared): filesystem, github, brave-search
  - Per-session: serena, sequential-thinking, graphiti
```

### Cleanup Flow
```
tmk (kill session)
     ↓
tmux session-closed hook
     ↓
cleanup-session.sh
     ↓
Kills session-specific MCPs
     ↓
Removes PID tracking files
```

## 💡 Best Practices

1. **One Session Per Project**: Let tmux reuse sessions
2. **Use `tmk` to Exit**: Ensures proper cleanup
3. **Regular Cleanup**: Run `cleanup` weekly
4. **Monitor Memory**: Use `mem` to check usage
5. **Don't Panic**: `tmka` fixes everything

## 🚨 Emergency Commands

```bash
# Everything is broken, fix it now:
tmka          # Kill all tmux
cleantmux     # Kill all processes
mcp restart   # Restart globals
mem           # Verify cleanup
```

## 📊 Expected Memory Usage

### Normal Operation
- Global MCPs: ~500MB total
- Per-session MCPs: ~1-2GB per active project
- Total with 2-3 projects: 2-4GB

### Warning Signs
- 10+ tmux sessions listed in `tml`
- 5GB+ shown in `mem`
- Multiple serena processes for same project
- Swap usage growing

## 🔄 Migration Steps

1. **Clean Current Mess**
   ```bash
   tmka
   cleantmux
   ```

2. **Reload Shell Config**
   ```bash
   source ~/.zshrc
   ```

3. **Start Fresh**
   ```bash
   cd ~/Projects/your-project
   tm  # Uses new smart session
   ```

4. **Verify**
   ```bash
   mcps  # Should show minimal servers
   mem   # Should show low usage
   ```

---

Remember: The key change is **session reuse**. No more unique sessions every time!