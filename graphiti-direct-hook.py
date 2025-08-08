#!/usr/bin/env python3
"""
Enhanced Graphiti Hook - Production Version
===========================================
Adds structured metadata tags to content for enhanced searchability
while maintaining backward compatibility and performance.
"""

import asyncio
import os
import sys
import json
import re
from datetime import datetime
from typing import Optional, Dict, Any, List
from pathlib import Path

from graphiti_core import Graphiti
from graphiti_core.llm_client.openai_client import OpenAIClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.openai import OpenAIEmbedder, OpenAIEmbedderConfig
from graphiti_core.nodes import EpisodeType

# Configuration from environment
NEO4J_URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "demodemo")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
if not OPENAI_API_KEY:
    raise ValueError("OPENAI_API_KEY environment variable is required")
MODEL_NAME = os.getenv("MODEL_NAME", "gpt-4o-mini")
EMBEDDER_MODEL = os.getenv("EMBEDDER_MODEL_NAME", "text-embedding-3-small")
GROUP_ID = os.getenv("GROUP_ID", "claude-code-hooks")
MAX_COROUTINES = int(os.getenv("SEMAPHORE_LIMIT", "10"))


def extract_simple_metadata(content: str) -> Dict[str, Any]:
    """Extract basic metadata from content without complex processing"""
    
    # Detect memory type
    content_lower = content.lower()
    if any(word in content_lower for word in ["bug", "fix", "error", "issue", "resolved"]):
        memory_type = "bug_fix"
        priority = "high" if "critical" in content_lower or "security" in content_lower else "medium"
    elif any(word in content_lower for word in ["feature", "implement", "add", "create"]):
        memory_type = "feature"
        priority = "medium"
    elif any(word in content_lower for word in ["refactor", "optimize", "improve", "cleanup"]):
        memory_type = "refactor"
        priority = "low"
    elif any(word in content_lower for word in ["discover", "found", "insight", "learn"]):
        memory_type = "discovery"
        priority = "medium"
    else:
        memory_type = "general"
        priority = "medium"
    
    # Extract project from [project] tag
    project = "general"
    project_match = re.search(r'\[([^\]]+)\]', content)
    if project_match:
        project = project_match.group(1)
    
    # Extract simple tech keywords
    tech_keywords = []
    simple_techs = ["react", "node", "python", "jwt", "mongodb", "docker", "git", "npm"]
    for tech in simple_techs:
        if tech in content_lower:
            tech_keywords.append(tech)
    
    return {
        "type": memory_type,
        "priority": priority,
        "project": project,
        "techs": tech_keywords[:3]  # Limit to 3 to keep it simple
    }


def enhance_content_with_metadata(content: str, metadata: Dict[str, Any]) -> str:
    """Add metadata tags to content for enhanced searchability"""
    
    # Add simple metadata suffix
    tags = []
    tags.append(f"#type:{metadata['type']}")
    tags.append(f"#priority:{metadata['priority']}")
    
    for tech in metadata.get('techs', []):
        tags.append(f"#tech:{tech}")
    
    # Add tags to end of content
    enhanced = f"{content} | {' '.join(tags)}"
    
    return enhanced


async def add_memory_to_graph(content: str, source: str = "claude-code-hook") -> Dict[str, Any]:
    """Add a memory directly to Graphiti graph database with enhanced metadata"""
    try:
        # Create LLM client
        llm_config = LLMConfig(
            api_key=OPENAI_API_KEY,
            model=MODEL_NAME,
            temperature=0.0
        )
        llm_client = OpenAIClient(config=llm_config)
        
        # Create embedder client
        embedder_config = OpenAIEmbedderConfig(
            api_key=OPENAI_API_KEY,
            embedding_model=EMBEDDER_MODEL
        )
        embedder_client = OpenAIEmbedder(config=embedder_config)
        
        # Initialize Graphiti client
        client = Graphiti(
            uri=NEO4J_URI,
            user=NEO4J_USER,
            password=NEO4J_PASSWORD,
            llm_client=llm_client,
            embedder=embedder_client,
            max_coroutines=MAX_COROUTINES
        )
        
        # Extract and add metadata
        metadata = extract_simple_metadata(content)
        enhanced_content = enhance_content_with_metadata(content, metadata)
        
        # Add episode to graph
        timestamp = datetime.now()
        result = await client.add_episode(
            name=f"Claude Code Memory",
            episode_body=enhanced_content,
            source=EpisodeType.text,
            source_description=f"Added via {source} at {timestamp}",
            reference_time=timestamp,
            group_id=GROUP_ID,
            entity_types={}  # No custom entities for performance
        )
        
        return {
            "success": True,
            "message": "Memory added to Graphiti knowledge graph",
            "group_id": GROUP_ID,
            "timestamp": timestamp.isoformat(),
            "episode_id": str(result) if result else "unknown",
            "metadata": metadata
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "message": f"Failed to add to Graphiti: {e}"
        }


async def search_graph_memories(query: str, limit: int = 10) -> Dict[str, Any]:
    """Search memories in Graphiti graph database"""
    try:
        # Create LLM client
        llm_config = LLMConfig(
            api_key=OPENAI_API_KEY,
            model=MODEL_NAME,
            temperature=0.0
        )
        llm_client = OpenAIClient(config=llm_config)
        
        # Create embedder client
        embedder_config = OpenAIEmbedderConfig(
            api_key=OPENAI_API_KEY,
            embedding_model=EMBEDDER_MODEL
        )
        embedder_client = OpenAIEmbedder(config=embedder_config)
        
        # Initialize Graphiti client
        client = Graphiti(
            uri=NEO4J_URI,
            user=NEO4J_USER,
            password=NEO4J_PASSWORD,
            llm_client=llm_client,
            embedder=embedder_client,
            max_coroutines=MAX_COROUTINES
        )
        
        # Use the unified search method
        results = await client.search(
            query=query,
            num_results=limit,
            group_ids=[GROUP_ID]
        )
        
        return {
            "success": True,
            "results": [
                {
                    "fact": edge.fact,
                    "source": edge.source_node_uuid,
                    "target": edge.target_node_uuid,
                    "created_at": str(edge.created_at) if hasattr(edge, 'created_at') else None
                }
                for edge in results
            ],
            "total_results": len(results),
            "group_id": GROUP_ID
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "message": f"Search failed: {e}"
        }


async def get_recent_episodes(limit: int = 10) -> Dict[str, Any]:
    """Get recent episodes from the graph with metadata extraction"""
    try:
        # Create LLM client
        llm_config = LLMConfig(
            api_key=OPENAI_API_KEY,
            model=MODEL_NAME,
            temperature=0.0
        )
        llm_client = OpenAIClient(config=llm_config)
        
        # Create embedder client
        embedder_config = OpenAIEmbedderConfig(
            api_key=OPENAI_API_KEY,
            embedding_model=EMBEDDER_MODEL
        )
        embedder_client = OpenAIEmbedder(config=embedder_config)
        
        # Initialize Graphiti client
        client = Graphiti(
            uri=NEO4J_URI,
            user=NEO4J_USER,
            password=NEO4J_PASSWORD,
            llm_client=llm_client,
            embedder=embedder_client,
            max_coroutines=MAX_COROUTINES
        )
        
        # Query recent episodes
        query = """
        MATCH (n)
        WHERE n.group_id = $group_id 
        AND n.name = 'Claude Code Memory'
        RETURN n
        ORDER BY n.created_at DESC
        LIMIT $limit
        """
        
        result = await client.driver.execute_query(
            query,
            group_id=GROUP_ID,
            limit=limit
        )
        
        episodes = []
        for record in result.records:
            node = record['n']
            timestamp = node.get('created_at', 'unknown')
            if hasattr(timestamp, 'isoformat'):
                timestamp = timestamp.isoformat()
            elif timestamp != 'unknown':
                timestamp = str(timestamp)
            
            content = node.get('content', 'No content')
            
            # Extract metadata from tags if present
            metadata = {}
            if "#type:" in content:
                type_match = re.search(r'#type:(\w+)', content)
                if type_match:
                    metadata['type'] = type_match.group(1)
            if "#priority:" in content:
                priority_match = re.search(r'#priority:(\w+)', content)
                if priority_match:
                    metadata['priority'] = priority_match.group(1)
            
            episode_data = {
                "content": content,
                "timestamp": timestamp,
                "source": node.get('source_description', 'unknown'),
                "name": node.get('name', 'Unknown')
            }
            
            if metadata:
                episode_data["metadata"] = metadata
                
            episodes.append(episode_data)
        
        return {
            "success": True,
            "episodes": episodes,
            "count": len(episodes),
            "group_id": GROUP_ID
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "message": f"Failed to get episodes: {e}"
        }


# Keep backward compatibility function
async def delete_astralis_memories(dry_run: bool = True) -> Dict[str, Any]:
    """Delete specific Astralis PM Next memories from the graph database"""
    try:
        # Create LLM client
        llm_config = LLMConfig(
            api_key=OPENAI_API_KEY,
            model=MODEL_NAME,
            temperature=0.0
        )
        llm_client = OpenAIClient(config=llm_config)
        
        # Create embedder client
        embedder_config = OpenAIEmbedderConfig(
            api_key=OPENAI_API_KEY,
            embedding_model=EMBEDDER_MODEL
        )
        embedder_client = OpenAIEmbedder(config=embedder_config)
        
        # Initialize Graphiti client
        client = Graphiti(
            uri=NEO4J_URI,
            user=NEO4J_USER,
            password=NEO4J_PASSWORD,
            llm_client=llm_client,
            embedder=embedder_client,
            max_coroutines=MAX_COROUTINES
        )
        
        # Find all nodes containing astralis_pm_next
        query = """
        MATCH (n)
        WHERE n.group_id = $group_id 
        AND (n.content CONTAINS '[astralis_pm_next]' OR n.episode_body CONTAINS '[astralis_pm_next]')
        RETURN n.uuid as uuid, n.content as content, n.episode_body as episode_body, 
               n.created_at as created_at, n.name as name, labels(n) as labels
        ORDER BY n.created_at DESC
        """
        
        result = await client.driver.execute_query(
            query,
            group_id=GROUP_ID
        )
        
        astralis_nodes = []
        for record in result.records:
            content = record.get('content', '') or record.get('episode_body', '')
            timestamp = record.get('created_at', 'unknown')
            if hasattr(timestamp, 'isoformat'):
                timestamp = timestamp.isoformat()
            elif timestamp != 'unknown':
                timestamp = str(timestamp)
            
            astralis_nodes.append({
                "uuid": record['uuid'],
                "content": content,
                "timestamp": timestamp,
                "name": record.get('name', 'Unknown'),
                "labels": record.get('labels', [])
            })
        
        if not astralis_nodes:
            return {
                "success": True,
                "message": "No Astralis memories found",
                "nodes_found": 0,
                "nodes_deleted": 0
            }
        
        if dry_run:
            return {
                "success": True,
                "message": f"Found {len(astralis_nodes)} Astralis memories (DRY RUN)",
                "nodes_found": len(astralis_nodes),
                "nodes_deleted": 0,
                "nodes": astralis_nodes
            }
        
        # Delete the nodes and their relationships
        deleted_count = 0
        for node in astralis_nodes:
            delete_query = """
            MATCH (n {uuid: $uuid})
            DETACH DELETE n
            RETURN count(n) as deleted
            """
            
            delete_result = await client.driver.execute_query(
                delete_query,
                uuid=node['uuid']
            )
            
            if delete_result.records and delete_result.records[0]['deleted'] > 0:
                deleted_count += 1
        
        return {
            "success": True,
            "message": f"Deleted {deleted_count} of {len(astralis_nodes)} Astralis memories",
            "nodes_found": len(astralis_nodes),
            "nodes_deleted": deleted_count
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "message": f"Failed to delete Astralis memories: {e}"
        }


async def main():
    """Main entry point for hook calls"""
    if len(sys.argv) < 2:
        print(json.dumps({
            "error": "No command specified",
            "usage": "graphiti-direct-hook.py {add|search|recent|delete-astralis} [args...]"
        }))
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "add":
        if len(sys.argv) < 3:
            print(json.dumps({"error": "No content provided for add command"}))
            sys.exit(1)
        
        content = " ".join(sys.argv[2:])
        result = await add_memory_to_graph(content)
        print(json.dumps(result, indent=2))
    
    elif command == "search":
        if len(sys.argv) < 3:
            print(json.dumps({"error": "No query provided for search command"}))
            sys.exit(1)
        
        query = " ".join(sys.argv[2:])
        result = await search_graph_memories(query)
        print(json.dumps(result, indent=2))
    
    elif command == "recent":
        limit = int(sys.argv[2]) if len(sys.argv) > 2 else 10
        result = await get_recent_episodes(limit)
        print(json.dumps(result, indent=2))
    
    elif command == "delete-astralis":
        dry_run = True
        if len(sys.argv) > 2 and sys.argv[2] == "--confirm":
            dry_run = False
        result = await delete_astralis_memories(dry_run)
        print(json.dumps(result, indent=2))
    
    else:
        print(json.dumps({
            "error": f"Unknown command: {command}",
            "available_commands": ["add", "search", "recent", "delete-astralis"]
        }))
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())