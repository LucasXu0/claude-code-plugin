---
description: Perform comprehensive Flutter code review with priority-based analysis (P0/P1/P2)
---

# Flutter Code Review Command

Analyze Flutter/Dart code changes for critical bugs, memory leaks, null safety violations, lifecycle issues, Bloc/Provider anti-patterns, and code quality.

Use the **flutter-review agent** to perform an intelligent, thorough code review:

1. Get git diff to understand what changed
2. Detect dependencies (Bloc, Provider) to enable relevant checks
3. Analyze code for P0 (critical), P1 (important), and P2 (quality) issues
4. Save detailed review to `/tmp/flutter_review/`
5. Offer to automatically fix issues found

The agent will provide a prioritized report with:
- **P0 (Critical)**: Crashes, memory leaks, null safety violations → Must fix
- **P1 (Important)**: Logic bugs, anti-patterns, complexity → Should fix
- **P2 (Quality)**: Code quality improvements → Nice to have

Each issue includes file location, problem explanation, current code, and suggested fix.
