#!/usr/bin/env python3
"""
Smart Memory Assessor for Claude Code
=====================================
Lightweight importance assessment before saving to Graphiti.
Prevents noise while keeping valuable memories.
"""

import json
import re
import hashlib
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Tuple, Optional

class MemoryAssessor:
    """Assesses whether information should be saved to memory graph"""
    
    def __init__(self, config_path: str = "/Users/zahar/.claude/memory-config.json"):
        with open(config_path) as f:
            self.config = json.load(f)
        
        # Track recent memories to avoid duplicates
        self.recent_hashes = []
        self.recent_cache_file = Path.home() / ".claude" / "recent_memory_hashes.json"
        self._load_recent_hashes()
    
    def _load_recent_hashes(self):
        """Load recent memory hashes from cache"""
        if self.recent_cache_file.exists():
            try:
                with open(self.recent_cache_file) as f:
                    data = json.load(f)
                    # Keep only hashes from last 24 hours
                    cutoff = (datetime.now() - timedelta(hours=24)).isoformat()
                    self.recent_hashes = [
                        h for h in data 
                        if h.get("timestamp", "") > cutoff
                    ]
            except:
                self.recent_hashes = []
    
    def _save_recent_hashes(self):
        """Save recent memory hashes to cache"""
        with open(self.recent_cache_file, 'w') as f:
            json.dump(self.recent_hashes, f)
    
    def _content_hash(self, content: str) -> str:
        """Generate hash of content for duplicate detection"""
        # Normalize whitespace and case for better duplicate detection
        normalized = re.sub(r'\s+', ' ', content.lower().strip())
        return hashlib.md5(normalized.encode()).hexdigest()[:8]
    
    def assess_importance(self, content: str, context: Dict[str, any] = None) -> Tuple[bool, str, str]:
        """
        Assess if memory should be saved.
        
        Returns:
            (should_save, importance_level, reason)
        """
        
        # 1. Check for duplicates
        content_hash = self._content_hash(content)
        if any(h["hash"] == content_hash for h in self.recent_hashes):
            return False, "duplicate", "Similar memory saved recently"
        
        # 2. Parse context if it's a string
        if isinstance(context, str):
            try:
                context = json.loads(context) if context else {}
            except:
                context = {}
        elif context is None:
            context = {}
        
        # 3. Extract context clues
        memory_type = context.get("type", "unknown")
        file_path = context.get("file_path", "")
        command = context.get("command", "")
        exit_code = context.get("exit_code", 0)
        
        # 3. Apply filtering rules
        
        # File edits
        if memory_type == "file_edit":
            # Skip ignored patterns
            for pattern in self.config["filtering"]["ignore_patterns"]:
                if pattern.replace("*", "") in file_path:
                    return False, "ignored", f"File matches ignore pattern: {pattern}"
            
            # Skip trivial changes
            lines_changed = context.get("lines_changed", 0)
            if lines_changed < self.config["filtering"]["min_file_change_lines"]:
                return False, "trivial", f"Only {lines_changed} lines changed"
            
            # Check if it's an important directory
            for important_dir in self.config["context_detection"]["important_dirs"]:
                if important_dir in file_path:
                    return True, "medium", f"Edit in important directory: {important_dir}"
            
            # Check if it's a test file
            for test_pattern in self.config["context_detection"]["test_patterns"]:
                if test_pattern in file_path:
                    return True, "medium", "Test file modification"
        
        # Commands
        elif memory_type == "command":
            # Skip trivial commands
            first_word = command.split()[0] if command else ""
            if first_word in self.config["filtering"]["trivial_commands"]:
                return False, "trivial", f"Trivial command: {first_word}"
            
            # Failed commands are always important
            if exit_code != 0:
                return True, "high", f"Command failed with exit code {exit_code}"
            
            # Check importance rules
            for level, patterns in self.config["importance_rules"].items():
                for pattern in patterns:
                    if pattern in command:
                        return True, level, f"Important command: {pattern}"
        
        # Bug fixes and features
        elif memory_type in ["bug_fix", "feature", "discovery"]:
            # These are always important
            return True, "high", f"Important {memory_type}"
        
        # Feature implementations
        elif any(keyword in content.lower() for keyword in ["feature", "implement", "add", "create"]):
            return True, "medium", "Feature implementation"
        
        # Performance and security issues
        elif "performance" in content.lower() or "security" in content.lower():
            return True, "high", "Performance or security related"
        
        # Errors and exceptions
        elif any(keyword in content.lower() for keyword in ["error", "exception", "failed", "crash"]):
            return True, "high", "Error or failure detected"
        
        # Architecture decisions
        elif any(keyword in content.lower() for keyword in ["decided", "switched", "migrated", "refactored"]):
            return True, "medium", "Architecture decision"
        
        # Default: Don't save routine operations
        return False, "low", "Routine operation"
    
    def create_summary(self, memories: List[Dict]) -> str:
        """Create intelligent summary of batched memories"""
        if not memories:
            return ""
        
        # Group by type
        file_edits = [m for m in memories if m.get("type") == "file_edit"]
        commands = [m for m in memories if m.get("type") == "command"]
        others = [m for m in memories if m.get("type") not in ["file_edit", "command"]]
        
        summary_parts = []
        
        # Summarize file edits
        if file_edits:
            unique_files = list(set(m.get("file_path", "") for m in file_edits))
            if len(unique_files) == 1:
                summary_parts.append(f"Modified {unique_files[0]}")
            else:
                summary_parts.append(f"Modified {len(unique_files)} files")
        
        # Summarize commands
        if commands:
            important_cmds = [m for m in commands if m.get("importance") in ["high", "medium"]]
            if important_cmds:
                cmd_types = list(set(m.get("command", "").split()[0] for m in important_cmds))
                summary_parts.append(f"Ran {', '.join(cmd_types[:3])}")
        
        # Include other important memories
        for memory in others:
            if memory.get("importance") == "high":
                summary_parts.append(memory.get("content", "")[:50])
        
        return " | ".join(summary_parts) if summary_parts else "Multiple operations"
    
    def mark_as_saved(self, content: str):
        """Mark content as recently saved"""
        self.recent_hashes.append({
            "hash": self._content_hash(content),
            "timestamp": datetime.now().isoformat()
        })
        # Keep only last 1000 hashes
        self.recent_hashes = self.recent_hashes[-1000:]
        self._save_recent_hashes()


# CLI usage for testing
if __name__ == "__main__":
    import sys
    
    assessor = MemoryAssessor()
    
    if len(sys.argv) > 1:
        test_content = sys.argv[1]
        test_context = {
            "type": sys.argv[2] if len(sys.argv) > 2 else "unknown",
            "file_path": sys.argv[3] if len(sys.argv) > 3 else ""
        }
        
        should_save, importance, reason = assessor.assess_importance(test_content, test_context)
        
        print(f"Content: {test_content[:50]}...")
        print(f"Should save: {should_save}")
        print(f"Importance: {importance}")
        print(f"Reason: {reason}")
    else:
        print("Usage: smart-memory-assessor.py <content> [type] [file_path]")
        print("\nExample assessments:")
        
        # Test cases
        tests = [
            ("Fixed JWT token expiration bug", {"type": "bug_fix"}),
            ("ls -la", {"type": "command", "command": "ls -la"}),
            ("Updated README.md", {"type": "file_edit", "file_path": "README.md", "lines_changed": 2}),
            ("npm test", {"type": "command", "command": "npm test", "exit_code": 1}),
            ("Refactored auth module", {"type": "file_edit", "file_path": "src/auth/index.js", "lines_changed": 50}),
        ]
        
        for content, context in tests:
            should_save, importance, reason = assessor.assess_importance(content, context)
            print(f"\n'{content}' -> Save: {should_save}, Level: {importance}, Reason: {reason}")