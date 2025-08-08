#!/usr/bin/env python3
"""
Smart Context Loader Hook for Claude Code
Intelligently loads relevant context based on current task and location
"""

import json
import sys
import os
import re
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict
import subprocess

class SmartContextLoader:
    """Intelligently loads relevant context for Claude sessions"""
    
    def __init__(self):
        self.claude_base = Path.home() / ".claude"
        self.memory_base = self.claude_base / "project-memories"
        self.graph_path = self.claude_base / "dependency-graphs"
        self.session_path = self.claude_base / "session-memories"
        self.context_output = self.claude_base / "current-context.md"
        
        # Context size limits (in characters)
        self.MAX_CONTEXT = 15000  # Total max context
        self.PROJECT_CONTEXT_LIMIT = 5000
        self.DEPENDENCY_CONTEXT_LIMIT = 3000
        self.SESSION_CONTEXT_LIMIT = 3000
        
    def load_context(self, cwd, task_hints=None):
        """Load smart context based on current location and task"""
        project = self.detect_project(cwd)
        
        if not project:
            return self.load_general_context()
        
        # Load different context types
        project_context = self.load_project_context(project)
        dependency_context = self.load_dependency_context(project)
        recent_session_context = self.load_recent_session_context(project)
        related_projects_context = self.load_related_projects_context(project)
        
        # Analyze task to prioritize context
        task_analysis = self.analyze_task(task_hints) if task_hints else {}
        
        # Build smart context
        context = self.build_smart_context(
            project,
            project_context,
            dependency_context,
            recent_session_context,
            related_projects_context,
            task_analysis
        )
        
        return context
    
    def detect_project(self, cwd):
        """Detect current BoardLens project"""
        path_parts = Path(cwd).parts
        
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
    
    def analyze_task(self, task_hints):
        """Analyze task hints to determine what context is most relevant"""
        analysis = {
            'needs_api_info': False,
            'needs_dependency_info': False,
            'needs_database_info': False,
            'needs_frontend_info': False,
            'needs_backend_info': False,
            'needs_ai_info': False,
            'keywords': []
        }
        
        if not task_hints:
            return analysis
        
        # Convert to string if needed
        hints = str(task_hints).lower()
        
        # Check for specific needs
        api_keywords = ['api', 'endpoint', 'route', 'rest', 'fetch', 'request']
        if any(kw in hints for kw in api_keywords):
            analysis['needs_api_info'] = True
            
        dep_keywords = ['dependency', 'import', 'require', 'package', 'module']
        if any(kw in hints for kw in dep_keywords):
            analysis['needs_dependency_info'] = True
            
        db_keywords = ['database', 'mongodb', 'schema', 'model', 'collection']
        if any(kw in hints for kw in db_keywords):
            analysis['needs_database_info'] = True
            
        frontend_keywords = ['react', 'next', 'component', 'ui', 'frontend', 'client']
        if any(kw in hints for kw in frontend_keywords):
            analysis['needs_frontend_info'] = True
            
        backend_keywords = ['express', 'node', 'server', 'backend', 'middleware']
        if any(kw in hints for kw in backend_keywords):
            analysis['needs_backend_info'] = True
            
        ai_keywords = ['ai', 'llm', 'prompt', 'embedding', 'vector', 'rag']
        if any(kw in hints for kw in ai_keywords):
            analysis['needs_ai_info'] = True
        
        # Extract key terms
        important_terms = re.findall(r'\b[A-Z][a-zA-Z]+\b', task_hints)  # Capitalized words
        analysis['keywords'] = important_terms[:5]
        
        return analysis
    
    def load_project_context(self, project):
        """Load project-specific memory"""
        memory_file = self.memory_base / project / "latest.md"
        
        if memory_file.exists():
            try:
                content = memory_file.read_text()
                # Truncate if needed
                if len(content) > self.PROJECT_CONTEXT_LIMIT:
                    # Keep most important sections
                    sections = self.extract_key_sections(content, [
                        "## Active Tasks and TODOs",
                        "## Uncommitted Changes",
                        "## Recent Activity",
                        "## Configuration"
                    ])
                    return self.truncate_content(sections, self.PROJECT_CONTEXT_LIMIT)
                return content
            except:
                return ""
        return ""
    
    def load_dependency_context(self, project):
        """Load dependency graph context"""
        graph_file = self.graph_path / "boardlens-dependencies.json"
        
        if graph_file.exists():
            try:
                graph = json.loads(graph_file.read_text())
                
                # Extract relevant dependency info
                context = f"## {project} Dependencies\n\n"
                
                # API calls this project makes
                api_calls = graph['dependencies']['api_calls'].get(project, [])
                if api_calls:
                    context += "### Outgoing API Calls\n"
                    for call in api_calls[:10]:
                        context += f"- {call.get('endpoint', call)}\n"
                    context += "\n"
                
                # Data flows
                flows = graph['dependencies']['data_flows'].get(project, {})
                if flows:
                    context += "### Data Flows\n"
                    if flows.get('calls'):
                        context += f"- Calls: {', '.join(flows['calls'])}\n"
                    if flows.get('called_by'):
                        context += f"- Called by: {', '.join(flows['called_by'])}\n"
                    context += "\n"
                
                # Shared resources
                context += "### Shared Resources\n"
                for resource_type, resources in graph['shared_resources'].items():
                    for resource, services in resources.items():
                        if project in services:
                            context += f"- Uses {resource}\n"
                
                return self.truncate_content(context, self.DEPENDENCY_CONTEXT_LIMIT)
            except:
                return ""
        return ""
    
    def load_recent_session_context(self, project):
        """Load context from recent sessions"""
        sessions = []
        
        # Get recent session files
        if self.session_path.exists():
            session_files = sorted(self.session_path.glob("session_*.md"), reverse=True)
            
            for session_file in session_files[:5]:  # Last 5 sessions
                try:
                    content = session_file.read_text()
                    # Check if this session involved the current project
                    if project in content:
                        # Extract relevant parts
                        sections = self.extract_key_sections(content, [
                            "## Technical Findings",
                            "## Active Development Areas",
                            "## Next Action Ready"
                        ])
                        sessions.append({
                            'timestamp': session_file.stem.split('_')[1],
                            'content': sections
                        })
                except:
                    pass
        
        # Build context from recent sessions
        if sessions:
            context = "## Recent Session Context\n\n"
            for session in sessions[:2]:  # Most recent 2 sessions
                context += f"### Session {session['timestamp']}\n"
                context += session['content'] + "\n"
            
            return self.truncate_content(context, self.SESSION_CONTEXT_LIMIT)
        
        return ""
    
    def load_related_projects_context(self, current_project):
        """Load context from related projects"""
        # Define project relationships
        relationships = {
            'boardlens-frontend': ['boardlens-backend', 'boardlens-python-api'],
            'boardlens-backend': ['boardlens-frontend', 'boardlens-python-api', 'boardlens-rag'],
            'boardlens-python-api': ['boardlens-backend'],
            'boardlens-rag': ['boardlens-backend']
        }
        
        related = relationships.get(current_project, [])
        if not related:
            return ""
        
        context = "## Related Projects Context\n\n"
        
        for project in related:
            memory_file = self.memory_base / project / "latest.md"
            if memory_file.exists():
                try:
                    content = memory_file.read_text()
                    # Get just the essential info
                    sections = self.extract_key_sections(content, [
                        "## Integration Points",
                        "## Recent Activity"
                    ])
                    
                    if sections:
                        context += f"### {project}\n"
                        context += self.truncate_content(sections, 1000) + "\n"
                except:
                    pass
        
        return context
    
    def load_general_context(self):
        """Load general BoardLens context when not in a specific project"""
        context = """# BoardLens Platform Context

## Architecture Overview
- **Frontend**: Next.js (port 3000) - User interface
- **Backend**: Express (port 3001) - API server  
- **Python API**: FastAPI (port 5000) - AI processing
- **RAG System**: FastAPI (port 8000) - Document processing

## Key Technologies
- Authentication: JWT with httpOnly cookies
- Database: MongoDB with Mongoose/Motor
- Vector DB: Pinecone
- Storage: AWS S3
- Queue: Agenda/Redis
- AI: OpenAI, Anthropic, Cohere

## Common Tasks
- Frontend: `npm run dev`
- Backend: `npm run dev`
- Python API: `python main.py`
- RAG: `python -m app.main`
"""
        return context
    
    def extract_key_sections(self, content, section_headers):
        """Extract specific sections from markdown content"""
        extracted = ""
        lines = content.split('\n')
        
        current_section = None
        section_content = []
        
        for line in lines:
            # Check if this is a section header we want
            for header in section_headers:
                if line.strip().startswith(header):
                    # Save previous section
                    if current_section and section_content:
                        extracted += f"{current_section}\n"
                        extracted += '\n'.join(section_content[:20]) + "\n\n"  # Limit lines
                    
                    # Start new section
                    current_section = line
                    section_content = []
                    break
            else:
                # Add to current section if we're in one
                if current_section and line.strip():
                    section_content.append(line)
        
        # Don't forget last section
        if current_section and section_content:
            extracted += f"{current_section}\n"
            extracted += '\n'.join(section_content[:20]) + "\n\n"
        
        return extracted
    
    def truncate_content(self, content, limit):
        """Truncate content to limit while keeping it meaningful"""
        if len(content) <= limit:
            return content
        
        # Try to cut at a paragraph boundary
        truncated = content[:limit]
        last_newline = truncated.rfind('\n\n')
        
        if last_newline > limit * 0.8:  # If we have a good break point
            return truncated[:last_newline] + "\n\n[... truncated for context limit]"
        
        # Otherwise just truncate
        return truncated + "\n[... truncated for context limit]"
    
    def build_smart_context(self, project, project_ctx, dep_ctx, session_ctx, related_ctx, task_analysis):
        """Build final smart context based on all inputs"""
        context = f"""# Smart Context for {project}
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Current Project
You are working in: **{project}**

"""
        
        # Add project context
        if project_ctx:
            context += "## Project Memory\n"
            context += project_ctx + "\n\n"
        
        # Add dependency context if relevant
        if dep_ctx and (task_analysis.get('needs_api_info') or task_analysis.get('needs_dependency_info')):
            context += dep_ctx + "\n\n"
        
        # Add recent session context
        if session_ctx:
            context += session_ctx + "\n\n"
        
        # Add related projects if space allows
        if len(context) < self.MAX_CONTEXT * 0.8 and related_ctx:
            context += related_ctx + "\n\n"
        
        # Add task-specific hints
        if task_analysis.get('keywords'):
            context += f"## Task Keywords Detected\n"
            context += f"Keywords: {', '.join(task_analysis['keywords'])}\n\n"
        
        # Add specific guidance based on task analysis
        if task_analysis.get('needs_api_info'):
            context += self.get_api_reference(project)
        
        if task_analysis.get('needs_database_info'):
            context += self.get_database_reference(project)
        
        # Ensure we don't exceed limit
        if len(context) > self.MAX_CONTEXT:
            context = self.truncate_content(context, self.MAX_CONTEXT)
        
        return context
    
    def get_api_reference(self, project):
        """Get quick API reference for project"""
        refs = {
            'boardlens-frontend': """## API Quick Reference
- Backend API: `http://localhost:3001/api`
- Auth endpoints: `/api/auth/login`, `/api/auth/logout`
- Use RTK Query for API calls (see src/RTK/)
""",
            'boardlens-backend': """## API Quick Reference
- Express routes in `src/routes/`
- Python API calls: `http://localhost:5000/ai`
- Auth middleware: `authMiddleware.js`
""",
            'boardlens-python-api': """## API Quick Reference
- FastAPI endpoints in `main.py`
- Auth: Validate JWT from backend
- Key endpoints: `/ai/report`, `/ai/analyze`
""",
            'boardlens-rag': """## API Quick Reference
- Upload: `POST /upload`
- Query: `POST /query`
- Delete: `DELETE /delete/{file_id}`
"""
        }
        
        return refs.get(project, "")
    
    def get_database_reference(self, project):
        """Get quick database reference"""
        if project == 'boardlens-backend':
            return """## Database Quick Reference
- Models in `src/models/`
- MongoDB connection in `config/database.js`
- Key collections: users, documents, collections
"""
        return ""
    
    def save_context(self, context):
        """Save the context for the session"""
        self.context_output.write_text(context)
        
        # Also create a symlink for easy access
        current_link = self.claude_base / "CURRENT_CONTEXT.md"
        if current_link.exists():
            current_link.unlink()
        
        try:
            current_link.symlink_to(self.context_output)
        except:
            # Fall back to copy if symlink fails
            current_link.write_text(context)
        
        return str(self.context_output)

def main():
    """Main hook execution"""
    try:
        # Get current working directory
        cwd = os.getcwd()
        
        # Get task hints from environment or stdin
        task_hints = os.environ.get('CLAUDE_TASK_HINTS', '')
        
        # If no hints in env, try to get from stdin
        if not task_hints and not sys.stdin.isatty():
            try:
                task_hints = sys.stdin.read()
            except:
                pass
        
        print("[Smart Context] Loading intelligent context...")
        
        # Create loader
        loader = SmartContextLoader()
        
        # Load smart context
        context = loader.load_context(cwd, task_hints)
        
        # Save context
        context_file = loader.save_context(context)
        
        print(f"[Smart Context] Context loaded: {len(context)} characters")
        print(f"[Smart Context] Saved to: {context_file}")
        print(f"[Smart Context] Access via: ~/.claude/CURRENT_CONTEXT.md")
        
        # If running interactively, also output context
        if os.environ.get('CLAUDE_OUTPUT_CONTEXT'):
            print("\n" + "="*50 + "\n")
            print(context)
            print("\n" + "="*50 + "\n")
        
    except Exception as e:
        print(f"[Smart Context] Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()