# Sequential Thinking - Graphiti Integration

This document describes the integration between MCP Sequential Thinking server and the Graphiti memory system.

## Overview

The integration enables structured reasoning chains from sequential thinking to be captured as interconnected memories in Graphiti, while also allowing sequential thinking to query historical context from Graphiti.

## Components

### 1. Sequential Graphiti Bridge (`sequential-graphiti-bridge.py`)

A standalone bridge that:
- Monitors the sequential thinking session file for changes
- Syncs each new thought to Graphiti with rich metadata
- Creates comprehensive session summaries
- Maintains state to avoid duplicate processing

**Features:**
- File watcher using `watchdog` library
- Thread-safe state management
- Automatic retry logic
- Session summary generation on exit

**Usage:**
```bash
# Start the bridge
python ~/.claude/sequential-graphiti-bridge.py

# The bridge will monitor ~/.mcp_sequential_thinking/current_session.json
# Press Ctrl+C to stop and generate session summary
```

### 2. Sequential Thinking Graphiti Hook (`sequential-thinking-graphiti-hook.py`)

A hook module for direct integration into the MCP server:
- Can be imported into a modified sequential thinking server
- Provides `on_thought_processed()` callback
- Enhances thoughts with related memories from Graphiti
- Creates session summaries automatically

**Integration Example:**
```python
from sequential_thinking_graphiti_hook import SequentialThinkingGraphitiHook

# Initialize hook
hook = SequentialThinkingGraphitiHook(auto_sync=True)

# In process_thought function
enhanced_thought = await hook.on_thought_processed(thought_data)

# In generate_summary function
await hook.on_summary_generated(summary_data)
```

## Memory Format

### Individual Thought Memory
```
[Sequential Thinking - {Stage}] {Thought content} | Tags: {tags} | Progress: {n}/{total}
```

### Session Summary Memory
```
[Sequential Thinking Session Summary]

Problem Definition:
  1. First thought...
  2. Second thought...

Analysis:
  1. Analysis thought...

Key Topics: integration, memory, architecture
Principles Used: LLM extraction, File monitoring
Total Thoughts: 8
Session ID: a1b2c3d4
```

## Benefits

1. **Persistent Reasoning Chains**: All sequential thinking sessions are preserved in Graphiti
2. **Context Enhancement**: Sequential thinking can access related historical memories
3. **Relationship Extraction**: Graphiti automatically extracts entities and relationships from thoughts
4. **Cross-Service Integration**: Bridges the gap between structured reasoning and memory systems
5. **Searchable History**: All thoughts become searchable through Graphiti's query interface

## Setup Instructions

### Option 1: Standalone Bridge

1. Ensure Neo4j is running for Graphiti
2. Start sequential thinking MCP server
3. Run the bridge:
   ```bash
   python ~/.claude/sequential-graphiti-bridge.py
   ```

### Option 2: Server Integration

1. Modify the sequential thinking server to import the hook
2. Add callbacks in appropriate functions
3. The integration will be automatic

## Configuration

- **Sequential Thinking Storage**: `~/.mcp_sequential_thinking/`
- **Bridge State File**: `~/.mcp_sequential_thinking/bridge_state.json`
- **Graphiti Group ID**: `claude-code-hooks`

## Future Enhancements

1. **Real-time Sync**: WebSocket connection for instant updates
2. **Thought Threading**: Link related thoughts across sessions
3. **Visual Graph**: Generate visual representations of reasoning chains
4. **Smart Summarization**: Use LLMs to create better session summaries
5. **Query Integration**: Allow sequential thinking to query Graphiti mid-session

## Example Workflow

1. Start a sequential thinking session
2. Bridge monitors and syncs each thought
3. Thoughts are enhanced with related memories
4. Session summary created on completion
5. All data searchable via Graphiti

This integration creates a powerful combination of structured reasoning and persistent memory, enabling more sophisticated AI reasoning capabilities.