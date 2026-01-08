---
name: flutter-review
description: Expert knowledge for reviewing Flutter/Dart code including critical bugs, memory leaks, null safety violations, lifecycle issues, Bloc/Provider anti-patterns, collection equality, and code quality patterns. Use when reviewing code, checking PRs, analyzing code quality, or when user mentions bugs, issues, memory leaks, null safety, lifecycle, state management, or code review in Flutter context.
invocable: true
---

# Flutter Code Review

**This skill is directly invocable. See [workflow.md](workflow.md) for the complete 5-step execution strategy.**

Expert knowledge for identifying critical bugs, anti-patterns, and code quality issues in Flutter/Dart code.

## Execution Instructions

When invoked directly (e.g., via /flutter-review command):

1. Follow the 5-step workflow in [workflow.md](workflow.md)
2. Apply the priority-based checks defined below
3. Generate a comprehensive review report
4. Offer to automatically fix issues found

## Priority-Based Analysis

### P0 - Critical (Must Fix Before Merge)

Issues that cause crashes, data loss, or security vulnerabilities.

#### Null Safety Violations

**Force Unwrap Without Checks** (variable!, expression!.property)

- Risk: Runtime crash with "Null check operator used on a null value"
- Fix: Use ?. or ?? operators, explicit null checks, or pattern matching
- → Details: reference.md#avoid_non_null_assertion

**Unsafe Nullable Access**

- Risk: Null pointer exceptions when accessing properties without checks
- Fix: Add null checks before property access
- → Details: reference.md#missing_null_safety

**Unsafe Type Casts** (value as Type)

- Risk: Type cast errors at runtime
- Fix: Use pattern matching or check with is operator first
- → Details: reference.md#unsafe_type_casts

#### Flutter Lifecycle Issues

**setState Without Mounted Check**

- Risk: setState() called after dispose() crashes app
- Fix: Add if (!mounted) return; before setState in async callbacks
- → Details: reference.md#avoid_mounted_in_setstate

**State Modifications After Disposal**

- Risk: Memory leaks and unexpected behavior
- Fix: Check mounted or cancel operations in dispose
- → Details: reference.md#state_after_disposal

#### Memory Leaks

**Resources That Must Be Disposed:**
TextEditingController, AnimationController, ScrollController, TabController, PageController, FocusNode, StreamSubscription, Timer, any class with addListener() called

**Detection:** Check if controllers/subscriptions created in fields or initState have corresponding dispose() calls. Verify ALL resources disposed, not just presence of dispose method.

- → Details: reference.md#dispose_class_fields

#### Logic Errors

**Incorrect Conditional Logic**

- || vs && confusion, missing null checks in compounds, negation errors
- → Details: reference.md#logic_errors_conditionals

**Missing Error Handling**

- API calls, file operations, JSON parsing without try-catch
- → Details: reference.md#missing_error_handling

**Infinite Loops**

- Loops without termination or where condition never changes
- → Details: reference.md#infinite_loops

**Race Conditions**

- Multiple async operations modifying same state without guards
- → Details: reference.md#race_conditions

#### Bloc State Synchronization Issues

**Only check when flutter_bloc or bloc in dependencies.**

**BlocListener/BlocConsumer Missing Initial State**

- Risk: Widget state (TextEditingController, variables) not initialized from bloc's initial state
- Problem: Listener callbacks only fire on state changes, not initial state. If bloc emits state before widget creation, initial state is missed
- Fix: Initialize widget state in initState() from current bloc state, AND have listener for updates
- → Details: reference.md#bloc_missing_initial_state

---

### P1 - Important (Should Fix)

Issues causing logic bugs and maintainability problems.

#### Collection Equality

**Using == on Collections** (list1 == list2, map1 == map2)

- Problem: Dart uses reference equality, always false for different instances
- Fix: Use package:collection - ListEquality().equals(), MapEquality().equals(), or DeepCollectionEquality().equals()
- Exception: const collections (same instance)
- → Details: reference.md#avoid_collection_equality_checks

#### Code Complexity

**Deep Nesting** (>4 levels)

- Problem: Reduces readability, increases cognitive load
- Fix: Extract methods, use early returns, guard clauses
- → Details: reference.md#deep_nesting

**Long Methods** (>100 lines)

- Problem: Violates Single Responsibility Principle
- Fix: Break into smaller focused methods
- → Details: reference.md#long_methods

**Long Build Methods** (>50 lines)

- Problem: Too much UI logic in build method, hard to maintain
- Fix: Extract to buildWidget helpers (buildHeader, buildBody) or create separate widget files
- → Details: reference.md#long_build_methods

#### Widget Organization

**Multiple Widget Definitions Per File**

- Problem: Reduces code organization, testability, and reusability
- Fix: Each widget class must be in its own file (e.g., UserCard in user_card.dart)
- **No exceptions**: Even private (`_Widget`) or small helper widgets should be extracted
- → Details: reference.md#multiple_widgets_per_file

#### Late Modifier Usage

**Avoid Late Keyword**

- Risk: Defers initialization to runtime, can cause LateInitializationError
- Fix: Initialize in constructor, use nullable types, or required parameters
- Exception: DI frameworks with guaranteed initialization
- → Details: reference.md#avoid_late_keyword

#### Bloc Anti-Patterns

**Only check when flutter_bloc or bloc in dependencies.**

**Public Fields in BLoC**

- Problem: Breaks encapsulation, allows external state modification
- Fix: Make fields private, expose through state
- → Details: reference.md#bloc_public_fields

**Public Methods in BLoC**

- Problem: BLoCs should only respond to events
- Fix: Create events and use add() instead
- → Details: reference.md#bloc_public_methods

**Mutable Events**

- Problem: Events should be immutable data
- Fix: Add @immutable, make fields final, use const constructors
- → Details: reference.md#bloc_mutable_events

**Non-Sealed States**

- Problem: Can't exhaustively pattern match
- Fix: Use sealed class for state base, final class for implementations
- → Details: reference.md#bloc_non_sealed_states

#### Provider Anti-Patterns

**Only check when provider in dependencies.**

**context.read() in Build**

- Problem: Won't rebuild when provider changes
- Fix: Use context.watch() for reactive data
- → Details: reference.md#provider_read_in_build

**Old Provider Syntax** (Provider.of<Type>(context, listen: true))

- Problem: Outdated, less readable
- Fix: Use context.watch() or context.read()
- → Details: reference.md#provider_old_syntax

**Missing Disposal in ChangeNotifier**

- Problem: Memory leaks from undisposed resources
- Fix: Override dispose() and clean up all resources
- → Details: reference.md#provider_missing_disposal

#### Logic Issues

**Incorrect Operators**

- Using = instead of == in conditions, comparing incompatible types
- → Details: reference.md#incorrect_operators

**Missing Edge Cases**

- No empty collection checks before .first/.last, no bounds checking
- → Details: reference.md#missing_edge_cases

**Off-By-One Errors**

- Loop conditions with <= instead of < for length
- → Details: reference.md#off_by_one_errors

---

### P2 - Code Quality (Nice to Have)

Improvements for maintainability.

#### Magic Numbers

**Hardcoded Numbers Without Context**

- Exceptions: 0, 1, -1, obvious widget dimensions (padding: 16)
- Fix: Define as named constants
- → Details: reference.md#magic_numbers

#### TODO/FIXME Comments

**Markers for Incomplete Work**

- Patterns: // TODO:, // FIXME:, // HACK:
- Action: Track and address before merge
- → Details: reference.md#todo_comments

#### Long Classes (>500 lines)

**Classes Exceeding 500 Lines**

- Problem: Violates Single Responsibility, may contain dead code
- Fix: Split into multiple classes, extract to mixins/utilities
- Action: Review for unused methods, commented code, duplicate logic
- → Details: reference.md#long_classes

#### Moderate Nesting (3-4 levels)

**Nesting Depth 3-4**

- Consider simplification for readability
- → Details: reference.md#moderate_nesting

---

## Dependency-Specific Knowledge

### Bloc Pattern Detection

**Trigger:** flutter_bloc or bloc in pubspec.yaml

**Key Principles:**

- State is immutable and sealed
- Events are immutable
- No public methods (only event handlers)
- No public fields (only private state)
- UI never contains business logic

→ See reference.md#bloc_pattern for state/event patterns

### Provider Pattern Detection

**Trigger:** provider in pubspec.yaml

**Key Principles:**

- Use context.watch() for reactive rebuilds
- Use context.read() only for one-time reads (not in build)
- Use context.select() for performance optimization
- Always dispose resources in ChangeNotifier

→ See reference.md#provider_pattern for usage patterns

---

## Context Awareness

### When NOT to Flag

**Test Files:**

- More lenient with force unwraps in test setup
- Focus on logic errors, not style

**Generated Code:**

- Files matching _.g.dart, _.freezed.dart, \*.gr.dart
- Skip entirely - will be regenerated

**Intentional Patterns:**

- Null check immediately before force unwrap
- Type check before cast
- Controlled environments after validation

### When TO Flag Even If...

**Pattern is common:**

- Common doesn't mean correct
- Flag reference equality on collections even if widespread

**"It works":**

- Working code can still have bugs
- Flag potential issues even if not currently crashing

**Dispose exists but incomplete:**

- If new controllers added but not in dispose
- Check ALL resources, not just presence of dispose method

**Widget is private or small:**

- Flag ALL widget definitions in same file (except StatefulWidget's State class)
- Private (`_Widget`) does not exempt from one-widget-per-file rule
- "Small" size does not exempt from one-widget-per-file rule
- Every widget class deserves its own file for testability and organization

---

## Review Output Format

### Report Structure

**Summary:**

- Count by priority (P0: X, P1: Y, P2: Z)
- Clear status (Pass / Must Fix / Recommended)
- Overall recommendation (🔴 BLOCK / 🟡 REVIEW NEEDED / 🟢 APPROVED)

**Issue Format:**

- File path:line_number
- Issue type and priority
- Problem explanation
- Current code snippet (with context)
- Fixed code snippet
- Benefit of fix

**Organization:**

- P0 first (most critical)
- Within priority, group by type
- Use tables for many similar issues (>3)
- Detailed format for complex issues

### Recommendation Guidelines

🔴 **BLOCK** - Any P0 issues present (must fix before merge)
🟡 **REVIEW NEEDED** - No P0, but P1 issues present (should fix)
🟢 **APPROVED** - No P0 or P1, only P2 optional improvements

---

## Analysis Efficiency

**Focus on Changed Code:**

- Analyze additions and modifications (+ in diff)
- Use surrounding context from diff
- Don't review entire codebase

**Selective Deep Dives:**
Read full files only when:

- Diff context insufficient
- Need to verify disposal (new controllers/streams added)
- Need class structure or imports

**File Type Guides Analysis:**

- Widgets: Lifecycle, mounted, dispose
- BLoCs: Encapsulation, events, states
- Providers: Disposal, context usage
- Models: Immutability, equality
- Services: Error handling, async patterns

---

## Key Principles

1. **Safety First** - P0 issues can crash apps, prioritize these
2. **Be Specific** - Always provide file:line, code snippets, fixes
3. **Avoid False Positives** - When uncertain, don't flag or mark P2
4. **Context Matters** - Understand intent before flagging
5. **Actionable Feedback** - Every issue needs clear, copy-paste ready fix
6. **Respect Patterns** - Understand project architecture before suggesting changes

---

## Additional Resources

For detailed explanations of each check, see [reference.md](reference.md).

For code examples showing good vs bad patterns, see [examples.md](examples.md).
