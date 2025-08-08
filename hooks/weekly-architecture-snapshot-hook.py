#!/usr/bin/env python3
"""
Weekly Architecture Snapshot Hook for Claude Code
Captures high-level architecture state for long-term consistency
"""

import json
import sys
import os
import subprocess
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict

class ArchitectureSnapshotBuilder:
    """Builds comprehensive architecture snapshots"""
    
    def __init__(self):
        self.snapshot_base = Path.home() / ".claude" / "architecture-snapshots"
        self.snapshot_base.mkdir(exist_ok=True)
        self.workspace_path = Path.home() / "Projects" / "boardlens"
        
    def should_create_snapshot(self):
        """Check if it's time for a new snapshot"""
        latest = self.get_latest_snapshot_date()
        
        if not latest:
            return True
        
        # Create snapshot if more than 7 days old
        days_old = (datetime.now() - latest).days
        return days_old >= 7
    
    def get_latest_snapshot_date(self):
        """Get date of most recent snapshot"""
        snapshots = list(self.snapshot_base.glob("snapshot_*.json"))
        
        if not snapshots:
            return None
        
        latest = max(snapshots, key=lambda p: p.stat().st_mtime)
        
        try:
            # Extract date from filename
            date_str = latest.stem.split('_')[1]
            return datetime.strptime(date_str, '%Y%m%d')
        except:
            return None
    
    def create_snapshot(self):
        """Create comprehensive architecture snapshot"""
        print("[Architecture Snapshot] Creating weekly snapshot...")
        
        snapshot = {
            'timestamp': datetime.now().isoformat(),
            'version': '1.0',
            'projects': {},
            'shared_infrastructure': {},
            'api_contracts': {},
            'database_schemas': {},
            'configuration': {},
            'dependencies': {},
            'architecture_decisions': []
        }
        
        # Analyze each project
        for project in ['boardlens-frontend', 'boardlens-backend', 'boardlens-python-api', 'boardlens-rag']:
            project_path = self.workspace_path / project
            if project_path.exists():
                snapshot['projects'][project] = self.analyze_project(project_path, project)
        
        # Capture shared infrastructure
        snapshot['shared_infrastructure'] = self.analyze_shared_infrastructure()
        
        # Capture API contracts
        snapshot['api_contracts'] = self.analyze_api_contracts()
        
        # Capture database schemas
        snapshot['database_schemas'] = self.analyze_database_schemas()
        
        # Capture key configurations
        snapshot['configuration'] = self.analyze_configurations()
        
        # Capture dependency versions
        snapshot['dependencies'] = self.analyze_dependencies()
        
        # Add architecture decisions/notes
        snapshot['architecture_decisions'] = self.get_architecture_decisions()
        
        return snapshot
    
    def analyze_project(self, project_path, project_name):
        """Analyze individual project architecture"""
        analysis = {
            'structure': {},
            'technology': {},
            'size_metrics': {},
            'key_files': [],
            'recent_activity': {}
        }
        
        # Project structure
        analysis['structure'] = self.analyze_project_structure(project_path)
        
        # Technology stack
        analysis['technology'] = self.detect_technology_stack(project_path, project_name)
        
        # Size metrics
        analysis['size_metrics'] = self.calculate_size_metrics(project_path)
        
        # Key files
        analysis['key_files'] = self.identify_key_files(project_path, project_name)
        
        # Recent activity summary
        analysis['recent_activity'] = self.get_recent_activity_summary(project_path)
        
        return analysis
    
    def analyze_project_structure(self, project_path):
        """Analyze directory structure"""
        structure = {
            'directories': [],
            'depth': 0,
            'organization': 'unknown'
        }
        
        # Get top-level directories
        dirs = []
        for item in project_path.iterdir():
            if item.is_dir() and not item.name.startswith('.') and item.name not in ['node_modules', '__pycache__']:
                dirs.append(item.name)
        
        structure['directories'] = sorted(dirs)[:20]  # Top 20
        
        # Detect organization pattern
        if 'src' in dirs:
            structure['organization'] = 'src-based'
        elif 'app' in dirs:
            structure['organization'] = 'app-based'
        elif 'lib' in dirs and 'bin' in dirs:
            structure['organization'] = 'lib-bin-based'
        
        return structure
    
    def detect_technology_stack(self, project_path, project_name):
        """Detect technology stack"""
        tech = {
            'language': None,
            'framework': None,
            'runtime': None,
            'build_tools': [],
            'testing': []
        }
        
        # Check package.json for Node projects
        package_json = project_path / 'package.json'
        if package_json.exists():
            try:
                data = json.loads(package_json.read_text())
                deps = {**data.get('dependencies', {}), **data.get('devDependencies', {})}
                
                tech['language'] = 'JavaScript/TypeScript'
                tech['runtime'] = f"Node.js {data.get('engines', {}).get('node', 'latest')}"
                
                # Detect framework
                if 'next' in deps:
                    tech['framework'] = f"Next.js {deps['next']}"
                elif 'express' in deps:
                    tech['framework'] = f"Express {deps['express']}"
                elif 'react' in deps:
                    tech['framework'] = f"React {deps['react']}"
                
                # Build tools
                if 'webpack' in deps:
                    tech['build_tools'].append('Webpack')
                if 'vite' in deps:
                    tech['build_tools'].append('Vite')
                if 'typescript' in deps:
                    tech['build_tools'].append('TypeScript')
                
                # Testing
                if 'jest' in deps:
                    tech['testing'].append('Jest')
                if 'mocha' in deps:
                    tech['testing'].append('Mocha')
                if 'playwright' in deps:
                    tech['testing'].append('Playwright')
                    
            except:
                pass
        
        # Check for Python projects
        requirements = project_path / 'requirements.txt'
        pyproject = project_path / 'pyproject.toml'
        
        if requirements.exists() or pyproject.exists():
            tech['language'] = 'Python'
            tech['runtime'] = 'Python 3.11+'
            
            # Detect framework
            if project_name == 'boardlens-python-api':
                tech['framework'] = 'FastAPI'
            elif project_name == 'boardlens-rag':
                tech['framework'] = 'FastAPI/LlamaIndex'
        
        return tech
    
    def calculate_size_metrics(self, project_path):
        """Calculate project size metrics"""
        metrics = {
            'total_files': 0,
            'total_lines': 0,
            'file_types': defaultdict(int),
            'largest_files': []
        }
        
        try:
            # Count files and lines
            for ext in ['*.py', '*.js', '*.jsx', '*.ts', '*.tsx']:
                files = list(project_path.rglob(ext))
                
                for file in files:
                    if 'node_modules' not in str(file) and '__pycache__' not in str(file):
                        metrics['total_files'] += 1
                        metrics['file_types'][file.suffix] += 1
                        
                        try:
                            lines = len(file.read_text().splitlines())
                            metrics['total_lines'] += lines
                            
                            if lines > 500:
                                metrics['largest_files'].append({
                                    'path': str(file.relative_to(project_path)),
                                    'lines': lines
                                })
                        except:
                            pass
            
            # Sort largest files
            metrics['largest_files'] = sorted(
                metrics['largest_files'], 
                key=lambda x: x['lines'], 
                reverse=True
            )[:10]
            
        except:
            pass
        
        return dict(metrics)
    
    def identify_key_files(self, project_path, project_name):
        """Identify architecturally significant files"""
        key_files = []
        
        # Common key files
        important_files = {
            'boardlens-frontend': [
                'next.config.ts', 'next.config.js',
                'src/app/layout.tsx', 'src/app/page.tsx',
                'src/RTK/baseQuery.js',
                'src/components/AuthGuard.jsx'
            ],
            'boardlens-backend': [
                'src/app.js', 'src/config/index.js',
                'src/routes/index.js',
                'src/middleware/authMiddleware.js',
                'src/config/database.js'
            ],
            'boardlens-python-api': [
                'main.py', 'settings.py',
                'boardlens_prompts/engine.py',
                'validation_models/executive_debrief_validation.py'
            ],
            'boardlens-rag': [
                'app/main.py', 'services/config.py',
                'services/llama_cloud.py',
                'services/query_processing_service.py'
            ]
        }
        
        for file_path in important_files.get(project_name, []):
            full_path = project_path / file_path
            if full_path.exists():
                key_files.append({
                    'path': file_path,
                    'exists': True,
                    'size': full_path.stat().st_size,
                    'modified': datetime.fromtimestamp(full_path.stat().st_mtime).isoformat()
                })
        
        return key_files
    
    def get_recent_activity_summary(self, project_path):
        """Get summary of recent project activity"""
        activity = {
            'last_commit': None,
            'commit_count_7d': 0,
            'active_branch': None,
            'uncommitted_changes': False
        }
        
        try:
            # Get last commit
            last_commit = subprocess.check_output(
                ['git', 'log', '-1', '--pretty=format:%h|%s|%ar'],
                cwd=project_path, stderr=subprocess.DEVNULL
            ).decode().strip()
            
            if last_commit:
                parts = last_commit.split('|')
                activity['last_commit'] = {
                    'hash': parts[0],
                    'message': parts[1] if len(parts) > 1 else '',
                    'time': parts[2] if len(parts) > 2 else ''
                }
            
            # Count commits in last 7 days
            commits_7d = subprocess.check_output(
                ['git', 'rev-list', '--count', '--since="7 days ago"', 'HEAD'],
                cwd=project_path, stderr=subprocess.DEVNULL
            ).decode().strip()
            
            activity['commit_count_7d'] = int(commits_7d) if commits_7d else 0
            
            # Get current branch
            branch = subprocess.check_output(
                ['git', 'branch', '--show-current'],
                cwd=project_path, stderr=subprocess.DEVNULL
            ).decode().strip()
            
            activity['active_branch'] = branch
            
            # Check for uncommitted changes
            status = subprocess.check_output(
                ['git', 'status', '--porcelain'],
                cwd=project_path, stderr=subprocess.DEVNULL
            ).decode().strip()
            
            activity['uncommitted_changes'] = bool(status)
            
        except:
            pass
        
        return activity
    
    def analyze_shared_infrastructure(self):
        """Analyze shared infrastructure components"""
        infra = {
            'databases': self.detect_databases(),
            'caching': self.detect_caching(),
            'storage': self.detect_storage(),
            'queues': self.detect_queues(),
            'external_services': self.detect_external_services()
        }
        
        return infra
    
    def detect_databases(self):
        """Detect database usage"""
        dbs = {}
        
        # MongoDB
        if self.check_service_usage(['mongoose', 'mongodb', 'MongoClient']):
            dbs['mongodb'] = {
                'primary': True,
                'used_by': self.find_projects_using(['mongoose', 'mongodb'])
            }
        
        # PostgreSQL
        if self.check_service_usage(['pg', 'postgres', 'psycopg']):
            dbs['postgresql'] = {
                'primary': False,
                'used_by': self.find_projects_using(['pg', 'postgres'])
            }
        
        return dbs
    
    def detect_caching(self):
        """Detect caching solutions"""
        cache = {}
        
        if self.check_service_usage(['redis', 'ioredis', 'aioredis']):
            cache['redis'] = {
                'used_by': self.find_projects_using(['redis', 'ioredis'])
            }
        
        return cache
    
    def detect_storage(self):
        """Detect storage solutions"""
        storage = {}
        
        if self.check_service_usage(['aws-sdk', 'boto3', 's3']):
            storage['s3'] = {
                'provider': 'AWS',
                'used_by': self.find_projects_using(['aws-sdk', 'boto3'])
            }
        
        if self.check_service_usage(['@azure/storage-blob']):
            storage['azure_blob'] = {
                'provider': 'Azure',
                'used_by': self.find_projects_using(['@azure/storage-blob'])
            }
        
        return storage
    
    def detect_queues(self):
        """Detect queue/job systems"""
        queues = {}
        
        if self.check_service_usage(['agenda', 'agendash']):
            queues['agenda'] = {
                'type': 'MongoDB-based',
                'used_by': self.find_projects_using(['agenda'])
            }
        
        if self.check_service_usage(['celery']):
            queues['celery'] = {
                'type': 'Python-based',
                'used_by': self.find_projects_using(['celery'])
            }
        
        return queues
    
    def detect_external_services(self):
        """Detect external service integrations"""
        services = {}
        
        # AI Services
        ai_services = {
            'openai': ['openai', 'ChatOpenAI'],
            'anthropic': ['anthropic', 'Claude'],
            'cohere': ['cohere'],
            'pinecone': ['pinecone', 'Pinecone']
        }
        
        for service, indicators in ai_services.items():
            if self.check_service_usage(indicators):
                services[service] = {
                    'type': 'AI',
                    'used_by': self.find_projects_using(indicators)
                }
        
        # Payment
        if self.check_service_usage(['stripe']):
            services['stripe'] = {
                'type': 'Payment',
                'used_by': self.find_projects_using(['stripe'])
            }
        
        # Email
        if self.check_service_usage(['mailersend', '@mailersend']):
            services['mailersend'] = {
                'type': 'Email',
                'used_by': self.find_projects_using(['mailersend'])
            }
        
        return services
    
    def check_service_usage(self, indicators):
        """Check if any BoardLens project uses these services"""
        for project in ['boardlens-frontend', 'boardlens-backend', 'boardlens-python-api', 'boardlens-rag']:
            project_path = self.workspace_path / project
            if project_path.exists():
                # Check package files
                for file_name in ['package.json', 'requirements.txt', 'pyproject.toml']:
                    file_path = project_path / file_name
                    if file_path.exists():
                        try:
                            content = file_path.read_text().lower()
                            for indicator in indicators:
                                if indicator.lower() in content:
                                    return True
                        except:
                            pass
        return False
    
    def find_projects_using(self, indicators):
        """Find which projects use these indicators"""
        projects = []
        
        for project in ['boardlens-frontend', 'boardlens-backend', 'boardlens-python-api', 'boardlens-rag']:
            project_path = self.workspace_path / project
            if project_path.exists():
                for file_name in ['package.json', 'requirements.txt', 'pyproject.toml']:
                    file_path = project_path / file_name
                    if file_path.exists():
                        try:
                            content = file_path.read_text().lower()
                            for indicator in indicators:
                                if indicator.lower() in content:
                                    projects.append(project)
                                    break
                        except:
                            pass
        
        return list(set(projects))
    
    def analyze_api_contracts(self):
        """Analyze API contracts between services"""
        contracts = {}
        
        # Frontend -> Backend
        contracts['frontend_backend'] = {
            'base_url': 'http://localhost:3001',
            'auth_method': 'JWT in httpOnly cookies',
            'key_endpoints': [
                'POST /api/auth/login',
                'POST /api/auth/logout',
                'GET /api/user/profile',
                'GET /api/collections',
                'POST /api/documents/upload'
            ]
        }
        
        # Backend -> Python API
        contracts['backend_python'] = {
            'base_url': 'http://localhost:5000',
            'auth_method': 'JWT token validation',
            'key_endpoints': [
                'POST /ai/report',
                'POST /ai/analyze',
                'POST /ai/market-signals'
            ]
        }
        
        # Backend -> RAG
        contracts['backend_rag'] = {
            'base_url': 'http://localhost:8000',
            'auth_method': 'API key',
            'key_endpoints': [
                'POST /upload',
                'POST /query',
                'DELETE /delete/{file_id}'
            ]
        }
        
        return contracts
    
    def analyze_database_schemas(self):
        """Analyze database schemas"""
        schemas = {
            'mongodb_collections': self.get_mongodb_schemas(),
            'vector_indexes': self.get_vector_schemas()
        }
        
        return schemas
    
    def get_mongodb_schemas(self):
        """Get MongoDB collection schemas"""
        # Based on models in backend
        return {
            'users': {
                'fields': ['email', 'name', 'password', 'role', 'subscription'],
                'indexes': ['email']
            },
            'documents': {
                'fields': ['title', 'userId', 'collectionId', 's3Key', 'metadata'],
                'indexes': ['userId', 'collectionId']
            },
            'collections': {
                'fields': ['name', 'userId', 'documents', 'settings'],
                'indexes': ['userId']
            },
            'reports': {
                'fields': ['documentId', 'userId', 'type', 'content', 'metadata'],
                'indexes': ['documentId', 'userId']
            }
        }
    
    def get_vector_schemas(self):
        """Get vector database schemas"""
        return {
            'pinecone': {
                'indexes': ['boardlens-documents', 'boardlens-rag'],
                'dimensions': 1536,
                'metric': 'cosine'
            }
        }
    
    def analyze_configurations(self):
        """Analyze key configuration patterns"""
        config = {
            'environment_variables': self.get_common_env_vars(),
            'ports': self.get_service_ports(),
            'api_keys_required': self.get_required_api_keys()
        }
        
        return config
    
    def get_common_env_vars(self):
        """Get common environment variables"""
        return {
            'frontend': [
                'NEXT_PUBLIC_API_URL',
                'NEXT_PUBLIC_PYTHON_API_URL',
                'NEXT_PUBLIC_STRIPE_PUBLIC_KEY'
            ],
            'backend': [
                'MONGODB_URI',
                'JWT_SECRET',
                'AWS_ACCESS_KEY_ID',
                'STRIPE_SECRET_KEY',
                'PYTHON_API_URL'
            ],
            'python_api': [
                'OPENAI_API_KEY',
                'ANTHROPIC_API_KEY',
                'MONGODB_URI',
                'PINECONE_API_KEY'
            ],
            'rag': [
                'AZURE_STORAGE_CONNECTION_STRING',
                'PINECONE_API_KEY',
                'OPENAI_API_KEY',
                'REDIS_URL'
            ]
        }
    
    def get_service_ports(self):
        """Get service port mappings"""
        return {
            'boardlens-frontend': 3000,
            'boardlens-backend': 3001,
            'boardlens-python-api': 5000,
            'boardlens-rag': 8000,
            'mongodb': 27017,
            'redis': 6379
        }
    
    def get_required_api_keys(self):
        """Get required API keys"""
        return [
            'OPENAI_API_KEY',
            'ANTHROPIC_API_KEY',
            'COHERE_API_KEY',
            'PINECONE_API_KEY',
            'STRIPE_SECRET_KEY',
            'MAILERSEND_API_KEY',
            'AWS_ACCESS_KEY_ID'
        ]
    
    def analyze_dependencies(self):
        """Analyze dependency versions across projects"""
        deps = {}
        
        for project in ['boardlens-frontend', 'boardlens-backend', 'boardlens-python-api', 'boardlens-rag']:
            project_path = self.workspace_path / project
            deps[project] = self.get_project_dependencies(project_path)
        
        return deps
    
    def get_project_dependencies(self, project_path):
        """Get key dependencies for a project"""
        deps = {
            'runtime': None,
            'key_packages': {}
        }
        
        # Node.js projects
        package_json = project_path / 'package.json'
        if package_json.exists():
            try:
                data = json.loads(package_json.read_text())
                
                # Runtime
                if 'engines' in data:
                    deps['runtime'] = data['engines']
                
                # Key packages
                important_packages = [
                    'next', 'react', 'express', 'mongoose',
                    'typescript', '@types/node', 'tailwindcss',
                    'agenda', 'stripe', 'aws-sdk'
                ]
                
                all_deps = {**data.get('dependencies', {}), **data.get('devDependencies', {})}
                
                for pkg in important_packages:
                    if pkg in all_deps:
                        deps['key_packages'][pkg] = all_deps[pkg]
                        
            except:
                pass
        
        # Python projects
        requirements = project_path / 'requirements.txt'
        if requirements.exists():
            try:
                lines = requirements.read_text().splitlines()
                
                deps['runtime'] = 'Python 3.11+'
                
                important_packages = [
                    'fastapi', 'pydantic', 'openai', 'anthropic',
                    'langchain', 'llama-index', 'pinecone-client',
                    'motor', 'redis', 'celery'
                ]
                
                for line in lines:
                    for pkg in important_packages:
                        if line.startswith(pkg):
                            deps['key_packages'][pkg] = line.split('==')[1] if '==' in line else 'latest'
                            
            except:
                pass
        
        return deps
    
    def get_architecture_decisions(self):
        """Get key architecture decisions"""
        return [
            {
                'decision': 'Microservices Architecture',
                'rationale': 'Separation of concerns between frontend, API, and AI processing',
                'components': ['Frontend (Next.js)', 'Backend (Express)', 'Python API (FastAPI)', 'RAG System']
            },
            {
                'decision': 'JWT Authentication with httpOnly Cookies',
                'rationale': 'Security best practice to prevent XSS attacks',
                'implementation': 'Backend issues tokens, all services validate'
            },
            {
                'decision': 'MongoDB as Primary Database',
                'rationale': 'Flexible schema for document storage and metadata',
                'usage': 'User data, documents, collections, reports'
            },
            {
                'decision': 'Pinecone for Vector Search',
                'rationale': 'Managed vector database for RAG implementation',
                'usage': 'Document embeddings and semantic search'
            },
            {
                'decision': 'Multi-Provider AI Strategy',
                'rationale': 'Flexibility and redundancy in AI providers',
                'providers': ['OpenAI', 'Anthropic', 'Cohere', 'Google AI']
            }
        ]
    
    def save_snapshot(self, snapshot):
        """Save the architecture snapshot"""
        timestamp = datetime.now().strftime('%Y%m%d')
        
        # Save JSON snapshot
        snapshot_file = self.snapshot_base / f"snapshot_{timestamp}.json"
        snapshot_file.write_text(json.dumps(snapshot, indent=2))
        
        # Create human-readable summary
        summary = self.create_snapshot_summary(snapshot)
        summary_file = self.snapshot_base / f"summary_{timestamp}.md"
        summary_file.write_text(summary)
        
        # Update latest symlink
        latest_link = self.snapshot_base / "latest_snapshot.json"
        if latest_link.exists():
            latest_link.unlink()
        
        try:
            latest_link.symlink_to(snapshot_file)
        except:
            # Copy if symlink fails
            latest_link.write_text(snapshot_file.read_text())
        
        print(f"[Architecture Snapshot] Saved snapshot to {snapshot_file}")
        print(f"[Architecture Snapshot] Summary at {summary_file}")
    
    def create_snapshot_summary(self, snapshot):
        """Create human-readable summary"""
        summary = f"""# BoardLens Architecture Snapshot
Date: {snapshot['timestamp'][:10]}

## Project Overview
"""
        
        for project, data in snapshot['projects'].items():
            tech = data['technology']
            metrics = data['size_metrics']
            activity = data['recent_activity']
            
            summary += f"\n### {project}\n"
            summary += f"- **Technology**: {tech.get('framework', 'Unknown')} ({tech.get('language', 'Unknown')})\n"
            summary += f"- **Size**: {metrics.get('total_files', 0)} files, {metrics.get('total_lines', 0)} lines\n"
            summary += f"- **Activity**: {activity.get('commit_count_7d', 0)} commits this week\n"
            summary += f"- **Branch**: {activity.get('active_branch', 'unknown')}\n"
        
        summary += "\n## Shared Infrastructure\n"
        
        for category, services in snapshot['shared_infrastructure'].items():
            if services:
                summary += f"\n### {category.title()}\n"
                for service, details in services.items():
                    summary += f"- **{service}**: Used by {', '.join(details.get('used_by', []))}\n"
        
        summary += "\n## Key Dependencies\n"
        
        for project, deps in snapshot['dependencies'].items():
            if deps.get('key_packages'):
                summary += f"\n### {project}\n"
                for pkg, version in list(deps['key_packages'].items())[:5]:
                    summary += f"- {pkg}: {version}\n"
        
        return summary

def main():
    """Main hook execution"""
    try:
        builder = ArchitectureSnapshotBuilder()
        
        # Check if we should create a snapshot
        if not builder.should_create_snapshot() and not os.environ.get('FORCE_SNAPSHOT'):
            print("[Architecture Snapshot] Not time for snapshot yet (less than 7 days)")
            return
        
        # Create snapshot
        snapshot = builder.create_snapshot()
        
        # Save snapshot
        builder.save_snapshot(snapshot)
        
        # Print summary stats
        total_files = sum(p['size_metrics']['total_files'] for p in snapshot['projects'].values())
        total_lines = sum(p['size_metrics']['total_lines'] for p in snapshot['projects'].values())
        
        print(f"[Architecture Snapshot] Complete:")
        print(f"  - Projects: {len(snapshot['projects'])}")
        print(f"  - Total files: {total_files}")
        print(f"  - Total lines: {total_lines}")
        print(f"  - Shared services: {len([s for cat in snapshot['shared_infrastructure'].values() for s in cat])}")
        
    except Exception as e:
        print(f"[Architecture Snapshot] Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()