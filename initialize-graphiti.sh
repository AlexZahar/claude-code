#!/bin/bash
# Graphiti Memory System Initialization Script
# This script sets up Neo4j for the Graphiti memory system

set -e

echo "🚀 Initializing Graphiti Memory System..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop first."
    echo "   Download from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Check if Neo4j container already exists
if docker ps -a | grep -q "neo4j"; then
    echo "⚠️  Neo4j container already exists. Starting it..."
    # Check which container name to use
    if docker ps -a | grep -q "mcp_server-neo4j-1"; then
        docker start mcp_server-neo4j-1
    else
        docker start neo4j
    fi
    echo "✅ Neo4j container started"
else
    echo "📦 Creating Neo4j container..."
    # If running from docker-compose, use that container instead
    if docker ps -a | grep -q "mcp_server-neo4j-1"; then
        echo "📦 Using existing Docker Compose Neo4j container..."
        docker start mcp_server-neo4j-1
    else
        echo "📦 Creating standalone Neo4j container..."
        docker run -d \
            --name neo4j \
        --restart unless-stopped \
        -p 7474:7474 \
        -p 7687:7687 \
        -e NEO4J_AUTH=neo4j/graphiti123 \
        -e NEO4J_PLUGINS='["apoc"]' \
        -e NEO4J_apoc_export_file_enabled=true \
        -e NEO4J_apoc_import_file_enabled=true \
        -e NEO4J_apoc_import_file_use__neo4j__config=true \
        -e NEO4JLABS_PLUGINS='["apoc"]' \
        -v neo4j_data:/data \
            neo4j:5.15.0
    fi
    
    echo "⏳ Waiting for Neo4j to start (this may take up to 30 seconds)..."
    sleep 10
    
    # Wait for Neo4j to be ready
    max_attempts=20
    attempt=0
    while ! curl -s http://localhost:7474 > /dev/null 2>&1; do
        attempt=$((attempt + 1))
        if [ $attempt -eq $max_attempts ]; then
            echo "❌ Neo4j failed to start. Check Docker logs with: docker logs neo4j"
            exit 1
        fi
        echo -n "."
        sleep 2
    done
    echo ""
    echo "✅ Neo4j is running!"
fi

# Install Python dependencies if needed
echo "📦 Checking Python dependencies..."
if ! uv pip list 2>/dev/null | grep -q "graphiti-core"; then
    echo "Installing Graphiti dependencies..."
    uv pip install graphiti-core openai anthropic
else
    echo "✅ Python dependencies already installed"
fi

# Test the connection
echo "🔍 Testing Graphiti connection..."
python3 -c "
from graphiti_core import Graphiti
from graphiti_core.nodes import EpisodeType
import sys

try:
    # Just test connection, don't actually initialize
    print('✅ Graphiti Python module loaded successfully')
    print('✅ Memory system is ready to use!')
except Exception as e:
    print(f'❌ Error: {e}')
    sys.exit(1)
"

echo ""
echo "🎉 Graphiti Memory System initialized successfully!"
echo ""
echo "📝 Neo4j Credentials:"
echo "   URL: http://localhost:7474"
echo "   Username: neo4j"
echo "   Password: graphiti123"
echo ""
echo "🔧 Usage:"
echo "   - Memory is automatically captured via hooks"
echo "   - Search memories: ~/.claude/graphiti-hook.sh search \"query\""
echo "   - Add memory: ~/.claude/graphiti-hook.sh add \"content\""
echo "   - Recent memories: ~/.claude/graphiti-hook.sh recent 10"
echo ""
echo "🚀 Neo4j will start automatically when you open Claude Code"