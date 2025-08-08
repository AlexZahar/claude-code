# Serena Tool Statistics Configuration Guide

## Overview

Serena can track tool usage statistics, including:
- Number of times each tool is called
- Input token counts
- Output token counts
- Performance metrics

These statistics are displayed in the Serena web dashboard.

## Configuration

### 1. Enable Tool Stats Collection

In `~/.serena/serena_config.yml`, add:

```yaml
# Enable tool usage statistics
record_tool_usage_stats: true

# Token count estimator for stats (default is TIKTOKEN_GPT4O)
token_count_estimator: TIKTOKEN_GPT4O
```

### 2. Token Count Estimators

Available options:
- `TIKTOKEN_GPT4O` (default) - Fast, offline estimation
- `ANTHROPIC_CLAUDE_SONNET_4` - Exact count via Anthropic API (requires API key)

### 3. View Statistics

Once enabled:
1. Restart Claude Code / Serena MCP server
2. Open Serena dashboard: http://localhost:24282/dashboard/
3. Navigate to "Tool Stats" tab
4. View usage statistics for each tool

## Complete Configuration Example

```yaml
projects:
- /Users/USERNAME/Projects/boardlens/boardlens-backend
- /Users/USERNAME/Projects/boardlens/boardlens-frontend
- /Users/USERNAME/Projects/boardlens/boardlens-python-api
- /Users/USERNAME/Projects/boardlens/boardlens-rag

default_modes:
- interactive
- editing

# Context for IDE assistance
context: ide-assistant

# Enable web dashboard
enable_web_dashboard: true
web_dashboard_open_on_launch: true

# Tool configuration
tool_timeout: 30.0

# Enable tool usage statistics
record_tool_usage_stats: true

# Token count estimator for stats
token_count_estimator: TIKTOKEN_GPT4O
```

## Features

### In the Dashboard

When tool stats are enabled, you can:
- See which tools are used most frequently
- Monitor token usage per tool
- Identify expensive operations
- Track performance over time
- Clear statistics with a button

### API Endpoints

The dashboard exposes:
- `/get_tool_stats` - Get current statistics
- `/clear_tool_stats` - Reset statistics
- `/get_token_count_estimator_name` - Check which estimator is used

## Important Notes

1. **First Run**: TIKTOKEN_GPT4O may download tokenizer data on first use
2. **Performance**: Minimal overhead, stats are collected asynchronously
3. **Storage**: Statistics are kept in memory, cleared on restart
4. **Privacy**: All statistics are local, nothing is sent externally

## Troubleshooting

### "No tool stats collected"
- Ensure `record_tool_usage_stats: true` in config
- Restart Serena/Claude Code after changing config
- Check dashboard logs for errors

### Token counts seem wrong
- TIKTOKEN provides estimates, not exact counts
- For exact counts, use ANTHROPIC estimator (requires API key)

### Dashboard not showing stats
- Verify web dashboard is enabled
- Check URL: http://localhost:24282/dashboard/
- Look for "Tool Stats" tab in dashboard

## Benefits

1. **Optimization**: Identify which tools consume most tokens
2. **Debugging**: Track tool usage patterns
3. **Cost Analysis**: Estimate API costs based on token usage
4. **Performance**: Monitor tool execution frequency

## Implementation Details

From the Serena codebase:
- Stats collection in `src/serena/analytics.py`
- Dashboard integration in `src/serena/dashboard.py`
- Agent integration in `src/serena/agent.py` (line 159-162)

The configuration is now active in your `~/.serena/serena_config.yml`!