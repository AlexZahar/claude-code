# MCP Investigation Results: Graphiti vs OpenMemory

## Executive Summary

After extensive investigation, the root cause is a **Claude Desktop bug**, not an issue with either Graphiti or OpenMemory MCP servers. Claude Desktop doesn't properly send the required `notifications/initialized` message, causing FastMCP-based servers to reject requests.

## Root Cause Analysis

### The Problem
1. **MCP Protocol Requirement**: After initialization, the client MUST send `notifications/initialized`
2. **Claude Desktop Bug**: It often skips this notification or sends requests too quickly
3. **FastMCP Enforcement**: FastMCP strictly enforces the protocol, rejecting premature requests
4. **Result**: "Received request before initialization was complete" error

### Why Some Servers Work
- They use older MCP SDK versions (1.8.x) with different requirements
- They implement workarounds or less strict validation
- They use direct SDK instead of FastMCP framework

## Graphiti vs OpenMemory Comparison

### Graphiti
**Pros:**
- Temporal knowledge graph with Neo4j backend
- Sophisticated entity extraction and relationships
- Time-aware memory (episodes have timestamps)
- Advanced search with semantic understanding
- Production-ready with Zep backing

**Cons:**
- Requires Neo4j database
- More complex setup
- Higher resource usage
- Currently incompatible with Claude Desktop due to bug

### OpenMemory (Mem0)
**Pros:**
- Simpler key-value memory model
- Multiple backend options (SQLite, PostgreSQL, Qdrant)
- Easier setup and lower resource usage
- May work with Claude Desktop (uses MCP 1.3.0)

**Cons:**
- Less sophisticated than knowledge graphs
- No temporal awareness
- Limited relationship modeling
- Simpler search capabilities

## Pragmatic Recommendations

### 1. **Immediate Solution: Keep Current Hook Implementation**
Your hook-based Graphiti integration is actually **better** than MCP because:
- It works TODAY without waiting for bug fixes
- Direct API access is more reliable
- Full control over memory operations
- No protocol limitations

### 2. **Don't Switch to OpenMemory**
- It offers fewer features than Graphiti
- Still might have the same MCP issues
- Your current solution already works

### 3. **Community Consensus**
Based on Reddit/GitHub discussions:
- Many developers bypass MCP for critical features
- Direct integrations are more stable
- MCP is still maturing as a protocol

### 4. **Long-term Strategy**
- Keep your hook implementation as primary
- Monitor MCP protocol updates
- Test new Claude Desktop releases
- Consider MCP when it matures

## Technical Details

### Working MCP Servers (as of 2025)
1. Filesystem server (official)
2. GitHub server (official)
3. SQLite server
4. DesktopCommander
5. Sequential Thinking

### What Makes Them Work
- Use stdio transport (not SSE)
- Simple tool interfaces
- Less strict initialization
- Official SDK implementations

### The MCP Handshake Issue
```json
// What should happen:
→ Client: {"method": "initialize", ...}
← Server: {"result": {"capabilities": ...}}
→ Client: {"method": "notifications/initialized"}  // Claude skips this!
→ Client: {"method": "tools/list", ...}

// What Claude does:
→ Client: {"method": "initialize", ...}
← Server: {"result": {"capabilities": ...}}
→ Client: {"method": "tools/list", ...}  // Too early!
← Server: ERROR: "Received request before initialization"
```

## Conclusion

**Your current hook-based Graphiti implementation is the pragmatic choice.**

Why:
1. It works reliably NOW
2. Provides superior features (knowledge graph > key-value store)
3. Avoids protocol bugs
4. Gives you full control

The MCP ecosystem is promising but still immature. Your solution bypasses these growing pains while delivering the functionality you need today.

**Bottom line**: Don't change what's working. You've built a robust solution that's better than waiting for protocol fixes.