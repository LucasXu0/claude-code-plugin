# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code plugin marketplace repository containing plugins that extend Claude Code's capabilities for Flutter/Dart development and plugin authoring.

## Repository Structure

```
claude-code-plugin/
├── plugins/
│   ├── flutter-skills/          # Flutter/Dart code quality tools
│   │   ├── agents/               # flutter-review agent
│   │   ├── commands/             # Slash commands
│   │   └── skills/               # flutter-review, flutter-format
│   └── plugin-development/       # Plugin authoring tools
│       ├── agents/
│       ├── commands/
│       ├── hooks/
│       ├── scripts/
│       └── skills/
├── docs/                         # Plugin system documentation
└── .claude-plugin/               # Marketplace manifest
    └── marketplace.json
```

## Plugin Architecture

### Plugin Components

Each plugin in this repository follows the standard Claude Code plugin structure:

1. **Agents** (`agents/*.md`) - Specialized AI agents with specific expertise (e.g., flutter-review agent)
2. **Skills** (`skills/*/SKILL.md`) - Domain knowledge and expertise that agents can use
3. **Commands** (`commands/*.md`) - Slash commands that users can invoke
4. **Hooks** (`hooks/hooks.json`) - Event-driven automation triggers
5. **Plugin Manifest** (`.claude-plugin/plugin.json`) - Metadata and configuration

## Testing and Validation

### Testing Plugins Locally

Load a plugin for local testing:

```bash
# Load flutter-skills plugin
claude --plugin-dir ./plugins/flutter-skills

# Load plugin-development plugin
claude --plugin-dir ./plugins/plugin-development
```

### Validating Plugin Structure

Use the plugin-development plugin to validate structure:

```bash
# After loading plugin-development
/plugin-development:validate
```

## Marketplace Management

### Marketplace Manifest

The `.claude-plugin/marketplace.json` file defines the marketplace:

```json
{
  "name": "LucasXu0-flutter-skills",
  "plugins": [
    {
      "name": "flutter-skills",
      "source": "./plugins/flutter-skills",
      "category": "developer-tools",
      "tags": ["flutter", "dart", "code-review"]
    }
  ]
}
```

### Installation Commands

Users can install plugins via:

```bash
# Add marketplace
/plugin marketplace add LucasXu0/claude-code-plugin

# Install specific plugin
/plugin install flutter-skills@LucasXu0-flutter-skills
```

## Important File Patterns

### Avoid Backticks in Markdown (plugins/)

**Never use backticks (`) in markdown templates or programmatically generated output in plugin files.**

Backticks cause shell escaping errors when markdown is passed through bash commands. This applies to:
- Agent files (agents/*.md) - markdown templates for reports
- Command outputs - messages shown to users
- Any dynamic content with placeholders like {branch-name}

**Example of the error you'll get:**
```
Error: Bash command failed for pattern "!`
     - Risk: `": [stderr]
```

**Bad:**
```markdown
**Branch**: `{branch-name}` | Pattern: `YYYYMMDD.md`
```

**Good:**
```markdown
**Branch**: {branch-name} | Pattern: YYYYMMDD.md
```

## Plugin Development Guidelines

### Creating New Agents

Agent markdown files (`agents/*.md`) should include:
- Frontmatter with name, description, skills
- Clear execution strategy
- Tool usage patterns
- Output format specifications

### Creating New Skills

Skill markdown files (`skills/*/SKILL.md`) should include:
- Frontmatter with name, description, trigger conditions
- Domain knowledge and patterns
- Check definitions with examples
- Context-aware guidance

### Creating Commands

Command markdown files (`commands/*.md`) should:
- Include frontmatter with description
- Reference the agent or skill to invoke
- Explain what the command does
- Provide usage examples

## Common Workflows

### Updating flutter-skills Plugin

1. Make changes to plugin files
2. Test locally: `claude --plugin-dir ./plugins/flutter-skills`
3. Update version in `.claude-plugin/plugin.json`
4. Update `CHANGELOG.md`
5. Update marketplace manifest if needed
6. Commit and push to trigger marketplace update

### Adding a New Plugin

1. Create plugin directory under `plugins/`
2. Add `.claude-plugin/plugin.json` manifest
3. Create components (agents, skills, commands)
4. Add entry to `.claude-plugin/marketplace.json`
5. Update root README.md
6. Test locally before publishing

## Documentation

The `docs/` directory contains comprehensive Claude Code plugin system documentation:

- `plugins.md` - Plugin development guide
- `plugins-reference.md` - Technical specifications
- `plugin-marketplaces.md` - Marketplace creation
- `skills.md` - Agent skills guide
- `sub-agents.md` - Subagent system
- `hooks.md` - Hook system reference
- `settings.md` - Configuration guide
- `slash-commands.md` - Command reference
