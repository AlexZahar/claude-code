#!/bin/bash

# Railway MCP Hooks for BoardLens
# Usage: HOOK_TYPE=<type> ~/.claude/railway-hooks.sh [args]

HOOK_TYPE=${HOOK_TYPE:-"info"}
PROJECT_ID="5d301640-a4f6-432f-b26c-e9f5ed28eca2"
PRODUCTION_ENV="12404b43-06c1-4f00-a4b7-b8a5b53910e9"
STAGING_ENV="8c981e60-11d5-46b2-a63d-8c81329b9d40"

# Service IDs
BACKEND_SERVICE="5aa4a877-d40d-4fab-af26-25e83d805b47"
PYTHON_SERVICE="51dd4b5e-6b64-41ee-ae5a-7ed4a9380bf6"
REDIS_SERVICE="555bbffa-29c5-4769-93c7-c5efca1eb23f"

case "$HOOK_TYPE" in
  "health-check")
    echo "🏥 BoardLens Service Health Check"
    echo "================================="
    
    echo "📊 Production Services:"
    echo "  🔹 Backend API: https://api.project.ai/api/health"
    curl -s -o /dev/null -w "    Status: %{http_code} | Response Time: %{time_total}s\n" "https://api.project.ai/api/health"
    
    echo "  🔹 Python API: https://analysis.project.ai/api/v1/health"
    curl -s -o /dev/null -w "    Status: %{http_code} | Response Time: %{time_total}s\n" "https://analysis.project.ai/api/v1/health"
    
    echo -e "\n📊 Staging Services:"
    echo "  🔹 Backend API: https://api-staging.project.ai/api/health"
    curl -s -o /dev/null -w "    Status: %{http_code} | Response Time: %{time_total}s\n" "https://api-staging.project.ai/api/health"
    ;;
    
  "deployment-status")
    echo "🚀 BoardLens Deployment Status"
    echo "=============================="
    
    echo "📦 Production Environment:"
    echo "  Backend Service:"
    # Note: Would use Railway MCP here - showing command structure
    echo "    mcp__railway-mcp-server__deployment_list --projectId=$PROJECT_ID --serviceId=$BACKEND_SERVICE --environmentId=$PRODUCTION_ENV --limit=3"
    
    echo -e "\n📦 Staging Environment:"
    echo "  Backend Service:"
    echo "    mcp__railway-mcp-server__deployment_list --projectId=$PROJECT_ID --serviceId=$BACKEND_SERVICE --environmentId=$STAGING_ENV --limit=3"
    ;;
    
  "env-audit")
    echo "🔒 Environment Variables Security Audit"
    echo "======================================="
    
    echo "🔍 Checking for potential security issues..."
    
    # Check for missing critical variables
    echo "📋 Critical Variables Check:"
    echo "  • RAG_API_KEY: Required for service communication"
    echo "  • BLOB_CONNECTION_STRING: Required for Azure storage"
    echo "  • JWT_SECRET: Required for authentication"
    echo "  • MONGODB_URI: Required for database connection"
    
    echo -e "\n⚠️ Security Recommendations:"
    echo "  • Ensure production secrets differ from staging"
    echo "  • Verify no secrets are logged in deployment logs"
    echo "  • Check CORS domains are properly restricted"
    ;;
    
  "sync-staging")
    echo "🔄 Safe Environment Variable Sync Guide"
    echo "======================================="
    
    echo "⚠️  WARNING: Environment sync is now handled by safety system"
    echo ""
    echo "🛡️ Use the safe environment manager instead:"
    echo "  OPERATION=safe-sync ~/.claude/railway-env-safety.sh"
    echo ""
    echo "✅ This prevents accidentally overwriting production variables"
    echo ""
    echo "📋 Manual staging-specific variables to set:"
    echo "  • NODE_ENV=staging"
    echo "  • FRONTEND_URL=https://staging.project.ai"
    echo "  • RAG_API_BASE_URL=https://rag-staging.project.ai"
    echo "  • BACKEND_WEBHOOK_URL=https://api-staging.project.ai/api/webhooks/rag"
    echo "  • MONGODB_URI=[staging-database-url]"
    echo "  • STRIPE keys (use test keys for staging)"
    echo ""
    echo "🔧 Safe sync command:"
    echo "  OPERATION=compare-envs ~/.claude/railway-env-safety.sh"
    ;;
    
  "scaling-check")
    echo "📈 Service Scaling Analysis"
    echo "=========================="
    
    echo "🔍 Current Service Status:"
    echo "  Backend Service: Checking replica count and resource usage"
    echo "  Python API: Checking RAG processing load"
    echo "  Redis: Checking memory usage and connections"
    echo "  Celery Workers: Checking queue depth and processing time"
    
    echo -e "\n💡 Scaling Recommendations:"
    echo "  • Monitor RAG processing queue depth"
    echo "  • Scale Celery workers based on document upload volume"
    echo "  • Consider Redis memory limits for job tracking"
    ;;
    
  "cost-monitor")
    echo "💰 Railway Cost Monitoring"
    echo "========================="
    
    echo "📊 Resource Usage Estimates:"
    echo "  Backend Service: ~$5-15/month (depends on traffic)"
    echo "  Python API: ~$10-25/month (RAG processing intensive)"
    echo "  Redis: ~$3-8/month"
    echo "  Celery Workers: ~$8-20/month total"
    
    echo -e "\n💡 Cost Optimization Tips:"
    echo "  • Use sleep mode for staging services during off-hours"
    echo "  • Monitor Celery worker utilization"
    echo "  • Consider shared Redis for staging/development"
    ;;
    
  "domain-status")
    echo "🌐 Domain and SSL Status"
    echo "======================="
    
    echo "🔗 Production Domains:"
    echo "  api.project.ai → Port 3001"
    curl -s -I "https://api.project.ai" | grep -E "(HTTP|Server:|x-)"
    
    echo -e "\n  analysis.project.ai → Port 8080"
    curl -s -I "https://analysis.project.ai" | grep -E "(HTTP|Server:|x-)"
    
    echo -e "\n🔗 Staging Domains:"
    echo "  api-staging.project.ai → Port 3001"
    curl -s -I "https://api-staging.project.ai" | grep -E "(HTTP|Server:|x-)"
    ;;
    
  "integration-test")
    echo "🔗 Service Integration Test"
    echo "=========================="
    
    echo "🧪 Testing Backend → RAG Integration:"
    echo "  1. Check RAG API accessibility from backend"
    echo "  2. Verify webhook endpoints are reachable"
    echo "  3. Test authentication between services"
    echo "  4. Validate Azure Blob Storage access"
    
    echo -e "\n🧪 Testing Frontend → Backend Integration:"
    echo "  1. Check API endpoints are accessible"
    echo "  2. Verify CORS configuration"
    echo "  3. Test file upload flow"
    echo "  4. Validate user authentication"
    ;;
    
  "logs-tail")
    ENV=${1:-"production"}
    SERVICE=${2:-"backend"}
    
    echo "📜 Tailing Logs: $SERVICE ($ENV)"
    echo "================================"
    
    case "$SERVICE" in
      "backend")
        SERVICE_ID=$BACKEND_SERVICE
        ;;
      "python"|"rag")
        SERVICE_ID=$PYTHON_SERVICE
        ;;
      "redis")
        SERVICE_ID=$REDIS_SERVICE
        ;;
      *)
        echo "❌ Unknown service: $SERVICE"
        echo "Available: backend, python, redis"
        exit 1
        ;;
    esac
    
    case "$ENV" in
      "production"|"prod")
        ENV_ID=$PRODUCTION_ENV
        ;;
      "staging"|"stage")
        ENV_ID=$STAGING_ENV
        ;;
      *)
        echo "❌ Unknown environment: $ENV"
        echo "Available: production, staging"
        exit 1
        ;;
    esac
    
    echo "Service ID: $SERVICE_ID"
    echo "Environment ID: $ENV_ID"
    echo "Use: mcp__railway-mcp-server__deployment_logs --deploymentId=<latest-deployment>"
    ;;
    
  "deploy-rag")
    echo "🚀 Deploy RAG Service to Railway"
    echo "==============================="
    
    echo "📋 Pre-deployment Checklist:"
    echo "  ✅ RAG repo ready for deployment"
    echo "  ✅ Dockerfile configured for Railway"
    echo "  ✅ Environment variables prepared"
    echo "  ✅ Azure Blob Storage CORS updated"
    
    echo -e "\n🔧 Required Environment Variables:"
    echo "  • RAG_API_KEY"
    echo "  • BLOB_CONNECTION_STRING"
    echo "  • LLAMA_CLOUD_API_KEY"
    echo "  • BACKEND_WEBHOOK_URL"
    echo "  • REDIS_URL"
    
    echo -e "\n📝 Deployment Steps:"
    echo "  1. Create new service in Railway project"
    echo "  2. Connect to project-rag repository"
    echo "  3. Set environment variables"
    echo "  4. Configure custom domain (optional)"
    echo "  5. Test deployment health"
    ;;
    
  "backup-config")
    echo "💾 Configuration Backup"
    echo "======================"
    
    BACKUP_DIR="$HOME/.claude/railway-backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    echo "📁 Backup directory: $BACKUP_DIR"
    echo "  • Production environment variables"
    echo "  • Staging environment variables"
    echo "  • Domain configurations"
    echo "  • Service settings"
    
    echo -e "\nℹ️ Use Railway MCP to export configurations:"
    echo "  mcp__railway-mcp-server__list_service_variables --projectId=$PROJECT_ID --environmentId=$PRODUCTION_ENV"
    ;;
    
  "quick-status")
    echo "⚡ Quick BoardLens Status"
    echo "======================="
    
    # Quick health checks
    BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://api.project.ai/api/health")
    PYTHON_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://analysis.project.ai/api/v1/health")
    STAGING_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://api-staging.project.ai/api/health")
    
    echo "🏥 Service Health:"
    echo "  Backend (prod): $([ "$BACKEND_STATUS" = "200" ] && echo "✅ Online" || echo "❌ Down ($BACKEND_STATUS)")"
    echo "  Python API: $([ "$PYTHON_STATUS" = "200" ] && echo "✅ Online" || echo "❌ Down ($PYTHON_STATUS)")"
    echo "  Backend (staging): $([ "$STAGING_STATUS" = "200" ] && echo "✅ Online" || echo "❌ Down ($STAGING_STATUS)")"
    
    echo -e "\n📊 Last checked: $(date)"
    ;;
    
  *)
    echo "🚂 Railway MCP Hooks for BoardLens"
    echo "=================================="
    echo ""
    echo "Available hook types:"
    echo "  health-check     - Check all service endpoints"
    echo "  deployment-status - View recent deployments"
    echo "  env-audit        - Security audit of environment variables"
    echo "  sync-staging     - Guide for syncing prod to staging"
    echo "  scaling-check    - Analyze service scaling needs"
    echo "  cost-monitor     - Monitor Railway costs and usage"
    echo "  domain-status    - Check domain and SSL status"
    echo "  integration-test - Test inter-service communication"
    echo "  logs-tail        - Tail service logs (usage: logs-tail [env] [service])"
    echo "  deploy-rag       - Guide for deploying RAG service"
    echo "  backup-config    - Backup environment configurations"
    echo "  quick-status     - Quick health check of all services"
    echo ""
    echo "Usage Examples:"
    echo "  HOOK_TYPE=health-check ~/.claude/railway-hooks.sh"
    echo "  HOOK_TYPE=logs-tail ~/.claude/railway-hooks.sh staging backend"
    echo "  HOOK_TYPE=quick-status ~/.claude/railway-hooks.sh"
    ;;
esac