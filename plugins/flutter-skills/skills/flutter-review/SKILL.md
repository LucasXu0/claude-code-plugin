---
name: flutter-review
description: Expert knowledge for reviewing Flutter/Dart code including critical bugs, memory leaks, null safety violations, lifecycle issues, Bloc/Provider anti-patterns, collection equality, and code quality patterns. Use when reviewing code, checking PRs, analyzing code quality, or when user mentions bugs, issues, memory leaks, null safety, lifecycle, state management, or code review in Flutter context.
---

# Flutter Code Review

Expert knowledge for identifying critical bugs, anti-patterns, and code quality issues in Flutter/Dart code.

## Priority-Based Analysis

### P0 - Critical (Must Fix Before Merge)

Issues that cause crashes, data loss, or security vulnerabilities.

#### Null Safety Violations

**Pattern: Force Unwrap Without Checks**
- Code: variable!, expression!.property, function()!
- Risk: Null check operator used on a null value runtime crash
- When acceptable: Immediately after explicit null check
- Fix: Use ?., ??, explicit null checks, or pattern matching

**Pattern: Unsafe Nullable Access**
- Code: Accessing nullable properties without checks
- Risk: Null pointer exceptions
- Fix: Check nullability before access

**Pattern: Unsafe Type Casts**
- Code: value as Type without is check
- Risk: Type cast errors at runtime
- Fix: Use pattern matching or check with is first

#### Flutter Lifecycle Issues

**Pattern: setState Without Mounted Check**
- Code: setState() called in async callbacks without checking mounted
- Risk: setState() called after dispose() errors and crashes
- Detection: Look for async functions calling setState
- Fix: Add if (!mounted) return; before setState in async callbacks

**Pattern: State Modifications After Disposal**
- Code: Updating state variables after widget disposed
- Risk: Memory leaks and unexpected behavior
- Fix: Check mounted or cancel operations in dispose

#### Memory Leaks

**Resources That Must Be Disposed:**
- TextEditingController
- AnimationController
- ScrollController
- TabController
- PageController
- FocusNode
- StreamSubscription
- Timer
- Any class where addListener() was called

**Detection Pattern:**
- Look for controller/subscription creation in class fields or initState
- Verify corresponding dispose() call exists
- Even if dispose exists, check ALL resources are disposed

**Important:** If code adds new controllers/streams, must verify disposal even if dispose method already exists but unchanged.

#### Logic Errors

**Incorrect Conditional Logic:**
- || vs && confusion causing always-true/false conditions
- Missing null checks in compound conditions
- Negation errors

**Missing Error Handling:**
- API calls without try-catch
- File operations without error handling
- JSON parsing without validation
- Network requests without timeout or error cases

**Infinite Loops:**
- While loops without termination condition
- Loops where condition variable never changes
- Recursion without base case

**Race Conditions:**
- Multiple async operations modifying same state
- Concurrent access to shared resources
- Missing state guards for async flows

### P1 - Important (Should Fix)

Issues causing logic bugs and maintainability problems.

#### Collection Equality Issues

**Pattern: Using == on Collections**
- Code: list1 == list2, map1 == map2, set1 == set2
- Problem: Dart uses reference equality, not deep equality
- Result: Always false even with identical contents
- Fix: Use package:collection - ListEquality().equals(), MapEquality().equals(), DeepCollectionEquality().equals()
- Exception: const collections (same instance, comparison works)

#### Code Complexity

**Deep Nesting (>4 levels):**
- Problem: Reduces readability, increases cognitive load
- Fix: Extract nested logic to methods, use early returns, combine conditions with guard clauses

**Long Methods (>100 lines):**
- Problem: Violates Single Responsibility Principle
- Fix: Break into smaller, focused methods with clear names

#### Bloc Anti-Patterns

**Only check when flutter_bloc or bloc in dependencies.**

**Public Fields in BLoC:**
- Pattern: Non-private fields in Bloc classes
- Problem: Breaks encapsulation, allows external state modification
- Fix: Make fields private, expose through state

**Public Methods in BLoC:**
- Pattern: Public methods that modify state
- Problem: BLoCs should only respond to events
- Fix: Create events and use add() instead

**Mutable Events:**
- Pattern: Event classes without @immutable, mutable fields
- Problem: Events should be immutable data
- Fix: Add @immutable, make fields final, use const constructors

**Non-Sealed States:**
- Pattern: State classes not using sealed or final
- Problem: Can't exhaustively pattern match
- Fix: Use sealed class for state base, final class for implementations

#### Provider Anti-Patterns

**Only check when provider in dependencies.**

**context.read() in Build:**
- Pattern: context.read<Provider>() in build method
- Problem: Won't rebuild when provider changes
- Fix: Use context.watch<Provider>() for reactive data

**Old Provider Syntax:**
- Pattern: Provider.of<Type>(context, listen: true)
- Problem: Outdated, less readable
- Fix: Use context.watch<Type>() or context.read<Type>()

**Missing Disposal in ChangeNotifier:**
- Pattern: ChangeNotifier with controllers/subscriptions but no dispose
- Problem: Memory leaks
- Fix: Override dispose() and clean up resources

#### Logic Issues

**Incorrect Operators:**
- Using = instead of == in conditions
- Comparing incompatible types
- Wrong comparison operators

**Missing Edge Cases:**
- No empty collection checks before .first, .last
- No bounds checking for indices
- Missing null/empty string validation

**Off-By-One Errors:**
- Loop conditions with <= instead of < for length
- Index calculations off by one

### P2 - Code Quality (Nice to Have)

Improvements for maintainability.

#### Magic Numbers

**Pattern: Hardcoded Numbers Without Context**
- Example: if (status == 3), Timer(Duration(seconds: 3600))
- Exceptions: 0, 1, -1, and obvious widget dimensions (e.g., padding: 16)
- Fix: Define as named constants with descriptive names

#### TODO/FIXME Comments

**Pattern: Markers for Incomplete Work**
- Comments: // TODO:, // FIXME:, // HACK:
- Significance: Indicates areas needing attention before merge
- Action: Track and address or convert to issues

#### Long Classes (>500 lines)

**Pattern: Classes Exceeding 500 Lines**
- Problem: Violates Single Responsibility
- Fix: Split into multiple classes, extract logic to mixins/utilities

#### Moderate Nesting (3-4 levels)

**Pattern: Nesting Depth of 3-4**
- Not critical but consider simplification for readability
- Suggest refactoring if complexity impacts understanding

## Dependency-Specific Knowledge

### Bloc Pattern Detection

**Trigger:** flutter_bloc or bloc in pubspec.yaml

**Key Principles:**
- State is immutable and sealed
- Events are immutable
- No public methods (only event handlers)
- No public fields (only private state)
- UI never contains business logic

**State Pattern:**
```dart
sealed class UserState {}
final class UserInitial extends UserState {}
final class UserLoading extends UserState {}
final class UserLoaded extends UserState {
  final User user;
  UserLoaded(this.user);
}
```

**Event Pattern:**
```dart
@immutable
sealed class UserEvent {}
final class LoadUser extends UserEvent {
  final String userId;
  const LoadUser(this.userId);
}
```

### Provider Pattern Detection

**Trigger:** provider in pubspec.yaml

**Key Principles:**
- Use context.watch() for reactive rebuilds
- Use context.read() only for one-time reads (not in build)
- Use context.select() for performance (rebuild only on specific changes)
- Always dispose resources in ChangeNotifier

**Good Patterns:**
```dart
// Reactive - rebuilds
final count = context.watch<Counter>().value;

// One-time read - doesn't rebuild
onPressed: () => context.read<Counter>().increment()

// Selective - rebuilds only when name changes
final name = context.select((User user) => user.name);
```

## Context Awareness

### When NOT to Flag

**Test Files:**
- More lenient with some patterns (e.g., force unwraps in test setup)
- Focus on logic errors, not style

**Generated Code:**
- Files matching *.g.dart, *.freezed.dart, *.gr.dart
- Skip entirely - will be regenerated

**Intentional Patterns:**
- Null check immediately before force unwrap
- Type check before cast
- Controlled environments (e.g., after validation)

### When TO Flag Even If...

**Pattern is common:**
- Common doesn't mean correct
- Flag reference equality on collections even if widespread

**"It works":**
- Working code can still have bugs
- Flag potential issues even if not currently crashing

**Dispose exists but incomplete:**
- If new controllers added but not added to dispose
- Check ALL resources, not just presence of dispose method

## Review Output Knowledge

### Report Structure

**Summary Section:**
- Count by priority (P0/P1/P2)
- Clear status (Pass/Must Fix/Recommended)
- Overall recommendation (Block/Review Needed/Approved)

**Issue Format:**
- File path and line number
- Issue type/category
- Problem explanation
- Current code snippet (with context)
- Fixed code snippet
- Benefit of fix (in brief)

**Organization:**
- P0 first (most critical)
- Within priority, group by type
- Use tables for many similar issues (>3)
- Detailed format for complex issues

### Recommendation Guidelines

**🔴 BLOCK:**
- Any P0 issues present
- Must fix before merge

**🟡 REVIEW NEEDED:**
- No P0, but P1 issues present
- Should fix, but not blocking

**🟢 APPROVED:**
- No P0 or P1 issues
- P2 optional improvements only

## Analysis Efficiency

**Focus on Changed Code:**
- Analyze additions and modifications (marked with + in diff)
- Use surrounding context from diff
- Don't review entire codebase

**Selective Deep Dives:**
- Read full files only when:
  - Diff context insufficient
  - Need to verify disposal (new controllers/streams added)
  - Need class structure or imports

**File Type Guides Analysis:**
- **Widgets**: Lifecycle, mounted, dispose
- **BLoCs**: Encapsulation, events, states
- **Providers**: Disposal, context usage
- **Models**: Immutability, equality
- **Services**: Error handling, async patterns

## Key Principles

1. **Safety First**: P0 issues can crash apps - prioritize these
2. **Be Specific**: Always provide file:line, code snippets, fixes
3. **Avoid False Positives**: When uncertain, don't flag or mark P2
4. **Context Matters**: Understand intent before flagging
5. **Actionable Feedback**: Every issue needs clear, copy-paste ready fix
6. **Respect Patterns**: Understand project's architecture before suggesting changes

## Additional Resources

For detailed explanations of each check, see [reference.md](reference.md).

For code examples showing good vs bad patterns, see [examples.md](examples.md).

