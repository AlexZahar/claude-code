#!/bin/bash

# Azure CLI Hooks for BoardLens
# Usage: HOOK_TYPE=<type> ~/.claude/azure-hooks.sh [args]

HOOK_TYPE=${HOOK_TYPE:-"info"}
STORAGE_ACCOUNT="projectblob"
RESOURCE_GROUP="project"

case "$HOOK_TYPE" in
  "storage-monitor")
    echo "🔍 Azure Storage Monitoring Report"
    echo "=================================="
    
    # Storage account info
    echo "📊 Storage Account: $STORAGE_ACCOUNT"
    az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" \
      --query "{location: location, sku: sku.name, tier: accessTier, https: enableHttpsTrafficOnly}" \
      --output table
    
    # Container info
    echo -e "\n📁 Containers:"
    az storage container list --account-name "$STORAGE_ACCOUNT" --auth-mode login \
      --query "[].{Name: name, LastModified: properties.lastModified}" \
      --output table
    
    # Usage metrics (if available)
    echo -e "\n📈 Usage Metrics:"
    az monitor metrics list \
      --resource "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT" \
      --metric "UsedCapacity" \
      --interval PT1H \
      --query "value[0].timeseries[0].data[-1].total" \
      --output tsv 2>/dev/null || echo "Metrics not available"
    ;;
    
  "security-audit")
    echo "🔒 Azure Storage Security Audit"
    echo "==============================="
    
    # CORS configuration
    echo "🌐 CORS Configuration:"
    az storage cors list --services b --account-name "$STORAGE_ACCOUNT" --output table
    
    # Access policies
    echo -e "\n🔑 Access Configuration:"
    az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" \
      --query "{httpsOnly: enableHttpsTrafficOnly, minTlsVersion: minimumTlsVersion, allowBlobPublicAccess: allowBlobPublicAccess}" \
      --output table
    
    # Network rules
    echo -e "\n🛡️ Network Rules:"
    az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" \
      --query "networkRuleSet.{defaultAction: defaultAction, bypass: bypass}" \
      --output table
    ;;
    
  "backup")
    echo "💾 Azure Storage Backup Status"
    echo "=============================="
    
    # Check backup configuration
    echo "🔄 Backup Configuration:"
    az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" \
      --query "geoReplicationStats" \
      --output table
    
    # List recent backups (if any automated backup is configured)
    echo -e "\n📋 Container List (for backup verification):"
    az storage container list --account-name "$STORAGE_ACCOUNT" --auth-mode login \
      --output table
    ;;
    
  "cors-update")
    echo "🌐 Updating CORS Configuration"
    echo "============================="
    
    # Clear existing CORS
    az storage cors clear --services b --account-name "$STORAGE_ACCOUNT"
    
    # Add BoardLens CORS rules
    az storage cors add \
      --services b \
      --methods GET HEAD POST PUT DELETE OPTIONS \
      --origins "https://app.project.ai" "http://localhost:3000" "http://localhost:3001" \
      --allowed-headers "*" \
      --exposed-headers "x-ms-request-id,x-ms-client-request-id,ETag,x-ms-version,Content-Type,Content-Length" \
      --max-age 3600 \
      --account-name "$STORAGE_ACCOUNT"
    
    echo "✅ CORS configuration updated"
    ;;
    
  "info")
    echo "ℹ️ Azure Storage Account Information"
    echo "==================================="
    
    # Basic info
    az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" \
      --query "{name: name, location: location, resourceGroup: resourceGroup, sku: sku.name}" \
      --output table
    
    # Endpoints
    echo -e "\n🔗 Service Endpoints:"
    az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" \
      --query "primaryEndpoints" \
      --output table
    ;;
    
  "costs")
    echo "💰 Azure Storage Cost Analysis"
    echo "============================="
    
    # Get consumption data for the last 30 days
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    
    az consumption usage list \
      --start-date "$(date -d '30 days ago' '+%Y-%m-%d')" \
      --end-date "$(date '+%Y-%m-%d')" \
      --query "[?contains(instanceName, '$STORAGE_ACCOUNT')].{Date: usageStart, Service: meterName, Quantity: quantity, Cost: pretaxCost}" \
      --output table 2>/dev/null || echo "Cost data not available (may need billing permissions)"
    ;;
    
  *)
    echo "🤖 Azure CLI Hooks for BoardLens"
    echo "==============================="
    echo ""
    echo "Available hook types:"
    echo "  storage-monitor - Monitor storage usage and health"
    echo "  security-audit  - Audit security configuration"
    echo "  backup         - Check backup status"
    echo "  cors-update    - Update CORS configuration"
    echo "  info           - Show storage account information"
    echo "  costs          - Show cost analysis (last 30 days)"
    echo ""
    echo "Usage:"
    echo "  HOOK_TYPE=storage-monitor ~/.claude/azure-hooks.sh"
    echo "  HOOK_TYPE=security-audit ~/.claude/azure-hooks.sh"
    ;;
esac