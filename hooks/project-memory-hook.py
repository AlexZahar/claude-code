#!/usr/bin/env python3
"""
Project Memory Hook for Claude Code
Tracks per-project context and maintains project-specific memories
"""

import json
import sys
import subprocess
import os
from datetime import datetime, timedelta
from pathlib import Path
import hashlib

class ProjectMemoryManager:
    """Manages project-specific memory storage and retrieval"""
    
    def __init__(self):
        self.memory_base = Path.home() / ".claude" / "project-memories"
        self.memory_base.mkdir(exist_ok=True)
        
    def get_project_memory_path(self, project_name):
        """Get the memory path for a specific project"""
        return self.memory_base / project_name
    
    def load_existing_memory(self, project_name):
        """Load existing project memory if available"""
        memory_file = self.get_project_memory_path(project_name) / "latest.md"
        
        if memory_file.exists():
            try:
                content = memory_file.read_text()
                # Extract key sections
                return self._parse_memory_content(content)
            except:
                return {}
        return {}
    
    def _parse_memory_content(self, content):
        """Parse memory content into structured data"""
        memory = {
            'last_updated': None,
            'active_tasks': [],
            'recent_changes': [],
            'technical_decisions': [],
            'dependencies': [],
            'known_issues': []
        }
        
        # Simple parsing - could be enhanced with better section detection
        lines = content.split('\n')
        current_section = None
        
        for line in lines:
            if 'Date & Time Stamp' in line:
                current_section = 'timestamp'
            elif 'Active Tasks' in line:
                current_section = 'active_tasks'
            elif 'Recent Changes' in line:
                current_section = 'recent_changes'
            elif 'Technical Decisions' in line:
                current_section = 'technical_decisions'
            elif 'Dependencies' in line:
                current_section = 'dependencies'
            elif 'Known Issues' in line:
                current_section = 'known_issues'
            elif line.strip().startswith('- ') and current_section in memory:
                if isinstance(memory[current_section], list):
                    memory[current_section].append(line.strip()[2:])
        
        return memory

def get_project_context(cwd):
    """Get comprehensive project context"""
    project_name = detect_boardlens_project(cwd)
    
    if not project_name:
        return None
    
    context = {
        'project_name': project_name,
        'cwd': cwd,
        'timestamp': datetime.now(),
        'git_info': get_project_git_info(cwd),
        'file_structure': analyze_file_structure(cwd),
        'dependencies': analyze_dependencies(cwd, project_name),
        'recent_activity': get_recent_activity(cwd),
        'active_todos': find_active_todos(cwd),
        'configuration': get_project_config(cwd, project_name)
    }
    
    return context

def detect_boardlens_project(cwd):
    """Detect which BoardLens project we're in"""
    path_parts = Path(cwd).parts
    
    boardlens_projects = [
        'boardlens-frontend',
        'boardlens-backend', 
        'boardlens-python-api',
        'boardlens-rag'
    ]
    
    for project in boardlens_projects:
        if project in path_parts:
            return project
    
    return None

def get_project_git_info(cwd):
    """Get detailed git information for the project"""
    try:
        info = {}
        
        # Current branch
        info['branch'] = subprocess.check_output(
            ['git', 'branch', '--show-current'],
            cwd=cwd, stderr=subprocess.DEVNULL
        ).decode().strip()
        
        # Recent commits with details
        commit_log = subprocess.check_output(
            ['git', 'log', '--pretty=format:%h|%an|%ar|%s', '-10'],
            cwd=cwd, stderr=subprocess.DEVNULL
        ).decode().strip()
        
        info['recent_commits'] = []
        for line in commit_log.split('\n'):
            if line:
                parts = line.split('|')
                if len(parts) >= 4:
                    info['recent_commits'].append({
                        'hash': parts[0],
                        'author': parts[1],
                        'time': parts[2],
                        'message': parts[3]
                    })
        
        # Uncommitted changes
        status = subprocess.check_output(
            ['git', 'status', '--porcelain'],
            cwd=cwd, stderr=subprocess.DEVNULL
        ).decode().strip()
        
        info['uncommitted_files'] = []
        for line in status.split('\n'):
            if line:
                info['uncommitted_files'].append({
                    'status': line[:2],
                    'file': line[3:]
                })
        
        # Remote info
        try:
            remote = subprocess.check_output(
                ['git', 'remote', 'get-url', 'origin'],
                cwd=cwd, stderr=subprocess.DEVNULL
            ).decode().strip()
            info['remote'] = remote
        except:
            info['remote'] = None
        
        return info
    except:
        return {'error': 'Unable to get git info'}

def analyze_file_structure(cwd):
    """Analyze key file structure changes"""
    structure = {
        'total_files': 0,
        'file_types': {},
        'key_directories': [],
        'recent_additions': []
    }
    
    try:
        # Count files by type
        for root, dirs, files in os.walk(cwd):
            # Skip node_modules and other large dirs
            dirs[:] = [d for d in dirs if d not in ['node_modules', '.git', '__pycache__', '.next', 'dist', 'build']]
            
            structure['total_files'] += len(files)
            
            for file in files:
                ext = Path(file).suffix
                if ext:
                    structure['file_types'][ext] = structure['file_types'].get(ext, 0) + 1
            
            # Track key directories
            rel_path = os.path.relpath(root, cwd)
            if rel_path != '.' and len(Path(rel_path).parts) <= 2:
                structure['key_directories'].append(rel_path)
        
        # Find recently added files (last 7 days)
        try:
            recent = subprocess.check_output(
                ['find', '.', '-type', 'f', '-mtime', '-7', '-not', '-path', '*/\\.*', '-not', '-path', '*/node_modules/*'],
                cwd=cwd, stderr=subprocess.DEVNULL
            ).decode().strip()
            
            structure['recent_additions'] = [f for f in recent.split('\n') if f][:20]
        except:
            pass
        
        return structure
    except:
        return structure

def analyze_dependencies(cwd, project_name):
    """Analyze project dependencies based on project type"""
    deps = {
        'internal': [],  # Dependencies on other BoardLens projects
        'external': {}   # External package dependencies
    }
    
    # Check for internal dependencies
    if project_name == 'boardlens-frontend':
        deps['internal'] = ['boardlens-backend', 'boardlens-python-api']
        # Check package.json
        package_json = Path(cwd) / 'package.json'
        if package_json.exists():
            try:
                data = json.loads(package_json.read_text())
                deps['external']['npm'] = {
                    'dependencies': len(data.get('dependencies', {})),
                    'devDependencies': len(data.get('devDependencies', {})),
                    'key_packages': list(data.get('dependencies', {}).keys())[:10]
                }
            except:
                pass
                
    elif project_name == 'boardlens-backend':
        deps['internal'] = ['boardlens-python-api']
        # Check package.json
        package_json = Path(cwd) / 'package.json'
        if package_json.exists():
            try:
                data = json.loads(package_json.read_text())
                deps['external']['npm'] = {
                    'dependencies': len(data.get('dependencies', {})),
                    'key_packages': list(data.get('dependencies', {}).keys())[:10]
                }
            except:
                pass
                
    elif project_name in ['boardlens-python-api', 'boardlens-rag']:
        # Check requirements.txt or pyproject.toml
        requirements = Path(cwd) / 'requirements.txt'
        pyproject = Path(cwd) / 'pyproject.toml'
        
        if requirements.exists():
            try:
                lines = requirements.read_text().split('\n')
                packages = [l.split('==')[0].split('>=')[0] for l in lines if l and not l.startswith('#')]
                deps['external']['pip'] = {
                    'total': len(packages),
                    'packages': packages[:10]
                }
            except:
                pass
    
    return deps

def get_recent_activity(cwd):
    """Get recent development activity"""
    activity = {
        'last_24h': [],
        'last_week': []
    }
    
    try:
        # Files changed in last 24 hours
        recent_24h = subprocess.check_output(
            ['git', 'log', '--since="24 hours ago"', '--name-only', '--pretty=format:'],
            cwd=cwd, stderr=subprocess.DEVNULL
        ).decode().strip()
        
        activity['last_24h'] = list(set([f for f in recent_24h.split('\n') if f]))[:10]
        
        # Summary of last week's commits
        week_summary = subprocess.check_output(
            ['git', 'log', '--since="1 week ago"', '--pretty=format:%s'],
            cwd=cwd, stderr=subprocess.DEVNULL
        ).decode().strip()
        
        activity['last_week'] = week_summary.split('\n')[:10] if week_summary else []
        
    except:
        pass
    
    return activity

def find_active_todos(cwd):
    """Find TODO/FIXME comments in the codebase"""
    todos = []
    
    try:
        # Search for TODO and FIXME comments
        result = subprocess.check_output(
            ['grep', '-r', '-n', '-E', '(TODO|FIXME|HACK|BUG|XXX):', '.', 
             '--include=*.py', '--include=*.js', '--include=*.jsx', '--include=*.ts', '--include=*.tsx'],
            cwd=cwd, stderr=subprocess.DEVNULL
        ).decode()
        
        for line in result.split('\n')[:20]:  # Limit to 20
            if line:
                parts = line.split(':', 2)
                if len(parts) >= 3:
                    todos.append({
                        'file': parts[0].replace('./', ''),
                        'line': parts[1],
                        'text': parts[2].strip()
                    })
    except:
        pass
    
    return todos

def get_project_config(cwd, project_name):
    """Get project-specific configuration info"""
    config = {}
    
    if project_name in ['boardlens-frontend', 'boardlens-backend']:
        # Check for .env files
        env_files = ['.env', '.env.local', '.env.development', '.env.production']
        config['env_files'] = []
        
        for env_file in env_files:
            if (Path(cwd) / env_file).exists():
                config['env_files'].append(env_file)
        
        # Check for config files
        if (Path(cwd) / 'next.config.js').exists() or (Path(cwd) / 'next.config.ts').exists():
            config['framework'] = 'Next.js'
        elif (Path(cwd) / 'package.json').exists():
            try:
                pkg = json.loads((Path(cwd) / 'package.json').read_text())
                if 'express' in pkg.get('dependencies', {}):
                    config['framework'] = 'Express'
            except:
                pass
    
    elif project_name in ['boardlens-python-api', 'boardlens-rag']:
        # Check for Python config files
        if (Path(cwd) / 'main.py').exists():
            config['entry_point'] = 'main.py'
        if (Path(cwd) / 'settings.py').exists():
            config['settings_file'] = True
        if (Path(cwd) / '.env').exists():
            config['env_file'] = True
    
    return config

def create_project_memory(context, previous_memory=None):
    """Create comprehensive project memory documentation"""
    timestamp = context['timestamp'].strftime("%Y-%m-%d %H:%M:%S")
    
    # Merge with previous memory to maintain continuity
    active_tasks = previous_memory.get('active_tasks', []) if previous_memory else []
    technical_decisions = previous_memory.get('technical_decisions', []) if previous_memory else []
    
    memory = f"""# Project Memory: {context['project_name']}
Last Updated: {timestamp}

## Project Overview
**Project:** {context['project_name']}
**Location:** {context['cwd']}
**Current Branch:** {context['git_info'].get('branch', 'unknown')}

## Recent Activity
### Last 24 Hours
{format_file_list(context['recent_activity']['last_24h'])}

### Recent Commits
{format_commits(context['git_info'].get('recent_commits', [])[:5])}

## File Structure
- Total Files: {context['file_structure']['total_files']}
- File Types: {format_file_types(context['file_structure']['file_types'])}
- Key Directories: {', '.join(context['file_structure']['key_directories'][:10])}

## Dependencies
### Internal BoardLens Dependencies
{format_list(context['dependencies']['internal'])}

### External Dependencies
{format_dependencies(context['dependencies']['external'])}

## Active Tasks and TODOs
{format_todos(context['active_todos'])}

## Uncommitted Changes
{format_uncommitted(context['git_info'].get('uncommitted_files', []))}

## Configuration
{format_config(context['configuration'])}

## Technical Context
{get_project_specific_context(context['project_name'])}

## Integration Points
{get_integration_points(context['project_name'])}

## Known Issues and Considerations
{format_list(previous_memory.get('known_issues', [])) if previous_memory else '- None documented'}

## Development Notes
{format_list(active_tasks)}

---
*This memory is automatically maintained by Claude Code hooks*
"""
    
    return memory

def format_file_list(files):
    """Format a list of files"""
    if not files:
        return "- No recent changes"
    return '\n'.join([f"- {f}" for f in files[:10]])

def format_commits(commits):
    """Format commit list"""
    if not commits:
        return "- No recent commits"
    
    lines = []
    for commit in commits:
        lines.append(f"- {commit['hash']} - {commit['message']} ({commit['time']})")
    return '\n'.join(lines)

def format_file_types(file_types):
    """Format file type statistics"""
    if not file_types:
        return "N/A"
    
    sorted_types = sorted(file_types.items(), key=lambda x: x[1], reverse=True)[:5]
    return ', '.join([f"{ext}: {count}" for ext, count in sorted_types])

def format_list(items):
    """Format a simple list"""
    if not items:
        return "- None"
    return '\n'.join([f"- {item}" for item in items])

def format_dependencies(deps):
    """Format dependency information"""
    lines = []
    
    for manager, info in deps.items():
        if manager == 'npm':
            lines.append(f"**NPM Packages:** {info.get('dependencies', 0)} dependencies")
            if info.get('key_packages'):
                lines.append("Key packages: " + ', '.join(info['key_packages'][:5]))
        elif manager == 'pip':
            lines.append(f"**Python Packages:** {info.get('total', 0)} packages")
            if info.get('packages'):
                lines.append("Key packages: " + ', '.join(info['packages'][:5]))
    
    return '\n'.join(lines) if lines else "- No external dependencies found"

def format_todos(todos):
    """Format TODO items"""
    if not todos:
        return "- No TODOs found"
    
    lines = []
    for todo in todos[:10]:
        lines.append(f"- {todo['file']}:{todo['line']} - {todo['text'][:80]}")
    
    return '\n'.join(lines)

def format_uncommitted(files):
    """Format uncommitted files"""
    if not files:
        return "- No uncommitted changes"
    
    lines = []
    for file in files[:10]:
        status_map = {
            'M ': 'Modified',
            'A ': 'Added',
            'D ': 'Deleted',
            '??': 'Untracked',
            'R ': 'Renamed'
        }
        status = status_map.get(file['status'], file['status'])
        lines.append(f"- {status}: {file['file']}")
    
    return '\n'.join(lines)

def format_config(config):
    """Format configuration information"""
    if not config:
        return "- No configuration details found"
    
    lines = []
    if config.get('framework'):
        lines.append(f"- Framework: {config['framework']}")
    if config.get('env_files'):
        lines.append(f"- Environment files: {', '.join(config['env_files'])}")
    if config.get('entry_point'):
        lines.append(f"- Entry point: {config['entry_point']}")
    
    return '\n'.join(lines) if lines else "- No configuration details found"

def get_project_specific_context(project_name):
    """Get project-specific technical context"""
    contexts = {
        'boardlens-frontend': """- Next.js 14 with App Router
- TypeScript for type safety
- RTK Query for API state management
- Tailwind CSS for styling
- PDF viewer integration
- Real-time updates via SSE""",
        
        'boardlens-backend': """- Express 5 with ES modules
- MongoDB with Mongoose ODM
- JWT authentication with httpOnly cookies
- Agenda for job processing
- Multi-provider AI integration (OpenAI, Anthropic, etc.)
- S3 for document storage""",
        
        'boardlens-python-api': """- FastAPI for high-performance API
- Async/await throughout
- LangChain for AI orchestration
- Multiple AI model support
- Custom prompt engineering
- Market signals integration""",
        
        'boardlens-rag': """- LlamaIndex for document processing
- Pinecone for vector storage
- Azure Blob Storage integration
- Streaming responses
- Job tracking with Redis"""
    }
    
    return contexts.get(project_name, "- No specific context available")

def get_integration_points(project_name):
    """Get project integration points"""
    integrations = {
        'boardlens-frontend': """- Backend API: http://localhost:3001
- Python API: http://localhost:5000 (via backend proxy)
- Authentication: JWT cookies from backend
- File uploads: Direct to S3 via presigned URLs""",
        
        'boardlens-backend': """- Database: MongoDB (mongoose)
- Python API: Internal HTTP calls to port 5000
- Job Queue: Agenda with MongoDB
- Cache: Redis
- File Storage: AWS S3""",
        
        'boardlens-python-api': """- Called by: Backend API
- Database: Direct MongoDB access
- AI Providers: OpenAI, Anthropic, Cohere
- Vector DB: Pinecone
- Authentication: JWT validation""",
        
        'boardlens-rag': """- Storage: Azure Blob Storage
- Vector DB: Pinecone
- Job Tracking: Redis
- Document Processing: LlamaCloud
- API: RESTful endpoints"""
    }
    
    return integrations.get(project_name, "- No specific integrations documented")

def store_project_memory(project_name, memory_content):
    """Store the project memory"""
    memory_mgr = ProjectMemoryManager()
    project_path = memory_mgr.get_project_memory_path(project_name)
    project_path.mkdir(exist_ok=True)
    
    # Save as latest
    latest_file = project_path / "latest.md"
    latest_file.write_text(memory_content)
    
    # Save timestamped copy
    timestamp_file = project_path / f"memory_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
    timestamp_file.write_text(memory_content)
    
    # Clean old files (keep last 20)
    old_files = sorted(project_path.glob("memory_*.md"))
    if len(old_files) > 20:
        for old_file in old_files[:-20]:
            old_file.unlink()
    
    print(f"[Project Memory] Saved memory for {project_name}")

def main():
    """Main hook execution"""
    try:
        # Get current directory
        cwd = os.getcwd()
        
        # Get project context
        context = get_project_context(cwd)
        
        if not context:
            print("[Project Memory] Not in a BoardLens project directory")
            return
        
        # Load previous memory
        memory_mgr = ProjectMemoryManager()
        previous_memory = memory_mgr.load_existing_memory(context['project_name'])
        
        # Create new memory
        memory_content = create_project_memory(context, previous_memory)
        
        # Store memory
        store_project_memory(context['project_name'], memory_content)
        
        print(f"[Project Memory] Successfully updated memory for {context['project_name']}")
        
    except Exception as e:
        print(f"[Project Memory] Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()