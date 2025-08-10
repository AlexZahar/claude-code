#!/usr/bin/env python3
"""
Weekly Architecture Snapshot Hook
Creates periodic snapshots of project architecture for memory and documentation.
"""

import os
import sys
import json
import subprocess
import hashlib
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Set

# Configuration
SNAPSHOT_DIR = Path.home() / ".claude" / "architecture-snapshots"
GRAPHITI_HOOK = Path.home() / ".claude" / "graphiti-hook.sh"
LOG_FILE = Path.home() / ".claude" / "architecture-snapshot.log"

# Force snapshot if environment variable is set
FORCE_SNAPSHOT = os.environ.get('FORCE_SNAPSHOT', '0') == '1'

class ArchitectureSnapshot:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.project_name = self.project_path.name
        self.timestamp = datetime.now()
        
    def log(self, message: str):
        """Log message to file and stdout if forcing"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_message = f"[{timestamp}] [ARCH-SNAPSHOT] {message}"
        
        with open(LOG_FILE, 'a') as f:
            f.write(log_message + '\n')
            
        if FORCE_SNAPSHOT:
            print(log_message)
    
    def should_create_snapshot(self) -> bool:
        """Check if snapshot should be created based on last snapshot time"""
        if FORCE_SNAPSHOT:
            return True
            
        # Check for last snapshot
        snapshot_pattern = f"{self.project_name}_*.json"
        snapshots = list(SNAPSHOT_DIR.glob(snapshot_pattern))
        
        if not snapshots:
            return True
            
        # Get most recent snapshot
        latest_snapshot = max(snapshots, key=lambda p: p.stat().st_mtime)
        last_modified = datetime.fromtimestamp(latest_snapshot.stat().st_mtime)
        
        # Create snapshot if more than 7 days old
        return datetime.now() - last_modified > timedelta(days=7)
    
    def get_file_structure(self) -> Dict:
        """Analyze project file structure and patterns"""
        structure = {
            "directories": {},
            "files_by_type": {},
            "key_files": [],
            "patterns": []
        }
        
        # Ignore patterns
        ignore_dirs = {'.git', 'node_modules', '__pycache__', '.venv', 'dist', 'build', '.next'}
        ignore_files = {'.DS_Store', '.gitignore', '*.log', '*.pyc', '*.map'}
        
        try:
            for root, dirs, files in os.walk(self.project_path):
                # Filter ignored directories
                dirs[:] = [d for d in dirs if d not in ignore_dirs]
                
                rel_root = Path(root).relative_to(self.project_path)
                if rel_root == Path('.'):
                    rel_root = ''
                else:
                    rel_root = str(rel_root)
                
                # Count files by type
                for file in files:
                    if any(file.endswith(pattern.lstrip('*')) for pattern in ignore_files if pattern.startswith('*')):
                        continue
                        
                    file_path = Path(root) / file
                    suffix = file_path.suffix.lower()
                    
                    if suffix not in structure["files_by_type"]:
                        structure["files_by_type"][suffix] = 0
                    structure["files_by_type"][suffix] += 1
                    
                    # Mark key files
                    if file in ['package.json', 'pyproject.toml', 'Dockerfile', 'docker-compose.yml', 
                              'requirements.txt', 'README.md', 'tsconfig.json', '.env.example']:
                        structure["key_files"].append(str(file_path.relative_to(self.project_path)))
                        
        except Exception as e:
            self.log(f"Error analyzing file structure: {e}")
            
        return structure
    
    def detect_technologies(self) -> List[str]:
        """Detect technologies used in the project"""
        technologies = set()
        
        # Check package.json
        package_json = self.project_path / "package.json"
        if package_json.exists():
            try:
                with open(package_json) as f:
                    data = json.load(f)
                    deps = {**data.get('dependencies', {}), **data.get('devDependencies', {})}
                    
                    # Detect frameworks
                    if 'react' in deps: technologies.add('React')
                    if 'vue' in deps: technologies.add('Vue')
                    if 'angular' in deps: technologies.add('Angular')
                    if 'next' in deps: technologies.add('Next.js')
                    if 'express' in deps: technologies.add('Express')
                    if 'typescript' in deps: technologies.add('TypeScript')
                    if 'tailwindcss' in deps: technologies.add('TailwindCSS')
                    
            except Exception as e:
                self.log(f"Error reading package.json: {e}")
        
        # Check pyproject.toml / requirements.txt
        pyproject = self.project_path / "pyproject.toml"
        requirements = self.project_path / "requirements.txt"
        
        if pyproject.exists() or requirements.exists():
            technologies.add('Python')
            
            # Check for FastAPI, Flask, Django, etc.
            for file in [pyproject, requirements]:
                if file.exists():
                    try:
                        content = file.read_text()
                        if 'fastapi' in content.lower(): technologies.add('FastAPI')
                        if 'flask' in content.lower(): technologies.add('Flask')
                        if 'django' in content.lower(): technologies.add('Django')
                        if 'graphiti' in content.lower(): technologies.add('Graphiti')
                    except Exception as e:
                        self.log(f"Error reading {file}: {e}")
        
        # Check Dockerfile
        dockerfile = self.project_path / "Dockerfile"
        if dockerfile.exists():
            technologies.add('Docker')
            
        return sorted(list(technologies))
    
    def get_recent_changes(self) -> Optional[Dict]:
        """Get recent git changes if this is a git repository"""
        if not (self.project_path / ".git").exists():
            return None
            
        try:
            # Get recent commits (last 30 days)
            since_date = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
            
            result = subprocess.run([
                'git', '-C', str(self.project_path), 'log', 
                '--since', since_date, '--oneline', '--no-merges'
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                commits = result.stdout.strip().split('\n') if result.stdout.strip() else []
                return {
                    "recent_commits": len(commits),
                    "commits_sample": commits[:5],  # Last 5 commits
                    "since_date": since_date
                }
        except Exception as e:
            self.log(f"Error getting git changes: {e}")
            
        return None
    
    def create_snapshot(self) -> Dict:
        """Create comprehensive architecture snapshot"""
        snapshot = {
            "project_name": self.project_name,
            "project_path": str(self.project_path),
            "timestamp": self.timestamp.isoformat(),
            "structure": self.get_file_structure(),
            "technologies": self.detect_technologies(),
            "git_info": self.get_recent_changes(),
            "metadata": {
                "total_files": sum(self.get_file_structure()["files_by_type"].values()),
                "snapshot_type": "forced" if FORCE_SNAPSHOT else "scheduled"
            }
        }
        
        return snapshot
    
    def save_snapshot(self, snapshot: Dict) -> Path:
        """Save snapshot to file"""
        SNAPSHOT_DIR.mkdir(exist_ok=True)
        
        # Create filename with timestamp
        timestamp_str = self.timestamp.strftime('%Y%m%d_%H%M%S')
        filename = f"{self.project_name}_{timestamp_str}.json"
        filepath = SNAPSHOT_DIR / filename
        
        with open(filepath, 'w') as f:
            json.dump(snapshot, f, indent=2)
            
        return filepath
    
    def add_to_memory(self, snapshot: Dict, filepath: Path):
        """Add snapshot summary to Graphiti memory"""
        if not GRAPHITI_HOOK.exists():
            self.log("Graphiti hook not found, skipping memory addition")
            return
            
        # Create memory-friendly summary
        tech_list = ", ".join(snapshot["technologies"])
        total_files = snapshot["metadata"]["total_files"]
        
        summary = (f"ARCHITECTURE SNAPSHOT [{self.timestamp.strftime('%Y-%m-%d')}]: "
                  f"{self.project_name} project analysis - {total_files} files, "
                  f"Technologies: {tech_list}. "
                  f"Snapshot saved: {filepath.name}")
        
        try:
            subprocess.run([str(GRAPHITI_HOOK), "add", summary], 
                         capture_output=True, text=True, timeout=30)
            self.log(f"Added snapshot summary to memory: {len(summary)} chars")
        except Exception as e:
            self.log(f"Error adding to memory: {e}")


def main():
    """Main execution"""
    # Get current working directory as project path
    project_path = os.getcwd()
    
    if len(sys.argv) > 1:
        project_path = sys.argv[1]
        
    if not os.path.exists(project_path):
        print(f"Error: Project path does not exist: {project_path}", file=sys.stderr)
        sys.exit(1)
        
    snapshot_tool = ArchitectureSnapshot(project_path)
    
    if not snapshot_tool.should_create_snapshot():
        snapshot_tool.log(f"Snapshot not needed for {snapshot_tool.project_name} (recent snapshot exists)")
        return
        
    snapshot_tool.log(f"Creating architecture snapshot for {snapshot_tool.project_name}")
    
    try:
        # Create snapshot
        snapshot = snapshot_tool.create_snapshot()
        
        # Save to file
        filepath = snapshot_tool.save_snapshot(snapshot)
        snapshot_tool.log(f"Snapshot saved: {filepath}")
        
        # Add to memory
        snapshot_tool.add_to_memory(snapshot, filepath)
        
        print(f"✅ Architecture snapshot created: {filepath}")
        
    except Exception as e:
        error_msg = f"Error creating snapshot: {e}"
        snapshot_tool.log(error_msg)
        print(f"❌ {error_msg}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()