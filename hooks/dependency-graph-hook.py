#!/usr/bin/env python3
"""
Dependency Graph Hook for Claude Code
Tracks and visualizes dependencies between BoardLens projects
"""

import json
import sys
import os
import re
from datetime import datetime
from pathlib import Path
import ast
import subprocess

class DependencyGraphBuilder:
    """Builds and maintains dependency graph for BoardLens projects"""
    
    def __init__(self):
        self.graph_path = Path.home() / ".claude" / "dependency-graphs"
        self.graph_path.mkdir(exist_ok=True)
        self.graph_file = self.graph_path / "boardlens-dependencies.json"
        
        # Known BoardLens services and their details
        self.services = {
            'boardlens-frontend': {
                'type': 'frontend',
                'port': 3000,
                'api_prefix': '',
                'tech': 'Next.js'
            },
            'boardlens-backend': {
                'type': 'backend',
                'port': 3001,
                'api_prefix': '/api',
                'tech': 'Express'
            },
            'boardlens-python-api': {
                'type': 'ai-engine',
                'port': 5000,
                'api_prefix': '/ai',
                'tech': 'FastAPI'
            },
            'boardlens-rag': {
                'type': 'rag-system',
                'port': 8000,
                'api_prefix': '/rag',
                'tech': 'FastAPI'
            }
        }
        
    def load_existing_graph(self):
        """Load existing dependency graph"""
        if self.graph_file.exists():
            try:
                return json.loads(self.graph_file.read_text())
            except:
                return self._create_empty_graph()
        return self._create_empty_graph()
    
    def _create_empty_graph(self):
        """Create empty graph structure"""
        return {
            'last_updated': None,
            'services': self.services,
            'dependencies': {
                'api_calls': {},      # service -> [endpoints it calls]
                'imports': {},        # service -> [modules it imports]
                'shared_types': {},   # service -> [types it shares]
                'data_flows': {},     # service -> [data it exchanges]
                'configs': {}         # service -> [config dependencies]
            },
            'endpoints': {},          # All discovered endpoints by service
            'shared_resources': {     # Resources used by multiple services
                'database': {'mongodb': []},
                'cache': {'redis': []},
                'storage': {'s3': [], 'azure': []},
                'queues': {'agenda': [], 'celery': []},
                'vectors': {'pinecone': []}
            }
        }

def analyze_project_dependencies(project_path, project_name):
    """Analyze dependencies for a specific project"""
    deps = {
        'api_calls': [],
        'imports': [],
        'shared_types': [],
        'data_flows': [],
        'configs': [],
        'endpoints': []
    }
    
    if project_name == 'boardlens-frontend':
        deps.update(analyze_frontend_dependencies(project_path))
    elif project_name == 'boardlens-backend':
        deps.update(analyze_backend_dependencies(project_path))
    elif project_name in ['boardlens-python-api', 'boardlens-rag']:
        deps.update(analyze_python_dependencies(project_path))
    
    return deps

def analyze_frontend_dependencies(project_path):
    """Analyze Next.js frontend dependencies"""
    deps = {
        'api_calls': [],
        'imports': [],
        'endpoints': [],
        'configs': []
    }
    
    # Scan for API calls
    api_patterns = [
        r'fetch\s*\(\s*[\'"`]([^\'"`]+)[\'"`]',
        r'axios\.\w+\s*\(\s*[\'"`]([^\'"`]+)[\'"`]',
        r'api\.\w+\s*\(\s*[\'"`]([^\'"`]+)[\'"`]',
        r'createApi.*endpoints.*query.*[\'"`]([^\'"`]+)[\'"`]'
    ]
    
    # Scan TypeScript/JavaScript files
    for ext in ['*.ts', '*.tsx', '*.js', '*.jsx']:
        for file_path in Path(project_path).rglob(ext):
            if 'node_modules' in str(file_path):
                continue
                
            try:
                content = file_path.read_text()
                
                # Find API calls
                for pattern in api_patterns:
                    matches = re.findall(pattern, content)
                    for match in matches:
                        if match.startswith('/'):
                            deps['api_calls'].append({
                                'endpoint': match,
                                'file': str(file_path.relative_to(project_path)),
                                'service': detect_service_from_endpoint(match)
                            })
                
                # Find environment variables
                env_matches = re.findall(r'process\.env\.(\w+)', content)
                deps['configs'].extend(env_matches)
                
            except:
                pass
    
    # Check for RTK Query API definitions
    rtk_path = project_path / 'src' / 'RTK'
    if rtk_path.exists():
        for file_path in rtk_path.glob('*.js'):
            try:
                content = file_path.read_text()
                # Extract endpoints from RTK Query
                endpoint_matches = re.findall(r'endpoint:\s*[\'"`]([^\'"`]+)[\'"`]', content)
                deps['endpoints'].extend(endpoint_matches)
            except:
                pass
    
    return deps

def analyze_backend_dependencies(project_path):
    """Analyze Express backend dependencies"""
    deps = {
        'api_calls': [],
        'imports': [],
        'endpoints': [],
        'configs': [],
        'database_models': []
    }
    
    # Scan route files
    routes_path = project_path / 'src' / 'routes'
    if routes_path.exists():
        for file_path in routes_path.rglob('*.js'):
            try:
                content = file_path.read_text()
                
                # Find route definitions
                route_patterns = [
                    r'router\.(get|post|put|delete|patch)\s*\(\s*[\'"`]([^\'"`]+)[\'"`]',
                    r'app\.(get|post|put|delete|patch)\s*\(\s*[\'"`]([^\'"`]+)[\'"`]'
                ]
                
                for pattern in route_patterns:
                    matches = re.findall(pattern, content)
                    for method, endpoint in matches:
                        deps['endpoints'].append({
                            'method': method.upper(),
                            'path': endpoint,
                            'file': str(file_path.relative_to(project_path))
                        })
                
                # Find internal API calls (to Python API)
                python_api_patterns = [
                    r'http://localhost:5000([^\'"`\s]+)',
                    r'PYTHON_API_URL.*?([^\'"`\s]+)',
                    r'fetch.*5000([^\'"`\s]+)'
                ]
                
                for pattern in python_api_patterns:
                    matches = re.findall(pattern, content)
                    deps['api_calls'].extend([{'endpoint': m, 'service': 'boardlens-python-api'} for m in matches])
                
            except:
                pass
    
    # Scan models
    models_path = project_path / 'src' / 'models'
    if models_path.exists():
        for file_path in models_path.glob('*.js'):
            try:
                model_name = file_path.stem
                deps['database_models'].append(model_name)
            except:
                pass
    
    return deps

def analyze_python_dependencies(project_path):
    """Analyze Python service dependencies"""
    deps = {
        'api_calls': [],
        'imports': [],
        'endpoints': [],
        'configs': [],
        'external_services': []
    }
    
    # Scan Python files
    for file_path in Path(project_path).rglob('*.py'):
        if '__pycache__' in str(file_path):
            continue
            
        try:
            content = file_path.read_text()
            
            # Find FastAPI route definitions
            route_patterns = [
                r'@app\.(get|post|put|delete|patch)\s*\(\s*[\'"`]([^\'"`]+)[\'"`]',
                r'@router\.(get|post|put|delete|patch)\s*\(\s*[\'"`]([^\'"`]+)[\'"`]'
            ]
            
            for pattern in route_patterns:
                matches = re.findall(pattern, content)
                for method, endpoint in matches:
                    deps['endpoints'].append({
                        'method': method.upper(),
                        'path': endpoint,
                        'file': str(file_path.relative_to(project_path))
                    })
            
            # Find external API calls
            api_patterns = [
                r'requests\.(get|post|put|delete)\s*\(\s*[\'"`]([^\'"`]+)[\'"`]',
                r'httpx\.(get|post|put|delete)\s*\(\s*[\'"`]([^\'"`]+)[\'"`]',
                r'aiohttp.*?(get|post|put|delete)\s*\(\s*[\'"`]([^\'"`]+)[\'"`]'
            ]
            
            for pattern in api_patterns:
                matches = re.findall(pattern, content)
                for method, url in matches:
                    if 'http' in url:
                        deps['api_calls'].append({
                            'url': url,
                            'method': method.upper()
                        })
            
            # Find environment variables
            env_matches = re.findall(r'os\.environ\.get\s*\(\s*[\'"`](\w+)[\'"`]', content)
            deps['configs'].extend(env_matches)
            
            # Find database/service connections
            service_patterns = {
                'mongodb': r'MongoClient|motor\.motor_asyncio',
                'redis': r'redis\.Redis|aioredis',
                'pinecone': r'pinecone\.init|Pinecone',
                's3': r'boto3\.client\s*\(\s*[\'"`]s3[\'"`]',
                'openai': r'openai\.OpenAI|ChatOpenAI',
                'anthropic': r'anthropic\.Anthropic|Claude'
            }
            
            for service, pattern in service_patterns.items():
                if re.search(pattern, content):
                    deps['external_services'].append(service)
            
        except:
            pass
    
    return deps

def detect_service_from_endpoint(endpoint):
    """Detect which service an endpoint belongs to"""
    if endpoint.startswith('/api'):
        return 'boardlens-backend'
    elif endpoint.startswith('/ai'):
        return 'boardlens-python-api'
    elif endpoint.startswith('/rag'):
        return 'boardlens-rag'
    else:
        return 'boardlens-backend'  # Default

def analyze_shared_resources(workspace_path):
    """Analyze shared resources across all services"""
    shared = {
        'database': {'mongodb': []},
        'cache': {'redis': []},
        'storage': {'s3': [], 'azure': []},
        'queues': {'agenda': [], 'celery': []},
        'vectors': {'pinecone': []}
    }
    
    # Scan each project
    for project in ['boardlens-frontend', 'boardlens-backend', 'boardlens-python-api', 'boardlens-rag']:
        project_path = workspace_path / project
        if not project_path.exists():
            continue
        
        # Check for database usage
        if uses_mongodb(project_path):
            shared['database']['mongodb'].append(project)
        
        if uses_redis(project_path):
            shared['cache']['redis'].append(project)
        
        if uses_s3(project_path):
            shared['storage']['s3'].append(project)
        
        if uses_pinecone(project_path):
            shared['vectors']['pinecone'].append(project)
    
    return shared

def uses_mongodb(project_path):
    """Check if project uses MongoDB"""
    indicators = [
        'mongoose', 'mongodb', 'MongoClient', 'motor'
    ]
    
    return check_for_indicators(project_path, indicators)

def uses_redis(project_path):
    """Check if project uses Redis"""
    indicators = [
        'redis', 'ioredis', 'aioredis', 'Redis'
    ]
    
    return check_for_indicators(project_path, indicators)

def uses_s3(project_path):
    """Check if project uses S3"""
    indicators = [
        'aws-sdk', 'boto3', 'S3', 's3Client', 'getS3PresignedUrl'
    ]
    
    return check_for_indicators(project_path, indicators)

def uses_pinecone(project_path):
    """Check if project uses Pinecone"""
    indicators = [
        'pinecone', 'Pinecone', 'pinecone-client'
    ]
    
    return check_for_indicators(project_path, indicators)

def check_for_indicators(project_path, indicators):
    """Check if any indicators are present in the project"""
    # Check package files
    package_files = ['package.json', 'requirements.txt', 'pyproject.toml']
    
    for pkg_file in package_files:
        file_path = project_path / pkg_file
        if file_path.exists():
            try:
                content = file_path.read_text().lower()
                for indicator in indicators:
                    if indicator.lower() in content:
                        return True
            except:
                pass
    
    # Quick scan of a few source files
    extensions = ['*.js', '*.py', '*.ts']
    for ext in extensions:
        for file_path in list(project_path.rglob(ext))[:10]:  # Limit scan
            if 'node_modules' in str(file_path) or '__pycache__' in str(file_path):
                continue
            
            try:
                content = file_path.read_text().lower()
                for indicator in indicators:
                    if indicator.lower() in content:
                        return True
            except:
                pass
    
    return False

def create_dependency_graph(workspace_path):
    """Create comprehensive dependency graph"""
    builder = DependencyGraphBuilder()
    graph = builder.load_existing_graph()
    
    # Update timestamp
    graph['last_updated'] = datetime.now().isoformat()
    
    # Analyze each project
    for project_name in builder.services.keys():
        project_path = workspace_path / project_name
        if project_path.exists():
            print(f"[Dependency Graph] Analyzing {project_name}...")
            
            # Get project dependencies
            deps = analyze_project_dependencies(project_path, project_name)
            
            # Update graph
            graph['dependencies']['api_calls'][project_name] = deps.get('api_calls', [])
            graph['dependencies']['imports'][project_name] = deps.get('imports', [])
            graph['dependencies']['configs'][project_name] = list(set(deps.get('configs', [])))
            graph['endpoints'][project_name] = deps.get('endpoints', [])
    
    # Analyze shared resources
    graph['shared_resources'] = analyze_shared_resources(workspace_path)
    
    # Calculate data flows based on API calls
    graph['dependencies']['data_flows'] = calculate_data_flows(graph)
    
    return graph

def calculate_data_flows(graph):
    """Calculate data flow patterns between services"""
    flows = {}
    
    # Analyze API call patterns
    for service, calls in graph['dependencies']['api_calls'].items():
        if service not in flows:
            flows[service] = {'calls': [], 'called_by': []}
        
        for call in calls:
            target_service = call.get('service')
            if target_service and target_service != service:
                if target_service not in flows[service]['calls']:
                    flows[service]['calls'].append(target_service)
                
                # Add reverse mapping
                if target_service not in flows:
                    flows[target_service] = {'calls': [], 'called_by': []}
                if service not in flows[target_service]['called_by']:
                    flows[target_service]['called_by'].append(service)
    
    return flows

def generate_visualization(graph):
    """Generate a visual representation of the dependency graph"""
    viz = """
# BoardLens Dependency Graph

## Service Architecture
```mermaid
graph TD
    FE[Frontend<br/>Next.js:3000]
    BE[Backend<br/>Express:3001]
    PY[Python API<br/>FastAPI:5000]
    RAG[RAG System<br/>FastAPI:8000]
    
    FE -->|API Calls| BE
    FE -->|Direct Calls| PY
    BE -->|AI Processing| PY
    BE -->|Document Processing| RAG
    
    DB[(MongoDB)]
    CACHE[(Redis)]
    S3[(AWS S3)]
    PINE[(Pinecone)]
    
"""
    
    # Add shared resource connections
    for resource_type, resources in graph['shared_resources'].items():
        for resource, services in resources.items():
            if services:
                if resource == 'mongodb':
                    for service in services:
                        service_abbr = get_service_abbr(service)
                        viz += f"    {service_abbr} --> DB\n"
                elif resource == 'redis':
                    for service in services:
                        service_abbr = get_service_abbr(service)
                        viz += f"    {service_abbr} --> CACHE\n"
                elif resource == 's3':
                    for service in services:
                        service_abbr = get_service_abbr(service)
                        viz += f"    {service_abbr} --> S3\n"
                elif resource == 'pinecone':
                    for service in services:
                        service_abbr = get_service_abbr(service)
                        viz += f"    {service_abbr} --> PINE\n"
    
    viz += "```\n\n"
    
    # Add endpoint summary
    viz += "## API Endpoints by Service\n\n"
    for service, endpoints in graph['endpoints'].items():
        if endpoints:
            viz += f"### {service}\n"
            for ep in endpoints[:10]:  # Limit to 10
                viz += f"- {ep.get('method', 'GET')} {ep.get('path', ep)}\n"
            if len(endpoints) > 10:
                viz += f"- ... and {len(endpoints) - 10} more\n"
            viz += "\n"
    
    # Add data flow summary
    viz += "## Data Flow Summary\n\n"
    for service, flows in graph['dependencies']['data_flows'].items():
        if flows.get('calls') or flows.get('called_by'):
            viz += f"### {service}\n"
            if flows.get('calls'):
                viz += f"- **Calls:** {', '.join(flows['calls'])}\n"
            if flows.get('called_by'):
                viz += f"- **Called by:** {', '.join(flows['called_by'])}\n"
            viz += "\n"
    
    return viz

def get_service_abbr(service_name):
    """Get service abbreviation for visualization"""
    abbrs = {
        'boardlens-frontend': 'FE',
        'boardlens-backend': 'BE',
        'boardlens-python-api': 'PY',
        'boardlens-rag': 'RAG'
    }
    return abbrs.get(service_name, service_name[:2].upper())

def save_dependency_graph(graph, visualization):
    """Save dependency graph and visualization"""
    builder = DependencyGraphBuilder()
    
    # Save JSON graph
    builder.graph_file.write_text(json.dumps(graph, indent=2))
    
    # Save visualization
    viz_file = builder.graph_path / "dependency-visualization.md"
    viz_file.write_text(visualization)
    
    # Save timestamped copy
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    history_file = builder.graph_path / f"graph_{timestamp}.json"
    history_file.write_text(json.dumps(graph, indent=2))
    
    # Clean old history files
    history_files = sorted(builder.graph_path.glob("graph_*.json"))
    if len(history_files) > 10:
        for old_file in history_files[:-10]:
            old_file.unlink()
    
    print(f"[Dependency Graph] Saved graph to {builder.graph_file}")
    print(f"[Dependency Graph] Saved visualization to {viz_file}")

def main():
    """Main hook execution"""
    try:
        # Determine workspace path
        workspace_path = Path.home() / "Projects" / "boardlens"
        
        if not workspace_path.exists():
            print("[Dependency Graph] BoardLens workspace not found")
            return
        
        print("[Dependency Graph] Building dependency graph...")
        
        # Create dependency graph
        graph = create_dependency_graph(workspace_path)
        
        # Generate visualization
        visualization = generate_visualization(graph)
        
        # Save results
        save_dependency_graph(graph, visualization)
        
        # Print summary
        total_endpoints = sum(len(eps) for eps in graph['endpoints'].values())
        total_deps = sum(len(deps) for deps in graph['dependencies']['api_calls'].values())
        
        print(f"[Dependency Graph] Analysis complete:")
        print(f"  - Total endpoints: {total_endpoints}")
        print(f"  - Total dependencies: {total_deps}")
        print(f"  - Shared resources: {len([r for res in graph['shared_resources'].values() for r in res.values() if r])}")
        
    except Exception as e:
        print(f"[Dependency Graph] Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()