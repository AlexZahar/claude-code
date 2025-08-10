#!/usr/bin/env python3
"""
Smart Memory Batcher for Graphiti
Batches related operations within time windows to reduce API calls
and create more meaningful memories.
"""

import json
import time
import asyncio
from datetime import datetime
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Tuple, Optional
import os
import subprocess

class SmartMemoryBatcher:
    def __init__(self, flush_interval: int = 30):
        self.flush_interval = flush_interval  # seconds
        self.batch_file = Path.home() / ".claude" / "graphiti-batch.json"
        self.config_file = Path.home() / ".claude" / "memory-config.json"
        self.project_context = self.get_project_context()
        self.load_config()
        self.load_batch()
        
    def load_config(self):
        """Load configuration from file or use defaults"""
        if self.config_file.exists():
            with open(self.config_file, 'r') as f:
                self.config = json.load(f)
        else:
            self.config = self.get_default_config()
            self.save_config()
    
    def get_default_config(self) -> dict:
        """Default configuration for memory system"""
        return {
            "batching": {
                "enabled": True,
                "window_seconds": 30,
                "min_batch_size": 2,
                "max_batch_size": 50
            },
            "filtering": {
                "min_file_change_lines": 5,
                "ignore_patterns": ["*.log", "*.tmp", "__pycache__", ".git", "node_modules"],
                "trivial_commands": ["ls", "cd", "pwd", "echo", "cat", "which", "clear"]
            },
            "importance_rules": {
                "high": ["git commit", "npm publish", "deploy", "migration", "hotfix"],
                "medium": ["test", "refactor", "feature", "npm install", "pip install"],
                "low": ["style", "typo", "format", "lint"]
            },
            "context_detection": {
                "test_patterns": ["test_", "_test.py", ".test.js", "spec.js"],
                "config_files": ["package.json", "requirements.txt", "docker-compose.yml", ".env"],
                "important_dirs": ["src", "lib", "api", "core", "components"]
            }
        }
    
    def save_config(self):
        """Save configuration to file"""
        with open(self.config_file, 'w') as f:
            json.dump(self.config, f, indent=2)
    
    def get_project_context(self) -> str:
        """Get current project context from git or directory"""
        try:
            # Check if we're in a git repository
            result = subprocess.run(
                ['git', 'rev-parse', '--show-toplevel'],
                capture_output=True,
                text=True,
                check=False
            )
            if result.returncode == 0:
                repo_path = result.stdout.strip()
                return os.path.basename(repo_path)
        except:
            pass
        
        # Fallback to current directory name
        cwd = os.getcwd()
        dir_name = os.path.basename(cwd)
        if dir_name in ['.claude', os.path.basename(os.path.expanduser('~'))]:
            return 'general'
        return dir_name
    
    def load_batch(self):
        """Load existing batch from file"""
        if self.batch_file.exists():
            with open(self.batch_file, 'r') as f:
                data = json.load(f)
                self.batch = data.get('batch', {
                    'file_edits': defaultdict(list),
                    'commands': [],
                    'discoveries': [],
                    'errors': []
                })
                self.last_flush = data.get('last_flush', time.time())
        else:
            self.reset_batch()
    
    def reset_batch(self):
        """Reset batch to empty state"""
        self.batch = {
            'file_edits': defaultdict(list),
            'commands': [],
            'discoveries': [],
            'errors': []
        }
        self.last_flush = time.time()
    
    def save_batch(self):
        """Save current batch to file"""
        data = {
            'batch': dict(self.batch),
            'last_flush': self.last_flush
        }
        with open(self.batch_file, 'w') as f:
            json.dump(data, f)
    
    def add_file_edit(self, file_path: str, action: str):
        """Add a file edit to the batch"""
        module = self.get_module_from_path(file_path)
        self.batch['file_edits'][module].append({
            'path': file_path,
            'action': action,
            'timestamp': datetime.now().isoformat()
        })
        self.save_batch()
        self.maybe_flush()
    
    def add_command(self, command: str, exit_code: int):
        """Add a command to the batch"""
        importance = self.get_command_importance(command)
        self.batch['commands'].append({
            'command': command,
            'exit_code': exit_code,
            'importance': importance,
            'timestamp': datetime.now().isoformat()
        })
        self.save_batch()
        self.maybe_flush()
    
    def add_discovery(self, discovery: str, context: str):
        """Add a discovery to the batch"""
        self.batch['discoveries'].append({
            'discovery': discovery,
            'context': context,
            'timestamp': datetime.now().isoformat()
        })
        self.save_batch()
        self.maybe_flush()
    
    def add_error(self, error: str, context: str):
        """Add an error to the batch"""
        self.batch['errors'].append({
            'error': error,
            'context': context,
            'timestamp': datetime.now().isoformat()
        })
        self.save_batch()
        # Errors should flush immediately
        self.flush()
    
    def get_module_from_path(self, file_path: str) -> str:
        """Extract module/feature name from file path"""
        path = Path(file_path)
        
        # Check if it's in an important directory
        for important_dir in self.config['context_detection']['important_dirs']:
            if important_dir in path.parts:
                idx = path.parts.index(important_dir)
                if idx + 1 < len(path.parts):
                    return path.parts[idx + 1]
        
        # Otherwise use parent directory
        return path.parent.name if path.parent.name else 'root'
    
    def get_command_importance(self, command: str) -> str:
        """Determine command importance"""
        cmd_lower = command.lower()
        
        for level, patterns in self.config['importance_rules'].items():
            for pattern in patterns:
                if pattern in cmd_lower:
                    return level
        
        return 'low'
    
    def detect_work_context(self, file_edits: Dict[str, List]) -> str:
        """Detect what kind of work is being done"""
        all_files = []
        for edits in file_edits.values():
            all_files.extend([e['path'] for e in edits])
        
        # Check for test development
        test_count = sum(1 for f in all_files if any(
            pattern in f for pattern in self.config['context_detection']['test_patterns']
        ))
        if test_count > len(all_files) / 2:
            return "test_development"
        
        # Check for config changes
        config_changed = any(
            any(config in f for config in self.config['context_detection']['config_files'])
            for f in all_files
        )
        if config_changed:
            return "configuration_update"
        
        # Check for major refactoring
        if len(all_files) > 10:
            return "major_refactoring"
        
        # Check if mostly in one module
        modules = list(file_edits.keys())
        if len(modules) == 1:
            return f"feature_development_in_{modules[0]}"
        
        return "general_development"
    
    def create_summary(self) -> Optional[str]:
        """Create a human-readable summary of the batch"""
        if not self.has_significant_changes():
            return None
        
        # Update project context in case we changed directories
        self.project_context = self.get_project_context()
        
        parts = []
        
        # Summarize file edits
        if self.batch['file_edits']:
            context = self.detect_work_context(self.batch['file_edits'])
            file_count = sum(len(edits) for edits in self.batch['file_edits'].values())
            modules = list(self.batch['file_edits'].keys())
            
            if context == "test_development":
                parts.append(f"Test development: Modified {file_count} test files")
            elif context == "configuration_update":
                parts.append(f"Configuration update: Changed project settings")
            elif context == "major_refactoring":
                parts.append(f"Major refactoring: Updated {file_count} files across {len(modules)} modules")
            elif context.startswith("feature_development_in_"):
                module = context.replace("feature_development_in_", "")
                parts.append(f"Feature work in {module}: Modified {file_count} files")
            else:
                parts.append(f"Code changes: {file_count} files in {', '.join(modules[:3])}")
        
        # Summarize important commands
        if self.batch['commands']:
            high_importance = [c for c in self.batch['commands'] if c['importance'] == 'high']
            failed = [c for c in self.batch['commands'] if c['exit_code'] != 0]
            
            if high_importance:
                parts.append(f"Executed: {', '.join(c['command'].split()[0] for c in high_importance[:3])}")
            if failed:
                parts.append(f"Failed commands: {len(failed)}")
        
        # Include discoveries
        if self.batch['discoveries']:
            parts.append(f"Discoveries: {self.batch['discoveries'][0]['discovery']}")
        
        # Include errors
        if self.batch['errors']:
            parts.append(f"Errors encountered: {self.batch['errors'][0]['error']}")
        
        # Prepend project context to summary
        summary = " | ".join(parts) if parts else None
        if summary and self.project_context != 'general':
            summary = f"[{self.project_context}] {summary}"
        
        return summary
    
    def has_significant_changes(self) -> bool:
        """Check if batch has enough significant changes to flush"""
        min_size = self.config['batching']['min_batch_size']
        
        # Count significant items
        file_count = sum(len(edits) for edits in self.batch['file_edits'].values())
        important_commands = sum(1 for c in self.batch['commands'] if c['importance'] in ['high', 'medium'])
        
        total_significant = file_count + important_commands + len(self.batch['discoveries']) + len(self.batch['errors'])
        
        return total_significant >= min_size
    
    def maybe_flush(self):
        """Check if it's time to flush the batch"""
        time_elapsed = time.time() - self.last_flush
        
        # Flush if time window exceeded
        if time_elapsed > self.config['batching']['window_seconds']:
            self.flush()
        # Or if batch is getting too large
        elif sum(len(v) if isinstance(v, list) else len(list(v.values())) 
                for v in self.batch.values()) > self.config['batching']['max_batch_size']:
            self.flush()
    
    def flush(self) -> Optional[str]:
        """Flush the current batch and return summary"""
        summary = self.create_summary()
        
        if summary:
            # Reset batch
            self.reset_batch()
            self.save_batch()
            return summary
        
        return None

# CLI interface
if __name__ == "__main__":
    import sys
    
    batcher = SmartMemoryBatcher()
    
    if len(sys.argv) < 2:
        print("Usage: graphiti-batcher.py {add_file|add_command|add_discovery|add_error|flush|status}")
        sys.exit(1)
    
    action = sys.argv[1]
    
    if action == "add_file" and len(sys.argv) >= 4:
        batcher.add_file_edit(sys.argv[2], sys.argv[3])
        print("File edit added to batch")
    
    elif action == "add_command" and len(sys.argv) >= 4:
        batcher.add_command(sys.argv[2], int(sys.argv[3]))
        print("Command added to batch")
    
    elif action == "add_discovery" and len(sys.argv) >= 4:
        batcher.add_discovery(sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else "")
        print("Discovery added to batch")
    
    elif action == "add_error" and len(sys.argv) >= 4:
        batcher.add_error(sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else "")
        print("Error added to batch")
    
    elif action == "flush":
        summary = batcher.flush()
        if summary:
            print(f"Flushed: {summary}")
        else:
            print("Nothing significant to flush")
    
    elif action == "status":
        print(f"Batch size: {sum(len(v) if isinstance(v, list) else sum(len(vv) for vv in v.values()) for v in batcher.batch.values())} items")
        print(f"Time since last flush: {int(time.time() - batcher.last_flush)} seconds")
        print(f"Has significant changes: {batcher.has_significant_changes()}")
    
    else:
        print(f"Unknown action: {action}")
        sys.exit(1)