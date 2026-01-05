# Flutter Skills - Claude Code Plugin

Comprehensive Flutter/Dart code quality tools for Claude Code, featuring intelligent code review and automated formatting.

## Features

### Agents

| Name | Description |
|------|-------------|
| flutter-review | Analyzes Flutter code changes with priority-based detection (P0 critical bugs, P1 important issues, P2 code quality) and generates review reports with fix suggestions |

### Skills

| Name | Description |
|------|-------------|
| flutter-review | Domain expertise for Flutter/Dart code review including null safety, lifecycle issues, memory leaks, Bloc/Provider patterns, and code complexity checks |
| flutter-format | Automated workflow for running flutter analyze, applying dart fix, formatting code, and verifying no new errors are introduced |

### Commands

| Command | Description |
|---------|-------------|
| /flutter-tools:flutter-review | Triggers comprehensive code review of Flutter changes with prioritized report |
| /flutter-tools:flutter-format | Runs complete formatting and cleanup workflow for Flutter projects |

## Installation

### Method 1: Via Marketplace (Recommended)

```bash
# Add the marketplace from GitHub
/plugin marketplace add LucasXu0/claude-code-plugin

# Install the plugin
/plugin install flutter-tools@LucasXu0-flutter-tools
```

### Method 2: Manual Installation

```bash
# Clone and load directly
git clone https://github.com/LucasXu0/claude-code-plugin.git
cd claude-code-plugin
claude --plugin-dir ./plugins/flutter-tools
```

## Usage

### Flutter Code Review

**Slash command:**
```
/flutter-tools:flutter-review
```

**Natural language:**
```
Review my Flutter code
Check for bugs in my changes
Is this code ready to merge?
```

**Example output:**
```markdown
✅ Review complete! Results saved to:
   /tmp/flutter_review/20260104_1430-my_app-feature_login-a3f9d2.md

## Summary
| Priority | Count | Status |
|----------|-------|--------|
| 🚨 P0 | 2 | ❌ Must Fix |
| ⚠️ P1 | 3 | ⚡ Recommended |
| 💡 P2 | 5 | 💬 Optional |

**Recommendation**: 🟡 REVIEW NEEDED
```

### Flutter Format

**Slash command:**
```
/flutter-tools:flutter-format
```

**Natural language:**
```
Format my Flutter code
Run flutter analyze and fix issues
```

**Example output:**
```markdown
✅ Flutter Format Complete

**Changes Made:**
- Applied dart fix: 12 issues fixed
- Formatted: 45 files changed
- Final analysis: 0 errors, 0 warnings
```

## What Gets Checked

### P0 - Critical
- Null safety violations (force unwraps, unsafe casts)
- Lifecycle issues (setState without mounted checks)
- Memory leaks (undisposed controllers, subscriptions, listeners)
- Logic errors (incorrect conditions, missing error handling)

### P1 - Important
- Collection equality bugs (== on List/Map/Set)
- Bloc anti-patterns (public fields/methods, mutable events)
- Provider anti-patterns (context.read in build, missing disposal)
- Code complexity (deep nesting, long methods/classes)

### P2 - Code Quality
- Magic numbers without constants
- TODO/FIXME comments
- Long classes (>500 lines)

## Resources

- [Claude Code Plugins](https://code.claude.com/docs/en/plugins)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Detailed Examples](skills/flutter-review/examples.md)
- [Check Reference](skills/flutter-review/reference.md)

## Support

- **Issues**: [GitHub Issues](https://github.com/LucasXu0/flutter_skills/issues)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)

## License

MIT License - Created by [Lucas Xu](https://github.com/LucasXu0)
