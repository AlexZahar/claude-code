#!/usr/bin/env python3
"""
Code Change Memory Hook for Claude Code
Tracks file modifications and maintains a lightweight change log
"""

import json
import sys
import os
import hashlib
import re
from datetime import datetime
from pathlib import Path
import subprocess
from collections import defaultdict

class CodeChangeTracker:
    """Tracks code changes across BoardLens projects"""
    
    def __init__(self):
        self.changes_base = Path.home() / ".claude" / "code-changes"
        self.changes_base.mkdir(exist_ok=True)
        
        # File patterns to track
        self.track_patterns = [
            '*.py', '*.js', '*.jsx', '*.ts', '*.tsx',
            '*.json', '*.yaml', '*.yml', '*.toml',
            '*.md', '*.txt', '*.env*',
            'Dockerfile', 'docker-compose.yml'
        ]
        
        # Patterns to ignore
        self.ignore_patterns = [
            'node_modules/', '__pycache__/', '.git/',
            '.next/', 'dist/', 'build/', '.cache/',
            '*.log', '*.lock', 'package-lock.json'
        ]
        
    def should_track_file(self, file_path):
        """Determine if a file should be tracked"""
        path_str = str(file_path)
        
        # Check ignore patterns
        for pattern in self.ignore_patterns:
            if pattern in path_str:
                return False
        
        # Check file extension
        for pattern in self.track_patterns:
            if file_path.match(pattern):
                return True
                
        return False
    
    def get_file_hash(self, file_path):
        """Get hash of file contents"""
        try:
            content = file_path.read_bytes()
            return hashlib.md5(content).hexdigest()
        except:
            return None
    
    def load_change_log(self, project):
        """Load existing change log for project"""
        log_file = self.changes_base / f"{project}_changes.json"
        
        if log_file.exists():
            try:
                return json.loads(log_file.read_text())
            except:
                return self._create_empty_log()
        return self._create_empty_log()
    
    def _create_empty_log(self):
        """Create empty change log structure"""
        return {
            'files': {},  # file_path -> {last_hash, last_modified, change_count}
            'recent_changes': [],  # List of recent changes
            'change_summary': defaultdict(int),  # Summary by change type
            'hot_files': defaultdict(int)  # Files with most changes
        }

def track_file_changes(file_path, project_name, change_type='modified'):
    """Track changes to a specific file"""
    tracker = CodeChangeTracker()
    
    if not tracker.should_track_file(file_path):
        return
    
    # Load existing log
    log = tracker.load_change_log(project_name)
    
    # Get file info
    rel_path = str(file_path.relative_to(file_path.parent.parent.parent))
    file_hash = tracker.get_file_hash(file_path)
    
    # Check if file has actually changed
    if rel_path in log['files']:
        if log['files'][rel_path]['last_hash'] == file_hash:
            return  # No actual change
    
    # Record the change
    timestamp = datetime.now().isoformat()
    
    # Update file info
    log['files'][rel_path] = {
        'last_hash': file_hash,
        'last_modified': timestamp,
        'change_count': log['files'].get(rel_path, {}).get('change_count', 0) + 1
    }
    
    # Add to recent changes
    change_entry = {
        'timestamp': timestamp,
        'file': rel_path,
        'type': change_type,
        'hash': file_hash[:8],  # Short hash
        'summary': analyze_change_content(file_path, change_type)
    }
    
    log['recent_changes'].insert(0, change_entry)
    log['recent_changes'] = log['recent_changes'][:100]  # Keep last 100
    
    # Update summaries
    log['change_summary'][change_type] += 1
    log['hot_files'][rel_path] += 1
    
    # Save updated log
    save_change_log(project_name, log)
    
    return change_entry

def analyze_change_content(file_path, change_type):
    """Analyze what kind of change was made"""
    try:
        if change_type == 'deleted':
            return "File deleted"
        
        if not file_path.exists():
            return "File not found"
            
        content = file_path.read_text()
        ext = file_path.suffix
        
        # Language-specific analysis
        if ext in ['.py']:
            return analyze_python_change(content)
        elif ext in ['.js', '.jsx', '.ts', '.tsx']:
            return analyze_javascript_change(content)
        elif ext in ['.json']:
            return analyze_json_change(content)
        elif ext in ['.md']:
            return analyze_markdown_change(content)
        else:
            return f"{change_type.capitalize()} {ext} file"
            
    except:
        return f"{change_type.capitalize()} file"

def analyze_python_change(content):
    """Analyze Python file changes"""
    summary = []
    
    # Check for new imports
    imports = re.findall(r'^import\s+(\w+)|^from\s+(\w+)', content, re.MULTILINE)
    if imports:
        summary.append(f"{len(imports)} imports")
    
    # Check for new functions/classes
    functions = re.findall(r'^def\s+(\w+)', content, re.MULTILINE)
    classes = re.findall(r'^class\s+(\w+)', content, re.MULTILINE)
    
    if functions:
        summary.append(f"{len(functions)} functions")
    if classes:
        summary.append(f"{len(classes)} classes")
    
    # Check for API endpoints (FastAPI)
    endpoints = re.findall(r'@app\.(get|post|put|delete|patch)', content)
    if endpoints:
        summary.append(f"{len(endpoints)} endpoints")
    
    return ', '.join(summary) if summary else "Python code update"

def analyze_javascript_change(content):
    """Analyze JavaScript/TypeScript file changes"""
    summary = []
    
    # Check for React components
    components = re.findall(r'(?:function|const)\s+(\w+).*?=.*?=>|(?:function|const)\s+(\w+).*?\{.*?return.*?<', content, re.DOTALL)
    if components:
        summary.append(f"{len(components)} components")
    
    # Check for exports
    exports = re.findall(r'export\s+(?:default\s+)?(?:function|const|class)\s+(\w+)', content)
    if exports:
        summary.append(f"{len(exports)} exports")
    
    # Check for API calls
    api_calls = re.findall(r'fetch\s*\(|axios\.|api\.', content)
    if api_calls:
        summary.append("API calls")
    
    return ', '.join(summary) if summary else "JavaScript code update"

def analyze_json_change(content):
    """Analyze JSON file changes"""
    try:
        data = json.loads(content)
        
        if 'dependencies' in data:
            return f"Package config ({len(data.get('dependencies', {}))} deps)"
        elif 'scripts' in data:
            return f"Scripts config ({len(data.get('scripts', {}))} scripts)"
        else:
            return f"JSON config ({len(data)} keys)"
    except:
        return "JSON file update"

def analyze_markdown_change(content):
    """Analyze Markdown file changes"""
    lines = content.split('\n')
    
    # Count headers
    headers = [l for l in lines if l.startswith('#')]
    
    # Look for code blocks
    code_blocks = len(re.findall(r'```', content)) // 2
    
    summary = []
    if headers:
        summary.append(f"{len(headers)} sections")
    if code_blocks:
        summary.append(f"{code_blocks} code blocks")
    
    return ', '.join(summary) if summary else "Documentation update"

def save_change_log(project_name, log):
    """Save the change log"""
    tracker = CodeChangeTracker()
    log_file = tracker.changes_base / f"{project_name}_changes.json"
    
    # Clean up old entries
    if len(log['recent_changes']) > 100:
        log['recent_changes'] = log['recent_changes'][:100]
    
    # Keep only top 20 hot files
    hot_files = sorted(log['hot_files'].items(), key=lambda x: x[1], reverse=True)[:20]
    log['hot_files'] = dict(hot_files)
    
    # Save
    log_file.write_text(json.dumps(log, indent=2))

def generate_change_report(project_name):
    """Generate a human-readable change report"""
    tracker = CodeChangeTracker()
    log = tracker.load_change_log(project_name)
    
    if not log['recent_changes']:
        return f"No changes tracked for {project_name}"
    
    report = f"""# Code Change Report: {project_name}
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Recent Changes (Last 20)
"""
    
    for change in log['recent_changes'][:20]:
        time = datetime.fromisoformat(change['timestamp']).strftime('%Y-%m-%d %H:%M')
        report += f"- **{time}** - {change['file']} - {change['summary']}\n"
    
    report += f"\n## Change Summary\n"
    for change_type, count in log['change_summary'].items():
        report += f"- {change_type.capitalize()}: {count}\n"
    
    report += f"\n## Most Changed Files\n"
    for file_path, count in list(log['hot_files'].items())[:10]:
        report += f"- {file_path}: {count} changes\n"
    
    report += f"\n## Tracked Files\n"
    report += f"Total files tracked: {len(log['files'])}\n"
    
    return report

def detect_project_from_path(file_path):
    """Detect which BoardLens project a file belongs to"""
    path_parts = Path(file_path).parts
    
    projects = [
        'boardlens-frontend',
        'boardlens-backend',
        'boardlens-python-api',
        'boardlens-rag'
    ]
    
    for project in projects:
        if project in path_parts:
            return project
    
    return None

def main():
    """Main hook execution"""
    try:
        # Get file path from arguments or environment
        if len(sys.argv) > 1:
            file_path = Path(sys.argv[1])
        else:
            file_path = Path(os.environ.get('CLAUDE_CHANGED_FILE', ''))
        
        if not file_path or not file_path.exists():
            print("[Code Change] No file specified or file doesn't exist")
            return
        
        # Detect project
        project = detect_project_from_path(file_path)
        
        if not project:
            print(f"[Code Change] File not in a BoardLens project: {file_path}")
            return
        
        # Determine change type
        change_type = os.environ.get('CLAUDE_CHANGE_TYPE', 'modified')
        
        # Track the change
        change = track_file_changes(file_path, project, change_type)
        
        if change:
            print(f"[Code Change] Tracked: {change['file']} - {change['summary']}")
        
        # Generate report if requested
        if os.environ.get('CLAUDE_GENERATE_REPORT'):
            report = generate_change_report(project)
            report_file = Path.home() / ".claude" / "code-changes" / f"{project}_report.md"
            report_file.write_text(report)
            print(f"[Code Change] Report saved to: {report_file}")
        
    except Exception as e:
        print(f"[Code Change] Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()