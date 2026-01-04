---
name: flutter-format
description: Knowledge about Flutter/Dart code formatting, analysis tools (flutter analyze, dart fix, dart format), and when to apply them. Use when formatting code, fixing lint issues, running code cleanup, or when user mentions format, analyze, lint, or cleanup in Flutter context.
---

# Flutter Format

Expert knowledge about Flutter/Dart code formatting and analysis tools.

## Core Tools

### flutter analyze
**Purpose**: Static analysis to find errors, warnings, and lint suggestions

**What it checks:**
- Syntax errors
- Type errors
- Unused imports and variables
- Lint rules from analysis_options.yaml
- Potential bugs and anti-patterns

**When to use:**
- Before applying fixes (to identify issues)
- After formatting (to verify no new issues)
- As pre-commit validation

**Output interpretation:**
- **Errors**: Must fix (compilation failures)
- **Warnings**: Should fix (potential bugs)
- **Info**: Optional improvements (style suggestions)

### dart fix --apply
**Purpose**: Automatically fix lint issues and apply Dart language updates

**What it fixes:**
- Deprecated API usage
- Lint violations with automated fixes
- Code modernization (e.g., null safety migration patterns)

**When to use:**
- After flutter analyze identifies fixable issues
- Before formatting (fixes may affect structure)
- When migrating Dart versions

**Safety considerations:**
- **Safe**: Lint fixes, deprecated API updates
- **Review needed**: Major refactorings, null safety changes
- **Skip if**: Syntax errors present, uncommitted important changes

**Always show changes to user** with git diff before proceeding.

### dart format
**Purpose**: Consistent code formatting following Dart style guide

**What it formats:**
- Indentation (2 spaces)
- Line length (default 80 characters)
- Bracket placement
- Whitespace and newlines

**What it doesn't change:**
- Code logic
- Import order (use IDE or separate tool)
- Comments content

**When to use:**
- After code changes
- After dart fix --apply
- Before commits

**Options:**
- . - Format entire project
- lib test - Format specific directories
- --line-length=120 - Custom line length (if needed)

## Best Practices

### Recommended Workflow

**Standard sequence:**
```
flutter analyze → dart fix --apply → dart format → flutter analyze
```

**Why this order:**
1. **Analyze first**: Identify issues
2. **Fix**: Auto-fix what's possible
3. **Format**: Apply consistent style
4. **Re-analyze**: Verify no new issues

### Edge Cases

**Generated Code**
- Files: *.g.dart, *.freezed.dart, *.gr.dart
- Action: Exclude from formatting
- Reason: Regenerated on build, formatting changes lost
- How: Use dart format lib test instead of dart format .

**Vendor/Third-Party Code**
- Directories: packages/, vendor/, .pub-cache/
- Action: Don't format
- Reason: Not your code, may break signatures
- How: Target specific directories

**Monorepos**
- Context: Multiple projects in one repository
- Action: Format only relevant project
- Reason: May affect other teams' code
- How: cd project_name && dart format lib test

**Build Runner Integration**
- When: Project uses build_runner for code generation
- Action: Run build after fixing/formatting if generated files changed
- Command: flutter pub run build_runner build --delete-conflicting-outputs

**Syntax Errors**
- Issue: dart format fails on unparseable code
- Action: Fix syntax errors first, then format
- Detection: flutter analyze shows errors

### Analysis Options

**Custom Lint Rules** (analysis_options.yaml)
- Location: Project root
- Purpose: Project-specific lint rules
- Respect user's choices - don't suggest disabling their rules
- Add exceptions only if user requests

**Example:**
```yaml
linter:
  rules:
    prefer_const_constructors: true
    avoid_print: true
```

### Output Reporting

**What to show user:**
- Number of issues fixed by dart fix
- Number of files formatted
- Final analysis status (errors/warnings count)
- List of modified files (or summary if >10)

**Helpful next steps:**
- How to review changes: git diff
- How to commit: git add . && git commit -m "chore: format code"

## Error Handling

### Common Failures

**flutter analyze fails:**
- **Cause**: Not in Flutter project, SDK not installed, corrupt dependencies
- **Solution**: Run flutter pub get to refresh dependencies

**dart fix --apply fails:**
- **Cause**: Syntax errors, conflicting fixes
- **Solution**: Fix syntax errors first, or skip and proceed with format only

**dart format fails:**
- **Cause**: Syntax errors (rare)
- **Solution**: Identify problematic file, fix syntax, or skip that file

**Permission errors:**
- **Cause**: File permissions, read-only files
- **Solution**: Check file permissions, may need user intervention

## Integration Patterns

### With Version Control

**Pre-commit:**
- Format staged files: git diff --name-only --cached '*.dart' | xargs dart format
- Verify: dart format --set-exit-if-changed . (fails if formatting needed)

**In CI/CD:**
- Check formatting: dart format --set-exit-if-changed .
- Run analysis: flutter analyze --no-fatal-warnings

### With IDEs

**Note**: This skill complements IDE formatting by:
- Ensuring all files formatted (IDE may only format open files)
- Running full analysis workflow
- Providing team-wide consistency

## Decision Guidelines

**When user says "format my code":**
- Run full workflow (analyze → fix → format → verify)
- Default to formatting entire project
- Exclude generated files automatically

**When user says "just format, don't fix":**
- Skip dart fix --apply
- Run only dart format
- Still verify with flutter analyze after

**When in doubt:**
- Ask user before applying risky fixes
- Show changes before proceeding
- Respect project's analysis_options.yaml

## Quick Reference

```bash
# Full workflow
flutter analyze && dart fix --apply && dart format . && flutter analyze

# Format only (skip fixes)
dart format .

# Format specific directories
dart format lib test

# Exclude generated files
dart format lib --exclude '**.g.dart'

# Check formatting (CI/CD)
dart format --set-exit-if-changed .

# Custom line length
dart format --line-length=120 .
```

## Key Principles

1. **Analyze before and after** - Catch issues early and verify fixes
2. **Show changes** - User should review before committing
3. **Respect configuration** - Use project's analysis_options.yaml
4. **Handle edge cases** - Generated code, vendor code, monorepos
5. **Report clearly** - Summarize what changed and next steps

