#!/bin/bash

# Neo4j initialization check for Claude Code sessions
# This hook ensures Neo4j is always available for memory operations

LOG_FILE="/Users/USERNAME/.claude/neo4j-startup.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if Neo4j is running
check_neo4j() {
    # Try to connect to Neo4j
    if curl -s http://localhost:7474 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Initialize Neo4j if not running
initialize_neo4j() {
    log_message "Checking Neo4j status..."
    
    if check_neo4j; then
        log_message "Neo4j is already running"
        echo "✓ Neo4j is running - memory system ready"
    else
        log_message "Neo4j is not running, attempting to start..."
        
        # Check if Docker is running and Neo4j container exists
        if command -v docker >/dev/null 2>&1; then
            # Check for both possible container names
            NEO4J_CONTAINER=""
            if docker ps -a | grep -q " neo4j$"; then
                NEO4J_CONTAINER="neo4j"
            elif docker ps -a | grep -q "mcp_server-neo4j-1"; then
                NEO4J_CONTAINER="mcp_server-neo4j-1"
            fi
            
            if [ -n "$NEO4J_CONTAINER" ]; then
                # Start the container if it exists but is stopped
                docker start $NEO4J_CONTAINER >/dev/null 2>&1
                sleep 5
                
                if check_neo4j; then
                    log_message "Neo4j container started successfully"
                    echo "✓ Started Neo4j container - memory system ready"
                else
                    log_message "Failed to start Neo4j container"
                    echo "⚠️  Neo4j startup failed - run: docker start neo4j"
                fi
            else
                log_message "Neo4j container not found"
                echo "⚠️  Neo4j not setup - run: /Users/USERNAME/.claude/initialize-graphiti.sh"
            fi
        else
            log_message "Docker not available, checking for native Neo4j"
            # Check for native Neo4j installation
            if command -v neo4j >/dev/null 2>&1; then
                neo4j start >/dev/null 2>&1
                sleep 5
                
                if check_neo4j; then
                    log_message "Native Neo4j started successfully"
                    echo "✓ Started Neo4j - memory system ready"
                else
                    log_message "Failed to start native Neo4j"
                    echo "⚠️  Neo4j startup failed - check logs"
                fi
            else
                log_message "Neo4j not installed"
                echo "⚠️  Neo4j not found - run: /Users/USERNAME/.claude/initialize-graphiti.sh"
            fi
        fi
    fi
}

# Main execution
initialize_neo4j

# Add initial session memory if Neo4j is running
if check_neo4j; then
    # Add session start memory (silently, no output unless error)
    /Users/USERNAME/.claude/memory-subagent-request.sh "Claude Code session started - Neo4j initialized successfully" normal >/dev/null 2>&1
fi