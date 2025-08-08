#!/bin/bash
# Graphiti Hook Integration for Claude Code
# ==========================================
# This script integrates with Claude Code hooks to automatically
# save memories to the Graphiti knowledge graph.

GRAPHITI_HOOK="/Users/USERNAME/.claude/graphiti-direct-hook.py"
HOOK_LOG="/Users/USERNAME/.claude/graphiti-hook.log"
DEBUG_LOG="/Users/USERNAME/.claude/graphiti-debug.log"
UV_PYTHON="/opt/homebrew/bin/uv run --with graphiti-core python"

# Trivial commands to ignore
TRIVIAL_COMMANDS=("ls" "cd" "pwd" "echo" "cat" "which" "clear" "head" "tail")
# File patterns to ignore
IGNORE_PATTERNS=(".pyc" ".log" "__pycache__" "node_modules" ".git" ".DS_Store")

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$HOOK_LOG"
}

# Function to log debug messages
log_debug() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DEBUG] $*" >> "$DEBUG_LOG"
}

# Function to check if command is trivial
is_trivial_command() {
    local cmd="$1"
    local first_word=$(echo "$cmd" | awk '{print $1}')
    
    for trivial in "${TRIVIAL_COMMANDS[@]}"; do
        if [[ "$first_word" == "$trivial" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check if file should be ignored
should_ignore_file() {
    local file_path="$1"
    
    for pattern in "${IGNORE_PATTERNS[@]}"; do
        if [[ "$file_path" == *"$pattern"* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to get current project context
get_project_context() {
    # Check if we're in a git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Get the repository name
        local repo_name=$(basename $(git rev-parse --show-toplevel))
        echo "$repo_name"
    else
        # Try to get from current directory name
        local dir_name=$(basename "$PWD")
        if [[ "$dir_name" == ".claude" || "$dir_name" == "$HOME" ]]; then
            echo "general"
        else
            echo "$dir_name"
        fi
    fi
}

# Non-blocking async version with metadata context
add_to_graphiti_async() {
    local content="$1"
    local include_project="${2:-true}"
    local priority="${3:-normal}"
    local context="${4:-}"
    
    if [ -z "$content" ]; then
        log_message "Error: No content provided"
        return 1
    fi
    
    local project_context=""
    if [ "$include_project" = "true" ]; then
        project_context="$(get_project_context)"
    fi
    
    # Create context JSON if additional context provided
    if [ -n "$context" ]; then
        export MEMORY_CONTEXT="$context"
    else
        # Build basic context
        export MEMORY_CONTEXT="{\"project\": \"$project_context\", \"session_id\": \"$(date +%Y%m%d-%H%M%S)\"}"
    fi
    
    # Queue for background processing (non-blocking)
    /Users/USERNAME/.claude/memory-queue-manager.sh queue "$content" "$priority" "$project_context"
    
    log_message "✅ Queued for async processing with metadata: $(echo "$content" | head -c 50)..."
    return 0  # Always return success immediately
}

# Function to add a memory to Graphiti (OPTIMIZED VERSION - LEGACY)
add_to_graphiti() {
    local content="$1"
    local include_project="${2:-true}"
    
    # Add project context if requested and not already present
    if [ "$include_project" = "true" ]; then
        local project=$(get_project_context)
        # Check if content already starts with a project context
        if [[ ! "$content" =~ ^\[.*\] ]]; then
            content="[$project] $content"
        fi
    fi
    
    log_message "Adding to Graphiti: $(echo "$content" | head -c 100)..."
    
    # Check content size - if too large, use preprocessor
    local content_size=${#content}
    local max_size=1600  # ~800 tokens for technical content (2 chars per token)
    
    if [ $content_size -gt $max_size ]; then
        log_message "Content too large ($content_size chars), using preprocessor..."
        # Use the memory preprocessor for large content
        /Users/USERNAME/.claude/memory-preprocessor.sh "$content" "$(get_project_context)"
        return $?
    fi
    
    # For smaller content, use direct approach with optimized timeout
    local max_retries=2  # Reduced from 3
    local retry_count=0
    local result
    local timeout_seconds=300  # Reduced from 600 (5 minutes)
    
    while [ $retry_count -lt $max_retries ]; do
        result=$(timeout $timeout_seconds $UV_PYTHON "$GRAPHITI_HOOK" add "$content" 2>&1)
        
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            log_message "Successfully added to Graphiti"
            echo "$result"
            return 0
        elif [ $exit_code -eq 124 ]; then
            retry_count=$((retry_count + 1))
            log_message "Operation timed out after $timeout_seconds seconds (attempt $retry_count/$max_retries)"
            if [ $retry_count -lt $max_retries ]; then
                log_message "Retrying with truncated content..."
                # Truncate content for timeout retry
                local truncated="${content:0:1000}... [TRUNCATED]"
                content="$truncated"
                sleep 2
            fi
        else
            retry_count=$((retry_count + 1))
            log_message "Failed to add to Graphiti (attempt $retry_count/$max_retries): $result"
            if [ $retry_count -lt $max_retries ]; then
                sleep 2
            fi
        fi
    done
    
    return 1
}

# Function to search Graphiti
search_graphiti() {
    local query="$1"
    log_message "Searching Graphiti: $query"
    
    result=$($UV_PYTHON "$GRAPHITI_HOOK" search "$query" 2>&1)
    
    if [ $? -eq 0 ]; then
        log_message "Search completed"
        echo "$result"
    else
        log_message "Search failed: $result"
        return 1
    fi
}

# Function to search with metadata filters
search_graphiti_filtered() {
    local type="$1"
    local priority="$2"
    local query="${3:-}"
    
    log_message "Searching Graphiti with filters: type=$type, priority=$priority"
    
    result=$($UV_PYTHON "$GRAPHITI_HOOK" search-filtered "$type" "$priority" "$query" 2>&1)
    
    if [ $? -eq 0 ]; then
        log_message "Filtered search completed"
        echo "$result"
    else
        log_message "Filtered search failed: $result"
        return 1
    fi
}

# Function to get recent episodes with optional type filter
get_recent_filtered() {
    local memory_type="$1"
    local limit="${2:-10}"
    
    log_message "Getting recent $memory_type memories (limit: $limit)"
    
    result=$($UV_PYTHON "$GRAPHITI_HOOK" recent-filtered "$memory_type" "$limit" 2>&1)
    
    if [ $? -eq 0 ]; then
        log_message "Retrieved filtered recent memories"
        echo "$result"
    else
        log_message "Failed to get filtered memories: $result"
        return 1
    fi
}

# Function to assess and queue memory using smart assessment
assess_and_queue_memory() {
    local content="$1"
    local priority="${2:-normal}"
    
    log_debug "Starting smart assessment for content: ${content:0:100}..."
    
    # Check content length first - if too long, chunk it
    local content_length=$(echo "$content" | wc -c)
    if [ "$content_length" -gt 1400 ]; then
        echo "📝 Memory content long ($content_length characters) - breaking into smaller memories"
        log_message "Memory too long ($content_length chars), chunking into smaller memories"
        echo "🔄 Processing chunks in background..."
        chunk_and_save_memory "$content" "$priority" &
        echo "✅ Chunking initiated - continuing without blocking"
        return 0
    fi
    
    # Use smart assessor to evaluate the content
    local assessment_result
    assessment_result=$($UV_PYTHON -c "
import sys
sys.path.append('/Users/USERNAME/.claude')
try:
    from smart_memory_assessor import MemoryAssessor
    assessor = MemoryAssessor()
    content = '''$content'''
    should_save, priority, reason = assessor.assess_importance(content)
    if should_save:
        print(f'SAVE:{priority}:{reason}')
    else:
        print(f'SKIP:{reason}')
except Exception as e:
    print(f'ERROR:{e}')
" 2>&1)

    if echo "$assessment_result" | grep -q "^SAVE:"; then
        local assessed_priority=$(echo "$assessment_result" | cut -d: -f2)
        local reason=$(echo "$assessment_result" | cut -d: -f3-)
        
        log_debug "Assessment: SAVE with priority $assessed_priority ($reason)"
        echo "✅ Saving to memory (priority: $assessed_priority)"
        echo "📝 Reason: $reason"
        
        # Create metadata context for the memory
        local context="{\"type\": \"$(echo "$content" | sed 's/[^a-zA-Z0-9 ]//g' | awk '{print tolower($1)}')\", \"priority\": \"$assessed_priority\", \"project\": \"$(get_project_context)\"}"
        export MEMORY_CONTEXT="$context"
        
        # Use the enhanced add function
        add_to_graphiti "$content"
        
    elif echo "$assessment_result" | grep -q "^SKIP:"; then
        local reason=$(echo "$assessment_result" | cut -d: -f2-)
        log_debug "Assessment: SKIP ($reason)"
        echo "ℹ️  Memory not saved: $reason"
        return 0
    else
        log_message "Assessment failed: $assessment_result"
        echo "⚠️  Assessment failed, using fallback direct save"
        echo "   This might be due to missing smart-memory-assessor.py"
        add_to_graphiti "$content"
    fi
}

# Function to chunk large content into smaller memories
chunk_and_save_memory() {
    local content="$1"
    local priority="${2:-normal}"
    
    log_debug "Chunking large memory content into smaller pieces"
    
    # Use Python to intelligently chunk the content
    local chunk_result
    chunk_result=$($UV_PYTHON -c "
import sys
import re

content = '''$content'''

# Extract key information for chunking
def extract_key_parts(text):
    chunks = []
    
    # Split by sentences first
    sentences = re.split(r'[.!?]+', text)
    
    current_chunk = ''
    max_chunk_size = 800  # Target ~800 chars per chunk (200-400 tokens)
    
    for sentence in sentences:
        sentence = sentence.strip()
        if not sentence:
            continue
            
        # If adding this sentence would exceed limit, save current chunk
        if len(current_chunk) + len(sentence) > max_chunk_size and current_chunk:
            chunks.append(current_chunk.strip())
            current_chunk = sentence
        else:
            if current_chunk:
                current_chunk += '. ' + sentence
            else:
                current_chunk = sentence
    
    # Don't forget the last chunk
    if current_chunk.strip():
        chunks.append(current_chunk.strip())
    
    return chunks

chunks = extract_key_parts(content)

# Print each chunk on a separate line with a delimiter
for i, chunk in enumerate(chunks):
    print(f'CHUNK_{i}:{chunk}')
" 2>&1)

    if [ $? -ne 0 ]; then
        echo "⚠️ Chunking failed, saving as single memory"
        add_to_graphiti "$content"
        return $?
    fi
    
    # Save each chunk as a separate memory
    local chunk_count=0
    local total_chunks=$(echo "$chunk_result" | grep "^CHUNK_" | wc -l)
    
    echo "💾 Saving $total_chunks smaller memories..."
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^CHUNK_[0-9]+: ]]; then
            chunk_count=$((chunk_count + 1))
            local chunk_content=$(echo "$line" | sed 's/^CHUNK_[0-9]*://')
            
            if [ -n "$chunk_content" ]; then
                echo "  📌 Memory $chunk_count/$total_chunks: ${chunk_content:0:60}..."
                add_to_graphiti "$chunk_content"
            fi
        fi
    done <<< "$chunk_result"
    
    log_message "Successfully chunked and saved $chunk_count memories"
    echo "✅ Completed: Saved $chunk_count focused memories"
    return 0
}

# Hook functions for different events

# Called after file edits
on_file_edit() {
    local file_path="$1"
    local action="$2"
    
    log_debug "File edit hook triggered: $file_path ($action)"
    
    # Check if file should be ignored
    if should_ignore_file "$file_path"; then
        log_debug "Ignoring file: $file_path (matches ignore pattern)"
        return 0
    fi
    
    # Add to batcher instead of direct memory
    $UV_PYTHON "/Users/USERNAME/.claude/graphiti-batcher.py" add_file "$file_path" "$action"
    
    # Check if we should flush
    flush_result=$($UV_PYTHON "/Users/USERNAME/.claude/graphiti-batcher.py" flush 2>&1)
    if [[ "$flush_result" == "Flushed:"* ]]; then
        summary="${flush_result#Flushed: }"
        add_to_graphiti "$summary"
    fi
}

# Called after running commands
on_command_run() {
    local command="$1"
    local exit_code="$2"
    
    log_debug "Command hook triggered: $command (exit: $exit_code)"
    
    # Check if command is trivial
    if is_trivial_command "$command"; then
        log_debug "Ignoring trivial command: $command"
        return 0
    fi
    
    # Check for important commands that should always be captured
    if [[ "$command" =~ ^(git|npm|yarn|pip|docker|kubectl|terraform|aws) ]]; then
        log_debug "Important command detected: $command"
    elif [[ "$exit_code" != "0" ]]; then
        log_debug "Failed command detected: $command (exit: $exit_code)"
    else
        # For other commands, only capture if they modify state
        if ! [[ "$command" =~ (test|build|install|deploy|migrate|seed) ]]; then
            log_debug "Skipping non-state-changing command: $command"
            return 0
        fi
    fi
    
    # Add to batcher
    $UV_PYTHON "/Users/USERNAME/.claude/graphiti-batcher.py" add_command "$command" "$exit_code"
    
    # Check if we should flush
    flush_result=$($UV_PYTHON "/Users/USERNAME/.claude/graphiti-batcher.py" flush 2>&1)
    if [[ "$flush_result" == "Flushed:"* ]]; then
        summary="${flush_result#Flushed: }"
        add_to_graphiti "$summary"
    fi
}

# Called for discoveries or insights
on_discovery() {
    local discovery="$1"
    local context="$2"
    
    memory="[Discovery] ${discovery} | Context: ${context}"
    add_to_graphiti "$memory"
}

# Called for errors
on_error() {
    local error="$1"
    local context="$2"
    
    memory="[Error] ${error} | Context: ${context}"
    add_to_graphiti "$memory"
}

# Called for Git commits
on_git_commit() {
    local message="$1"
    local files="$2"
    
    memory="[Git Commit] ${message} | Files: ${files}"
    add_to_graphiti "$memory"
}

# Main entry point
case "$1" in
    add)
        shift
        # Use smart assessment instead of direct save
        assess_and_queue_memory "$@" "normal"
        ;;
    search)
        shift
        search_graphiti "$@"
        ;;
    search-type)
        # Search for specific memory type
        shift
        type="$1"
        shift
        search_graphiti_filtered "$type" "all" "$@"
        ;;
    search-filtered)
        # Search with type and priority filters
        shift
        search_graphiti_filtered "$@"
        ;;
    recent-type)
        # Get recent memories of specific type
        shift
        get_recent_filtered "$@"
        ;;
    file_edit)
        shift
        on_file_edit "$@"
        ;;
    command_run)
        shift
        on_command_run "$@"
        ;;
    discovery)
        shift
        on_discovery "$@"
        ;;
    error)
        shift
        on_error "$@"
        ;;
    git_commit)
        shift
        on_git_commit "$@"
        ;;
    recent)
        $UV_PYTHON "$GRAPHITI_HOOK" recent "${2:-10}"
        ;;
    add_async|async)
        add_to_graphiti_async "$2" "true" "${3:-normal}"
        ;;
    queue_status|status)
        /Users/USERNAME/.claude/memory-queue-manager.sh status
        ;;
    start_worker)
        /Users/USERNAME/.claude/memory-queue-manager.sh start
        ;;
    *)
        echo "Usage: $0 {add|search|search-type|search-filtered|recent|recent-type|file_edit|command_run|discovery|error|git_commit|add_async|status|start_worker} [args...]"
        echo ""
        echo "Examples:"
        echo "  Basic operations:"
        echo "  $0 add \"Important memory to store in graph\""
        echo "  $0 search \"query to search\""
        echo "  $0 recent 20"
        echo ""
        echo "  Enhanced metadata search:"
        echo "  $0 search-type bug_fix          # Find all bug fixes"
        echo "  $0 search-type feature \"auth\"   # Find features related to auth"
        echo "  $0 search-filtered bug_fix high  # Find high priority bug fixes"
        echo "  $0 recent-type feature 10        # Show 10 most recent features"
        echo ""
        echo "  Hook operations:"
        echo "  $0 file_edit /path/to/file.py edited"
        echo "  $0 command_run \"npm test\" 0"
        echo "  $0 discovery \"Found security issue\" \"auth.js:42\""
        echo "  $0 error \"Build failed\" \"Missing dependency\""
        echo "  $0 git_commit \"feat: added new feature\" \"src/app.js,src/test.js\""
        echo ""
        echo "  Memory types: bug_fix, feature, refactor, discovery, documentation, general"
        echo "  Priority levels: high, medium, low"
        exit 1
        ;;
esac