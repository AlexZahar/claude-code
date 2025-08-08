#!/bin/bash

# Gemini CLI Helper Functions for Claude Code Hooks

# Extract file path from tool input JSON
get_file_path() {
    echo "$1" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
}

# Extract content from tool input JSON
get_content() {
    echo "$1" | jq -r '.content // empty' 2>/dev/null
}

# Extract command from bash input
get_command() {
    echo "$1" | jq -r '.command // empty' 2>/dev/null
}

# Impact Analysis
impact_analysis() {
    local file="$1"
    if [ -n "$file" ]; then
        echo "🔍 Analyzing impact of changes to $file..."
        gemini -p "@src/ What files and components depend on $file? List all imports and usages. Be specific about function names and potential breaking changes." 2>/dev/null | head -30
    fi
}

# Duplicate Code Detection
duplicate_check() {
    local content="$1"
    if echo "$content" | grep -qE "function|class|const|export|interface|type"; then
        echo "🔎 Checking for similar code..."
        gemini -p "@src/ Is there existing code similar to this? Focus on avoiding duplication: ${content:0:200}..." 2>/dev/null | head -20
    fi
}

# Code Quality Check
quality_check() {
    local file="$1"
    if [ -n "$file" ]; then
        echo "✅ Reviewing code quality..."
        gemini -p "@src/ Review $file for: 1) Consistency with project patterns 2) Performance issues 3) Security concerns 4) Missing error handling" 2>/dev/null | head -25
    fi
}

# Test Coverage Analysis
test_coverage() {
    echo "📊 Analyzing test coverage..."
    gemini -p "@src/ @tests/ What components and functions lack test coverage? What edge cases are missing? Priority areas for testing?" 2>/dev/null | head -20
}

# API Consistency Check
api_consistency() {
    local file="$1"
    if echo "$file" | grep -qE "api/|routes/|RTK/services/"; then
        echo "🌐 Checking API consistency..."
        gemini -p "@src/app/api/ @src/RTK/services/ How do similar endpoints handle errors, validation, and responses? What's the naming convention?" 2>/dev/null | head -20
    fi
}

# Security Audit
security_scan() {
    local file="$1"
    if [ -n "$file" ]; then
        echo "🔒 Security scan for $file..."
        gemini -p "@$file Check for: SQL injection risks, XSS vulnerabilities, exposed secrets, unsafe dependencies, missing auth checks, CSRF protection" 2>/dev/null | head -25
    else
        echo "🔒 Full security audit..."
        gemini -p "@src/ Perform security audit: Check for OWASP top 10 vulnerabilities, exposed secrets, unsafe dependencies, missing auth checks" 2>/dev/null | head -30
    fi
}

# Performance Analysis
performance_analysis() {
    local file="$1"
    if [ -n "$file" ]; then
        echo "⚡ Performance analysis for $file..."
        gemini -p "@$file Analyze performance: N+1 queries, unnecessary re-renders, large bundle sizes, inefficient algorithms, memory leaks" 2>/dev/null | head -25
    fi
}

# Migration Helper
migration_helper() {
    local pattern="$1"
    echo "🔄 Migration analysis..."
    gemini -p "@src/ List all files that need migration from old patterns to new patterns. Focus on deprecated APIs, outdated syntax, legacy components" 2>/dev/null | head -30
}

# Pre-Delete Safety Check
delete_safety() {
    local file="$1"
    if [ -n "$file" ]; then
        echo "⚠️  Delete safety check for $file..."
        gemini -p "@src/ Is it safe to delete $file? List all references, imports, and dependencies. Will anything break?" 2>/dev/null | head -20
        # Return non-zero to block deletion if dependencies found
        if gemini -p "@src/ Does anything depend on $file? Answer with just YES or NO" 2>/dev/null | grep -q "YES"; then
            echo "❌ BLOCKING: File has dependencies. Review above before deleting."
            exit 2  # Exit code 2 blocks the action
        fi
    fi
}

# Architecture Analysis (for new features)
architecture_analysis() {
    local feature="$1"
    echo "🏗️  Architecture recommendations for: $feature"
    gemini -p "@src/ For implementing '$feature', what's the best architecture approach? Consider existing patterns, suggest file structure, identify reusable components" 2>/dev/null | head -30
}

# Commit Message Generation
commit_message() {
    echo "📝 Generating commit message..."
    gemini -p "Based on recent changes, suggest a conventional commit message. Use format: type(scope): description. Be concise and specific" 2>/dev/null | head -10
}

# Code Review
code_review() {
    local files="$1"
    echo "👀 AI Code Review..."
    gemini -p "@$files Perform code review: Check for bugs, logic errors, edge cases, performance issues, security concerns. Be specific with line numbers if possible" 2>/dev/null | head -40
}

# Codebase Analysis (comprehensive project overview)
codebase_analysis() {
    local path="${1:-.}"
    echo "🔬 Analyzing codebase structure and features..."
    gemini -p "@$path Provide a comprehensive analysis:
    1. Project type and main technologies
    2. Folder structure and organization
    3. Key features and functionality
    4. Main dependencies and their purposes
    5. Architecture patterns used
    6. Entry points and flow
    7. Configuration files and their roles
    8. Testing setup and coverage
    9. Build and deployment process
    10. Notable design decisions" 2>/dev/null | head -50
}

# Feature Analysis (deep dive into specific feature)
feature_analysis() {
    local feature="$1"
    echo "🎯 Analyzing feature: $feature"
    gemini -p "@src/ For the '$feature' feature:
    1. Which files implement this feature?
    2. What are all the dependencies?
    3. How does data flow through the feature?
    4. What external services/APIs does it use?
    5. What are the main components/functions?
    6. How is it tested?
    7. What security considerations exist?
    8. Performance characteristics?
    9. Related features that might be affected?" 2>/dev/null | head -40
}

# Dependency Analysis
dependency_analysis() {
    local target="$1"
    echo "📦 Analyzing dependencies..."
    gemini -p "@package.json @package-lock.json @src/ 
    1. List all direct dependencies and their purposes
    2. Identify unused dependencies
    3. Find outdated packages with security issues
    4. Suggest redundant packages that could be consolidated
    5. Analyze bundle size impact of each dependency
    6. Check for multiple versions of same package" 2>/dev/null | head -35
}

# Quick Project Overview (for initial orientation)
quick_overview() {
    echo "🚀 Quick Project Overview..."
    gemini -p "@. In 2-3 paragraphs, explain:
    1. What is this project?
    2. What problem does it solve?
    3. Who are the users?
    4. What are the main features?
    5. Tech stack summary" 2>/dev/null | head -20
}

# Main dispatcher based on hook context
case "${HOOK_TYPE:-pre}" in
    "pre-edit")
        FILE=$(get_file_path "$TOOL_INPUT")
        impact_analysis "$FILE"
        ;;
    "pre-write")
        CONTENT=$(get_content "$TOOL_INPUT")
        duplicate_check "$CONTENT"
        ;;
    "post-edit")
        FILE=$(get_file_path "$TOOL_INPUT")
        quality_check "$FILE"
        api_consistency "$FILE"
        ;;
    "test-run")
        test_coverage
        ;;
    "security")
        FILE=$(get_file_path "$TOOL_INPUT")
        security_scan "$FILE"
        ;;
    "performance")
        FILE=$(get_file_path "$TOOL_INPUT")
        performance_analysis "$FILE"
        ;;
    "pre-delete")
        FILE=$(get_file_path "$TOOL_INPUT")
        delete_safety "$FILE"
        ;;
    "migration")
        migration_helper
        ;;
    "architecture")
        FEATURE="$1"
        architecture_analysis "$FEATURE"
        ;;
    "commit")
        commit_message
        ;;
    "review")
        FILES="$1"
        code_review "$FILES"
        ;;
    "codebase")
        PATH_ARG="$1"
        codebase_analysis "$PATH_ARG"
        ;;
    "feature")
        FEATURE="$1"
        feature_analysis "$FEATURE"
        ;;
    "dependencies")
        dependency_analysis
        ;;
    "overview")
        quick_overview
        ;;
esac