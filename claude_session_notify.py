#!/usr/bin/env python3
"""
Claude Code Session Notifier
Sends notifications when Claude Code sessions start and handles tool permissions
"""

import os
import sys
from pathlib import Path

# Add BoardLens project to path if available
boardlens_path = Path.home() / "Projects/boardlens/boardlens-python-api"
if boardlens_path.exists():
    sys.path.insert(0, str(boardlens_path))
    
    # Also check if we're already in the BoardLens directory
    current_path = Path.cwd()
    if "boardlens-python-api" in str(current_path):
        sys.path.insert(0, str(current_path))
    
    try:
        from signal_notify import request_permission, notify_task_complete, setup_notifier
        SIGNAL_AVAILABLE = True
    except ImportError:
        SIGNAL_AVAILABLE = False
else:
    SIGNAL_AVAILABLE = False

def notify_session_start(project_name: str = None):
    """Notify when a new Claude Code session starts"""
    if not SIGNAL_AVAILABLE:
        return
        
    notifier = setup_notifier()
    if not notifier:
        return
        
    message = "🚀 Claude Code Session Started"
    if project_name:
        message += f"\nProject: {project_name}"
    
    notifier.notify(message)

def request_tool_permission(tool_name: str, description: str = "") -> bool:
    """Request permission before using a specific tool"""
    if not SIGNAL_AVAILABLE:
        return True  # Default allow if not configured
        
    message = f"🔧 Tool Permission Request\n\nTool: {tool_name}"
    if description:
        message += f"\n{description}"
        
    return request_permission(message)

def notify_task_status(task: str, status: str = "complete"):
    """Notify about task status changes"""
    if not SIGNAL_AVAILABLE:
        return
        
    icons = {
        "complete": "✅",
        "failed": "❌",
        "in_progress": "🔄",
        "waiting": "⏳"
    }
    
    icon = icons.get(status, "📌")
    notify_task_complete(f"{icon} {task}")

# Hook for Claude Code to call
def on_session_start():
    """Called when Claude Code session starts"""
    cwd = os.getcwd()
    project_name = Path(cwd).name
    notify_session_start(project_name)

if __name__ == "__main__":
    # Test the notifier
    if SIGNAL_AVAILABLE:
        print("Signal integration available")
        on_session_start()
    else:
        print("Signal integration not available")