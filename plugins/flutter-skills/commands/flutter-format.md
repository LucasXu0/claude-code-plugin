---
description: Run Flutter code formatting and analysis workflow (analyze, fix, format)
---

# Flutter Format Command

Run automated Flutter/Dart code formatting and cleanup workflow.

Apply the **flutter-format skill** to:

1. Run `flutter analyze` to identify issues
2. Apply automated fixes with `dart fix --apply`
3. Format code with `dart format`
4. Re-verify with `flutter analyze`
5. Report all changes made

This ensures:
- All lint issues are addressed
- Code is consistently formatted
- No new errors are introduced
- You're ready to commit clean code

The workflow will ask for confirmation before:
- Applying potentially risky fixes
- Formatting generated or vendor code
- Making changes in monorepos
