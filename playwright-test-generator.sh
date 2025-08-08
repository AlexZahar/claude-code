#!/bin/bash

# Playwright Test Generator
# Converts successful workflows into reusable test files

set -e

TESTS_DIR="$HOME/.claude/generated-tests"
MEMORY_SCRIPT="$HOME/.claude/graphiti-hook.sh"

mkdir -p "$TESTS_DIR"

generate_test_file() {
    local workflow_name="$1"
    local url="$2"
    local actions="$3"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local filename="test_${workflow_name}_${timestamp}.spec.js"
    
    cat > "$TESTS_DIR/$filename" << EOF
import { test, expect } from '@playwright/test';

test.describe('Generated Test: $workflow_name', () => {
  test('should complete $workflow_name workflow', async ({ page }) => {
    // Navigate to page
    await page.goto('$url');
    
    // Wait for page to load
    await page.waitForLoadState('networkidle');
    
    $actions
    
    // Add your assertions here
    // await expect(page).toHaveTitle(/expected title/);
    // await expect(page.locator('selector')).toBeVisible();
  });
  
  test('should handle $workflow_name errors gracefully', async ({ page }) => {
    await page.goto('$url');
    
    // Test error scenarios
    // Add negative test cases here
  });
});
EOF

    echo "Generated test file: $TESTS_DIR/$filename"
    
    # Save to memory
    if [ -x "$MEMORY_SCRIPT" ]; then
        timeout 600 "$MEMORY_SCRIPT" add "Generated Playwright test: $workflow_name in $filename" 2>/dev/null || true
    fi
}

# Extract workflow from memory and generate test
if [ "$1" = "from-memory" ] && [ -n "$2" ]; then
    workflow_query="$2"
    echo "🔍 Searching memory for workflow: $workflow_query"
    
    if [ -x "$MEMORY_SCRIPT" ]; then
        workflow_data=$("$MEMORY_SCRIPT" search "Playwright Success" 2>/dev/null | head -1)
        if [ -n "$workflow_data" ]; then
            echo "📝 Found workflow data, generating test..."
            generate_test_file "memory_workflow" "https://example.com" "// Add actions from memory"
        fi
    fi
elif [ "$1" = "generate" ]; then
    # Manual test generation
    workflow_name="${2:-manual_workflow}"
    url="${3:-https://example.com}"
    actions="${4:-// Add your actions here}"
    
    generate_test_file "$workflow_name" "$url" "$actions"
else
    echo "Usage:"
    echo "  $0 from-memory <workflow-query>  # Generate from memory"
    echo "  $0 generate <name> <url> <actions>  # Manual generation"
fi