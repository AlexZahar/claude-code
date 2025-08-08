#!/Users/zahar/Projects/mcp/graphiti/mcp_server/.venv/bin/python3
"""
Graphiti Memory Bridge for Claude Code
======================================

This script provides a bridge between Claude Code hooks and the Graphiti memory system.
Since the MCP integration has protocol issues, this script can be called from hooks
to programmatically add memories to Graphiti.

Usage:
    python graphiti-memory-bridge.py add "Memory content here"
    python graphiti-memory-bridge.py search "search query"
    python graphiti-memory-bridge.py status
"""

import os
import sys
import asyncio
import json
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, Any

# Add the Graphiti path if it exists
graphiti_paths = [
    Path.home() / "Projects/mcp/graphiti",
    Path.home() / "Projects/mcp/graphiti/mcp_server",
    Path.home() / "Projects/graphiti"
]

for path in graphiti_paths:
    if path.exists():
        sys.path.insert(0, str(path))

try:
    from graphiti_core import Graphiti
    from graphiti_core.utils import clear_data
    GRAPHITI_AVAILABLE = True
except ImportError:
    GRAPHITI_AVAILABLE = False
    print("Warning: Graphiti not available. Using fallback memory system.")

# Configuration
NEO4J_URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "demodemo")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
MODEL_NAME = os.getenv("MODEL_NAME", "gpt-4o-mini")
GROUP_ID = os.getenv("GROUP_ID", "claude-code-memories")

# Fallback memory directory
FALLBACK_MEMORY_DIR = Path.home() / ".claude" / "graphiti-memories"
FALLBACK_MEMORY_DIR.mkdir(parents=True, exist_ok=True)


class MemoryBridge:
    def __init__(self):
        self.client = None
        if GRAPHITI_AVAILABLE and OPENAI_API_KEY:
            try:
                self.client = Graphiti(
                    uri=NEO4J_URI,
                    user=NEO4J_USER,
                    password=NEO4J_PASSWORD,
                    model_name=MODEL_NAME,
                    group_id=GROUP_ID
                )
            except Exception as e:
                print(f"Failed to initialize Graphiti: {e}")
                self.client = None

    async def add_memory(self, content: str, metadata: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Add a memory to Graphiti or fallback system"""
        timestamp = datetime.now().isoformat()
        
        if self.client:
            try:
                # Add to Graphiti
                result = await self.client.add_episode(
                    episode_content=content,
                    timestamp=timestamp,
                    metadata=metadata or {}
                )
                return {
                    "status": "success",
                    "type": "graphiti",
                    "message": "Memory added to Graphiti knowledge graph",
                    "timestamp": timestamp,
                    "group_id": GROUP_ID
                }
            except Exception as e:
                print(f"Graphiti error: {e}")
                # Fall through to fallback
        
        # Fallback: Save to local file
        memory_file = FALLBACK_MEMORY_DIR / f"memory_{timestamp.replace(':', '-')}.json"
        memory_data = {
            "content": content,
            "timestamp": timestamp,
            "metadata": metadata or {},
            "group_id": GROUP_ID
        }
        
        with open(memory_file, 'w') as f:
            json.dump(memory_data, f, indent=2)
        
        return {
            "status": "success",
            "type": "fallback",
            "message": f"Memory saved to {memory_file}",
            "timestamp": timestamp
        }

    async def search_memories(self, query: str, limit: int = 10) -> Dict[str, Any]:
        """Search memories in Graphiti or fallback system"""
        if self.client:
            try:
                # Search nodes
                nodes = await self.client.search_nodes(
                    query=query,
                    limit=limit,
                    group_id=GROUP_ID
                )
                
                # Search facts
                facts = await self.client.search_facts(
                    query=query,
                    limit=limit,
                    group_id=GROUP_ID
                )
                
                return {
                    "status": "success",
                    "type": "graphiti",
                    "nodes": [{"name": n.name, "summary": n.summary} for n in nodes],
                    "facts": [{"fact": f.fact, "confidence": f.confidence} for f in facts],
                    "total_results": len(nodes) + len(facts)
                }
            except Exception as e:
                print(f"Graphiti search error: {e}")
        
        # Fallback: Search local files
        results = []
        for memory_file in FALLBACK_MEMORY_DIR.glob("memory_*.json"):
            try:
                with open(memory_file) as f:
                    data = json.load(f)
                    if query.lower() in data["content"].lower():
                        results.append({
                            "content": data["content"],
                            "timestamp": data["timestamp"],
                            "file": str(memory_file.name)
                        })
            except Exception:
                continue
        
        return {
            "status": "success",
            "type": "fallback",
            "results": results[:limit],
            "total_results": len(results)
        }

    async def get_status(self) -> Dict[str, Any]:
        """Get status of memory system"""
        status = {
            "graphiti_available": GRAPHITI_AVAILABLE,
            "graphiti_connected": False,
            "neo4j_uri": NEO4J_URI,
            "model": MODEL_NAME,
            "group_id": GROUP_ID,
            "fallback_memories": len(list(FALLBACK_MEMORY_DIR.glob("memory_*.json")))
        }
        
        if self.client:
            try:
                # Test connection
                await self.client.search_nodes("test", limit=1)
                status["graphiti_connected"] = True
            except Exception:
                pass
        
        return status


async def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    command = sys.argv[1]
    bridge = MemoryBridge()
    
    if command == "add":
        if len(sys.argv) < 3:
            print("Usage: graphiti-memory-bridge.py add \"Memory content\"")
            sys.exit(1)
        
        content = " ".join(sys.argv[2:])
        result = await bridge.add_memory(content)
        print(json.dumps(result, indent=2))
    
    elif command == "search":
        if len(sys.argv) < 3:
            print("Usage: graphiti-memory-bridge.py search \"query\"")
            sys.exit(1)
        
        query = " ".join(sys.argv[2:])
        result = await bridge.search_memories(query)
        print(json.dumps(result, indent=2))
    
    elif command == "status":
        result = await bridge.get_status()
        print(json.dumps(result, indent=2))
    
    else:
        print(f"Unknown command: {command}")
        print("Available commands: add, search, status")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())