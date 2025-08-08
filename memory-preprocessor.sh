#!/bin/bash
# Memory Preprocessor - Chunks large content before sending to Graphiti

set -e

# Configuration
MAX_TOKENS=800
CHUNK_OVERLAP=100
TEMP_DIR="/tmp/memory_chunks"

# Function to chunk content semantically
chunk_content() {
    local content="$1"
    local chunk_size="$2"
    
    # Create temp directory
    mkdir -p "$TEMP_DIR"
    
    # Use Python to chunk semantically
    python3 << EOF
import sys
import re
import json

content = """$content"""
max_tokens = $chunk_size
overlap_tokens = $CHUNK_OVERLAP

# Rough tokenization (4 chars ≈ 1 token)
max_chars = max_tokens * 4
overlap_chars = overlap_tokens * 4

# Split on sentence boundaries first
sentences = re.split(r'(?<=[.!?])\s+', content)
chunks = []
current_chunk = ""

for sentence in sentences:
    # If adding this sentence would exceed max, start new chunk
    if len(current_chunk) + len(sentence) > max_chars and current_chunk:
        chunks.append(current_chunk.strip())
        # Start new chunk with overlap
        current_chunk = sentence
    else:
        current_chunk += " " + sentence if current_chunk else sentence

# Add final chunk
if current_chunk.strip():
    chunks.append(current_chunk.strip())

# Output chunks as JSON array
print(json.dumps(chunks))
EOF
}

# Function to create structured memory
create_structured_memory() {
    local chunk="$1"
    local chunk_num="$2"
    local total_chunks="$3"
    local context="$4"
    
    # Use GPT to create structured summary
    local structured_memory=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"gpt-4o-mini\",
            \"messages\": [{
                \"role\": \"system\",
                \"content\": \"Extract key information for memory storage. Focus on: actions taken, decisions made, problems solved, important discoveries. Keep under 300 tokens. Format as: [TYPE] Description with context.\"
            }, {
                \"role\": \"user\",
                \"content\": \"Context: $context\\n\\nChunk $chunk_num of $total_chunks:\\n$chunk\"
            }],
            \"max_tokens\": 300,
            \"temperature\": 0.3
        }" | jq -r '.choices[0].message.content')
    
    echo "$structured_memory"
}

# Main processing function
process_large_memory() {
    local original_content="$1"
    local context="${2:-"General session work"}"
    
    echo "Processing large memory ($(echo "$original_content" | wc -c) chars)..."
    
    # Check if content needs chunking
    local char_count=$(echo "$original_content" | wc -c)
    if [ "$char_count" -lt 1600 ]; then  # ~800 tokens for technical content
        # Small enough, send directly
        echo "Content small enough, sending directly..."
        ~/.claude/memory-subagent-request.sh "$original_content" normal
        return 0
    fi
    
    echo "Content too large, chunking..."
    
    # Chunk the content
    local chunks_json=$(chunk_content "$original_content" "$MAX_TOKENS")
    local chunk_count=$(echo "$chunks_json" | jq '. | length')
    
    echo "Split into $chunk_count chunks"
    
    # Process each chunk
    for i in $(seq 0 $((chunk_count - 1))); do
        local chunk=$(echo "$chunks_json" | jq -r ".[$i]")
        local chunk_num=$((i + 1))
        
        echo "Processing chunk $chunk_num/$chunk_count..."
        
        # Create structured memory
        local structured=$(create_structured_memory "$chunk" "$chunk_num" "$chunk_count" "$context")
        
        # Add chunk metadata
        local memory_content="[CHUNK $chunk_num/$chunk_count] $structured"
        
        # Save using non-blocking subagent pattern
        ~/.claude/memory-subagent-request.sh "$memory_content" high
        
        sleep 2  # Rate limiting
    done
    
    # Save a summary linking all chunks
    local summary="Session Summary: Processed $chunk_count memory chunks covering: $context"
    ~/.claude/memory-subagent-request.sh "$summary" normal
    
    echo "Successfully processed all chunks!"
}

# Usage: ./memory-preprocessor.sh "large content" "optional context"
if [ $# -ge 1 ]; then
    process_large_memory "$1" "$2"
else
    echo "Usage: $0 'content to store' ['context description']"
    exit 1
fi