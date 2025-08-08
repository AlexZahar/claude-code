# Serena MCP Working Setup for Claude Code

## Problem Summary
Serena MCP was failing to connect due to a bug where it tried to load all projects from `~/.serena/serena_config.yml` and crashed when encountering missing or malformed project files with:
```
TypeError: 'str' object does not support item assignment
```

## Root Cause
The Serena config loader (line 239 in serena_config.py) assumes `yaml.safe_load()` always returns a dictionary, but it can return strings or None, causing the crash when it tries to assign `yaml_data["project_name"]`.

## Clean Solution

### 1. Disable Global Config
```bash
# Move the problematic global config out of the way
mv ~/.serena/serena_config.yml ~/.serena/serena_config.yml.disabled
```

### 2. Add Serena MCP with User Scope
```bash
claude mcp add serena --scope user -- uvx --from git+https://github.com/oraios/serena serena-mcp-server --context ide-assistant --enable-web-dashboard false
```

### 3. Verify Connection
```bash
claude mcp list | grep -i serena
# Should show: serena: ... - ✓ Connected
```

## How It Works

1. **No Global Config**: By disabling the global config, Serena starts in a clean state without trying to preload projects
2. **User Scope**: Makes Serena available across all terminal sessions
3. **IDE Context**: The `--context ide-assistant` optimizes Serena for Claude Code usage
4. **No Dashboard**: `--enable-web-dashboard false` prevents extra processes

## Project Configuration

Each project must have a `.serena/project.yml` file (NOT `.serena.project.yaml`):
- Correct: `project-root/.serena/project.yml`
- Wrong: `project-root/.serena.project.yaml`

## Usage in New Sessions

When you start a new Claude Code session:

1. **Activate Your Project** (when needed):
   ```
   Use Serena tool: activate_project with path /Users/USERNAME/Projects/boardlens/boardlens-frontend
   ```

2. **Load Instructions** (recommended):
   ```
   /mcp__serena__initial_instructions
   ```

## Benefits

- ✅ Works reliably across all terminal sessions
- ✅ No complex multi-project configuration needed
- ✅ Avoids the configuration bug entirely
- ✅ Projects activated on-demand, not preloaded
- ✅ Clean, minimal setup

## Alternative: Fix Your Existing Setup

If you prefer to keep using your boardlens-dev tool with multiple projects:

1. Ensure ALL projects in `~/.serena/serena_config.yml` have valid `.serena/project.yml` files
2. Each project.yml must be a valid YAML dictionary (not a string or empty)
3. Use the template from `/Users/USERNAME/Projects/mcp/serena/src/serena/resources/project.template.yml`

## Troubleshooting

If Serena stops connecting:
1. Check `claude mcp list` for the exact error
2. Temporarily disable global config again
3. Remove and re-add with the command above

## Notes

- This setup uses the latest Serena from GitHub
- The bug is known (GitHub issues #201, #323) but not yet fixed in the main branch
- This workaround is stable and recommended by other users facing similar issues