# Contributing to Claude Code Enhanced Configuration

Thank you for your interest in contributing to this project! This guide will help you understand how to effectively contribute to the Claude Code enhanced configuration system.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Contributing Guidelines](#contributing-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Code Style](#code-style)
- [Security Guidelines](#security-guidelines)

## 🚀 Getting Started

### Prerequisites
- Claude Code CLI installed
- Docker (for Neo4j memory system)
- Python 3.8+
- Git
- Basic understanding of shell scripting and JSON configuration

### First-Time Setup
1. Fork this repository
2. Clone your fork locally
3. Run the installation script: `./install.sh`
4. Test your setup: `claude code`

## 🛠️ Development Setup

### Local Development Environment
```bash
# Clone your fork
git clone https://github.com/yourusername/claude-code-enhanced.git
cd claude-code-enhanced

# Install in development mode (creates symlinks)
./scripts/dev-install.sh

# Enable debug mode
export CLAUDE_DEBUG=true
```

### Testing Your Changes
```bash
# Test basic functionality
claude code --debug

# Test specific components
./scripts/test-hooks.sh
./scripts/test-memory.sh
./scripts/test-mcp.sh
```

## 📁 Project Structure

```
├── Core Configuration Files
│   ├── CLAUDE.md              # Behavior instructions
│   ├── settings.json          # MCP configuration
│   ├── memory-config.json     # Memory system config
│   └── hooks.json            # Hook definitions
│
├── Documentation
│   ├── docs/guides/          # Setup and usage guides
│   ├── docs/references/      # API references
│   └── docs/architecture/    # System architecture
│
├── Automation Scripts
│   ├── hooks/                # Hook implementations
│   ├── scripts/              # Utility scripts
│   └── *.sh                  # Main automation scripts
│
├── Custom Features
│   ├── slash-commands/       # Command definitions
│   ├── commands/             # Command implementations
│   └── agents/               # Specialized agents
│
└── Configuration
    ├── templates/            # Configuration templates
    └── examples/             # Example configurations
```

## 🤝 Contributing Guidelines

### Types of Contributions

#### 🐛 Bug Fixes
- Fix issues with existing functionality
- Improve error handling
- Performance improvements

#### ✨ New Features
- New hooks or automation
- Additional slash commands
- Enhanced MCP integrations
- Memory system improvements

#### 📚 Documentation
- Improve setup guides
- Add troubleshooting sections
- Create usage examples
- API documentation

#### 🔧 Infrastructure
- CI/CD improvements
- Testing frameworks
- Development tools

### Before Contributing

1. **Check existing issues** - Avoid duplicate work
2. **Discuss major changes** - Create an issue first for significant features
3. **Test thoroughly** - Ensure your changes don't break existing functionality
4. **Update documentation** - Keep docs in sync with code changes

## 🧪 Testing

### Automated Tests
```bash
# Run all tests
./scripts/run-tests.sh

# Test specific components
./scripts/test-hooks.sh          # Hook system
./scripts/test-memory.sh         # Memory system
./scripts/test-mcp.sh           # MCP integration
./scripts/test-commands.sh      # Slash commands
```

### Manual Testing
```bash
# Test basic functionality
claude code
/remember "Test memory"
/recall "test"

# Test advanced features
/gemini-overview
/context7-docs "react"
```

### Testing Checklist
- [ ] Hook system works correctly
- [ ] Memory system saves and retrieves data
- [ ] MCP servers connect properly
- [ ] Slash commands execute without errors
- [ ] No user-specific paths in shared configuration
- [ ] Security: No hardcoded secrets
- [ ] Documentation is up to date

## 📝 Pull Request Process

### PR Requirements
1. **Clear description** - Explain what and why
2. **Link to issue** - Reference related issues
3. **Test results** - Show testing was performed
4. **Documentation updates** - Update relevant docs
5. **No breaking changes** - Unless explicitly discussed

### PR Template
```markdown
## Description
Brief description of changes

## Related Issue
Fixes #(issue)

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Ran automated tests
- [ ] Manual testing performed
- [ ] No breaking changes

## Documentation
- [ ] Updated relevant documentation
- [ ] Added examples if needed
```

### Review Process
1. Automated checks must pass
2. At least one maintainer review
3. All comments addressed
4. Final approval and merge

## 🎨 Code Style

### Shell Scripts
```bash
#!/bin/bash
# Use strict mode
set -e

# Clear variable naming
CLAUDE_DIR="$HOME/.claude"

# Consistent indentation (2 spaces)
if [ "$condition" ]; then
  echo "Action"
fi

# Comments for complex logic
# This handles the edge case where...
```

### JSON Configuration
```json
{
  "consistent_formatting": true,
  "proper_indentation": "2_spaces",
  "no_trailing_commas": true,
  "descriptive_keys": "use_clear_names"
}
```

### Python Scripts
```python
#!/usr/bin/env python3
"""
Clear docstrings for all modules.
"""

import logging

# Clear variable names
claude_config_path = Path.home() / ".claude"

def descriptive_function_names():
    """Clear docstrings for all functions."""
    pass
```

### Documentation
- Use clear, actionable language
- Include examples for complex concepts
- Keep setup instructions step-by-step
- Use consistent formatting and headings

## 🔒 Security Guidelines

### Critical Security Rules
1. **No hardcoded secrets** - Always use environment variables
2. **No user-specific paths** - Use variables or placeholders
3. **Validate inputs** - Sanitize user inputs in scripts
4. **Minimal permissions** - Request only necessary permissions
5. **Secure defaults** - Choose secure options by default

### Security Checklist
- [ ] No API keys in code or config files
- [ ] No personal information in shared files
- [ ] Input validation for user-provided data
- [ ] Proper file permissions on scripts
- [ ] No execution of unvalidated code

### Reporting Security Issues
- **DO NOT** create public issues for security problems
- Email security concerns to [security@project.com]
- Provide detailed reproduction steps
- Allow time for assessment and fix

## 🚀 Development Workflow

### Feature Development
```bash
# 1. Create feature branch
git checkout -b feature/your-feature-name

# 2. Make changes
# ... develop your feature ...

# 3. Test thoroughly
./scripts/run-tests.sh

# 4. Commit with clear messages
git commit -m "feat: add new slash command for project analysis"

# 5. Push and create PR
git push origin feature/your-feature-name
```

### Commit Message Format
```
type(scope): description

feat: add new feature
fix: resolve bug
docs: update documentation
test: add tests
refactor: improve code structure
```

### Branch Naming
- `feature/feature-name` - New features
- `fix/bug-description` - Bug fixes
- `docs/update-description` - Documentation updates
- `refactor/component-name` - Code refactoring

## 📞 Getting Help

### Resources
- [Setup Guide](./COMPLETE_SETUP_GUIDE.md)
- [Quick Reference](./QUICK_REFERENCE.md)
- [Architecture Overview](./docs/architecture/)

### Contact
- Create an issue for bugs or feature requests
- Join discussions for questions
- Check existing documentation first

### Community Guidelines
- Be respectful and constructive
- Help others learn and contribute
- Share knowledge and best practices
- Follow the project's code of conduct

---

Thank you for contributing to Claude Code Enhanced Configuration! Your contributions help make this tool better for all developers. 🚀