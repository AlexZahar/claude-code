# Active Memory System Files

## Core Components (Keep These)

### Main Scripts
- `graphiti-hook.sh` - Main memory interface with smart filtering
- `graphiti-direct-hook.py` - Python integration with Graphiti
- `smart_memory_assessor.py` - Intelligent importance assessment
- `graphiti-batcher.py` - Batches operations for efficiency
- `memory-preprocessor.sh` - Handles large content chunking

### Configuration
- `memory-config.json` - Filtering and batching configuration
- `settings.json` - Hooks configuration (NOT hooks.json)

### Active Hooks
- `compact-memory-hook.sh` - Saves conversation summaries on /compact

### Support Files
- `graphiti-memory-bridge.py` - Alternative bridge (kept as fallback)
- `graphiti-flush.sh` - Manual batch flush utility
- `initialize-graphiti.sh` - Neo4j/Graphiti setup script

### Documentation
- `MEMORY_SYSTEM_CLARIFICATION.md` - Current accurate documentation
- `PROPOSED_MEMORY_HOOKS.json` - Ready-to-add hook configurations

## Archived (Historical Reference)
- `deprecated-memory-system-20250723/` - Old queue-based system
- `deprecated-memory-system-20250730/` - Previous MCP attempts
- `legacy-memory-scripts-archive-20250802/` - Legacy scripts
- `memory_fallbacks/` - Fallback storage when Graphiti unavailable

## Removed Files (No Longer Needed)
- ✅ `hooks.json.*` - Misleading configuration files
- ✅ `memory-subagent-request.sh` - Non-functional subagent trigger
- ✅ `memory-hook-lightweight.sh` - Unused alternative
- ✅ `example-memory-hooks.json` - Just examples
- ✅ `test_memory_hook.py` - Test files
- ✅ Various `.backup` and `.original` files
- ✅ Old Python hook versions (`graphiti-direct-hook-enhanced*.py`)
- ✅ Emergency fix scripts
- ✅ Old documentation files

## Current Status
- Neo4j starts automatically ✅
- Manual memory saves work ✅
- Automatic capture NOT enabled (needs hooks in settings.json) ❌
- Task agent available for async operations ✅