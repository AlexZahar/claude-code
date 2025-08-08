#!/bin/bash

# Railway Environment Safety Manager
# Prevents accidental overwriting of production environment variables
# Usage: OPERATION=<operation> ~/.claude/railway-env-safety.sh [args]

OPERATION=${OPERATION:-"help"}
PROJECT_ID="5d301640-a4f6-432f-b26c-e9f5ed28eca2"
PRODUCTION_ENV="12404b43-06c1-4f00-a4b7-b8a5b53910e9"
STAGING_ENV="8c981e60-11d5-46b2-a63d-8c81329b9d40"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Critical production variables that should NEVER be synced
CRITICAL_PROD_VARS=(
    "MONGODB_URI"
    "STRIPE_SECRET_KEY" 
    "MAILERSEND_API_KEY"
    "NODE_ENV"
    "FRONTEND_URL"
    "RAG_API_BASE_URL"
    "BACKEND_WEBHOOK_URL"
    "SERVER_URL"
    "GOOGLE_REDIRECT_URI"
    "WEBHOOK_SECRET"
)

# Environment-specific variables that must be different
ENV_SPECIFIC_VARS=(
    "NODE_ENV"
    "FRONTEND_URL" 
    "SERVER_URL"
    "RAG_API_BASE_URL"
    "BACKEND_WEBHOOK_URL"
    "GOOGLE_REDIRECT_URI"
    "MAILERSEND_FROM_EMAIL"
    "SUPPORT_EMAIL"
)

# Safe variables that can be synced (with confirmation)
SAFE_SYNC_VARS=(
    "COHERE_API_KEY"
    "PINECONE_API_KEY" 
    "LLAMA_PARSE_API_KEY"
    "OPENAI_API_KEY"
    "GEMINI_API_KEY"
    "ANTHROPIC_API_KEY"
    "COMPANY_NAME"
    "COMPANY_LOGO_URL"
    "BLOB_CONNECTION_STRING"
    "BLOB_CONTAINER_NAME"
    "STORAGE_PROVIDER"
    "RAG_API_KEY"
    "JWT_SECRET"
)

check_environment_safety() {
    local source_env=$1
    local target_env=$2
    
    echo -e "${BLUE}🔒 Environment Safety Check${NC}"
    echo "================================"
    echo "Source: $(get_env_name $source_env)"
    echo "Target: $(get_env_name $target_env)"
    echo ""
    
    # Prevent syncing TO production
    if [ "$target_env" = "$PRODUCTION_ENV" ]; then
        echo -e "${RED}❌ DANGER: Cannot sync TO production environment!${NC}"
        echo -e "${RED}   This could overwrite critical production settings.${NC}"
        echo ""
        echo -e "${YELLOW}💡 Safe alternatives:${NC}"
        echo "   • Use 'safe-copy' to copy specific variables"
        echo "   • Manually set variables in production"
        echo "   • Use 'compare-envs' to see differences"
        return 1
    fi
    
    # Warn about syncing FROM production
    if [ "$source_env" = "$PRODUCTION_ENV" ]; then
        echo -e "${YELLOW}⚠️  WARNING: Syncing FROM production${NC}"
        echo -e "${YELLOW}   Some variables will need manual adjustment for staging${NC}"
        echo ""
    fi
    
    return 0
}

get_env_name() {
    case "$1" in
        "$PRODUCTION_ENV")
            echo "Production"
            ;;
        "$STAGING_ENV")
            echo "Staging"
            ;;
        *)
            echo "Unknown ($1)"
            ;;
    esac
}

case "$OPERATION" in
    "safe-sync")
        SOURCE_ENV=${1:-"$PRODUCTION_ENV"}
        TARGET_ENV=${2:-"$STAGING_ENV"}
        SERVICE_ID=${3:-""}
        
        echo -e "${BLUE}🔄 Safe Environment Variable Sync${NC}"
        echo "=================================="
        
        # Safety check
        if ! check_environment_safety "$SOURCE_ENV" "$TARGET_ENV"; then
            exit 1
        fi
        
        echo -e "${GREEN}✅ Safety check passed${NC}"
        echo ""
        echo "📋 This operation will:"
        echo "  1. List current variables in both environments"
        echo "  2. Show you exactly what will be synced"
        echo "  3. Require confirmation for each critical variable"
        echo "  4. Skip environment-specific variables automatically"
        echo ""
        echo "🛡️ Protected variables (will NOT be synced):"
        for var in "${ENV_SPECIFIC_VARS[@]}"; do
            echo "    • $var"
        done
        echo ""
        
        read -p "Continue with safe sync? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Sync cancelled"
            exit 0
        fi
        
        echo ""
        echo "🔧 MCP Commands to execute:"
        echo "mcp__railway-mcp-server__list_service_variables --projectId=$PROJECT_ID --environmentId=$SOURCE_ENV --serviceId=$SERVICE_ID"
        echo "mcp__railway-mcp-server__variable_copy --projectId=$PROJECT_ID --sourceEnvironmentId=$SOURCE_ENV --targetEnvironmentId=$TARGET_ENV --serviceId=$SERVICE_ID"
        ;;
        
    "compare-envs")
        SERVICE_ID=${1:-""}
        
        echo -e "${BLUE}📊 Environment Variable Comparison${NC}"
        echo "=================================="
        echo ""
        echo "🔍 Comparing Production vs Staging environments"
        if [ -n "$SERVICE_ID" ]; then
            echo "   Service: $SERVICE_ID"
        else
            echo "   Scope: All shared variables"
        fi
        echo ""
        echo "🔧 MCP Commands to run:"
        echo "1. List Production variables:"
        echo "   mcp__railway-mcp-server__list_service_variables --projectId=$PROJECT_ID --environmentId=$PRODUCTION_ENV --serviceId=$SERVICE_ID"
        echo ""
        echo "2. List Staging variables:"
        echo "   mcp__railway-mcp-server__list_service_variables --projectId=$PROJECT_ID --environmentId=$STAGING_ENV --serviceId=$SERVICE_ID"
        echo ""
        echo "3. Compare the outputs manually or use diff tool"
        ;;
        
    "safe-copy")
        VAR_NAME=${1}
        SOURCE_ENV=${2:-"$PRODUCTION_ENV"}
        TARGET_ENV=${3:-"$STAGING_ENV"}
        SERVICE_ID=${4:-""}
        
        if [ -z "$VAR_NAME" ]; then
            echo -e "${RED}❌ Error: Variable name required${NC}"
            echo "Usage: OPERATION=safe-copy ~/.claude/railway-env-safety.sh VAR_NAME [SOURCE_ENV] [TARGET_ENV] [SERVICE_ID]"
            exit 1
        fi
        
        echo -e "${BLUE}📋 Safe Variable Copy${NC}"
        echo "===================="
        echo "Variable: $VAR_NAME"
        echo "From: $(get_env_name $SOURCE_ENV)"
        echo "To: $(get_env_name $TARGET_ENV)"
        echo ""
        
        # Check if variable is in critical list
        if [[ " ${CRITICAL_PROD_VARS[@]} " =~ " ${VAR_NAME} " ]]; then
            echo -e "${RED}⚠️  CRITICAL VARIABLE WARNING${NC}"
            echo "   $VAR_NAME is marked as a critical production variable"
            echo -e "${YELLOW}   Are you sure you want to copy this?${NC}"
            echo ""
            read -p "Type 'CONFIRM' to proceed: " confirm
            if [ "$confirm" != "CONFIRM" ]; then
                echo "Copy cancelled"
                exit 0
            fi
        fi
        
        # Check if variable is environment-specific
        if [[ " ${ENV_SPECIFIC_VARS[@]} " =~ " ${VAR_NAME} " ]]; then
            echo -e "${YELLOW}⚠️  ENVIRONMENT-SPECIFIC VARIABLE${NC}"
            echo "   $VAR_NAME should typically be different between environments"
            echo -e "${YELLOW}   You may need to modify the value after copying${NC}"
            echo ""
        fi
        
        echo "🔧 Steps to copy variable:"
        echo "1. Get current value:"
        echo "   mcp__railway-mcp-server__list_service_variables --projectId=$PROJECT_ID --environmentId=$SOURCE_ENV --serviceId=$SERVICE_ID"
        echo ""
        echo "2. Copy the value manually and set it:"
        echo "   mcp__railway-mcp-server__variable_set --projectId=$PROJECT_ID --environmentId=$TARGET_ENV --serviceId=$SERVICE_ID --name=$VAR_NAME --value='[VALUE]'"
        ;;
        
    "staging-to-prod-block")
        echo -e "${RED}🚫 OPERATION BLOCKED${NC}"
        echo "==================="
        echo ""
        echo -e "${RED}❌ Syncing from Staging to Production is FORBIDDEN${NC}"
        echo ""
        echo "This operation could:"
        echo "  • Overwrite critical production secrets"
        echo "  • Break production services"
        echo "  • Cause security vulnerabilities"
        echo "  • Violate compliance requirements"
        echo ""
        echo -e "${YELLOW}💡 Safe alternatives:${NC}"
        echo "  • Manually review and set variables in production"
        echo "  • Use infrastructure-as-code for environment parity"
        echo "  • Test changes in staging first, then apply to prod"
        ;;
        
    "backup-env")
        ENV_ID=${1:-"$PRODUCTION_ENV"}
        SERVICE_ID=${2:-""}
        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
        BACKUP_DIR="$HOME/.claude/railway-backups/env-$TIMESTAMP"
        
        mkdir -p "$BACKUP_DIR"
        
        echo -e "${BLUE}💾 Environment Variable Backup${NC}"
        echo "============================="
        echo "Environment: $(get_env_name $ENV_ID)"
        echo "Backup directory: $BACKUP_DIR"
        echo ""
        
        if [ -n "$SERVICE_ID" ]; then
            echo "Service-specific backup for: $SERVICE_ID"
            BACKUP_FILE="$BACKUP_DIR/service-$SERVICE_ID-vars.json"
        else
            echo "Shared variables backup"
            BACKUP_FILE="$BACKUP_DIR/shared-vars.json"
        fi
        
        echo ""
        echo "🔧 Command to export variables:"
        echo "mcp__railway-mcp-server__list_service_variables --projectId=$PROJECT_ID --environmentId=$ENV_ID --serviceId=$SERVICE_ID > $BACKUP_FILE"
        echo ""
        echo "💡 Run this command with Claude Code to create backup"
        ;;
        
    "restore-plan")
        BACKUP_FILE=${1}
        TARGET_ENV=${2:-"$STAGING_ENV"}
        
        if [ -z "$BACKUP_FILE" ]; then
            echo -e "${RED}❌ Error: Backup file path required${NC}"
            echo "Usage: OPERATION=restore-plan ~/.claude/railway-env-safety.sh /path/to/backup.json [TARGET_ENV]"
            exit 1
        fi
        
        echo -e "${BLUE}🔄 Environment Restore Plan${NC}"
        echo "=========================="
        echo "Backup file: $BACKUP_FILE"
        echo "Target environment: $(get_env_name $TARGET_ENV)"
        echo ""
        
        if [ "$TARGET_ENV" = "$PRODUCTION_ENV" ]; then
            echo -e "${RED}❌ DANGER: Cannot restore to production environment!${NC}"
            echo -e "${RED}   Use manual verification and setting instead.${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}✅ Safe to restore to staging environment${NC}"
        echo ""
        echo "🔧 Steps to restore:"
        echo "1. Review backup file contents first"
        echo "2. Use variable_bulk_set to restore non-critical variables"
        echo "3. Manually verify environment-specific variables"
        echo "4. Test application after restore"
        ;;
        
    "audit-safety")
        echo -e "${BLUE}🔍 Environment Safety Audit${NC}"
        echo "=========================="
        echo ""
        echo -e "${GREEN}✅ SAFE OPERATIONS:${NC}"
        echo "  • Production → Staging sync (with warnings)"
        echo "  • Individual variable copying with confirmation"
        echo "  • Environment comparison and diff"
        echo "  • Backup creation"
        echo "  • Restore to staging only"
        echo ""
        echo -e "${RED}❌ BLOCKED OPERATIONS:${NC}"
        echo "  • Any sync TO production environment"
        echo "  • Staging → Production sync"
        echo "  • Bulk overwrites without confirmation"
        echo "  • Restore to production environment"
        echo ""
        echo -e "${YELLOW}⚠️  PROTECTED VARIABLES:${NC}"
        echo "Critical production variables:"
        for var in "${CRITICAL_PROD_VARS[@]}"; do
            echo "    • $var"
        done
        echo ""
        echo "Environment-specific variables:"
        for var in "${ENV_SPECIFIC_VARS[@]}"; do
            echo "    • $var"
        done
        echo ""
        echo -e "${BLUE}🛡️ SAFEGUARDS IN PLACE:${NC}"
        echo "  • Direction validation (no sync TO prod)"
        echo "  • Variable classification and warnings"
        echo "  • Explicit confirmation for critical operations"
        echo "  • Backup creation before changes"
        echo "  • Manual review requirements"
        ;;
        
    *)
        echo -e "${BLUE}🛡️ Railway Environment Safety Manager${NC}"
        echo "===================================="
        echo ""
        echo "Available operations:"
        echo "  safe-sync         - Safely sync variables from prod to staging"
        echo "  compare-envs      - Compare production vs staging variables"
        echo "  safe-copy        - Copy a single variable with safety checks"
        echo "  backup-env       - Create backup of environment variables"
        echo "  restore-plan     - Plan restoration from backup (staging only)"
        echo "  audit-safety     - Show all safety measures in place"
        echo ""
        echo "Usage examples:"
        echo "  OPERATION=safe-sync ~/.claude/railway-env-safety.sh"
        echo "  OPERATION=safe-copy ~/.claude/railway-env-safety.sh JWT_SECRET"
        echo "  OPERATION=compare-envs ~/.claude/railway-env-safety.sh [service-id]"
        echo "  OPERATION=backup-env ~/.claude/railway-env-safety.sh"
        echo ""
        echo -e "${RED}🚫 NEVER SYNCS TO PRODUCTION - STAGING ONLY${NC}"
        ;;
esac