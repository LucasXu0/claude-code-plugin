# Flutter Review - Detailed Reference

This document provides in-depth explanations of all checks performed by the Flutter Review skill.

## P0 Checks (Critical)

### 1. avoid_non_null_assertion

**What it detects**: Usage of the force unwrap operator (exclamation mark) without proper null checks.

**Why it's critical**: Can cause runtime crashes with "Null check operator used on a null value" error.

**Pattern to detect**:
- variable with exclamation mark
- expression with exclamation mark followed by property access
- function call with exclamation mark

**When it's acceptable**:
- Immediately after an explicit null check: `if (x != null) { x!.method(); }`
- After type check: `if (x is String) { x.length; }`

**Suggested fixes**:
1. Use null-aware operator: `variable?.property`
2. Use null coalescing: `variable ?? defaultValue`
3. Add explicit null check before usage
4. Use pattern matching: `if (variable case final value?) { ... }`

---

### 2. avoid_mounted_in_setstate

**What it detects**: Calling `setState()` in async callbacks without checking if the widget is still mounted.

**Why it's critical**: Causes `setState() called after dispose()` errors and crashes.

**Pattern to detect**:
```dart
// BAD
Future<void> loadData() async {
  final data = await api.fetchData();
  setState(() {
    _data = data;
  });
}
```

**Suggested fix**:
```dart
// GOOD
Future<void> loadData() async {
  final data = await api.fetchData();
  if (!mounted) return;
  setState(() {
    _data = data;
  });
}
```

---

### 3. dispose_class_fields

**What it detects**: Controllers, streams, subscriptions, and other resources not properly disposed.

**Why it's critical**: Memory leaks that degrade app performance over time.

**Resources to check**:
- `TextEditingController`
- `AnimationController`
- `ScrollController`
- `TabController`
- `PageController`
- `FocusNode`
- `StreamSubscription`
- `Timer`
- Any class with `addListener()` called

**Pattern to detect**:
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController(); // Created
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = stream.listen(...);
  }

  // MISSING: dispose method or incomplete disposal
}
```

**Suggested fix**:
```dart
@override
void dispose() {
  _controller.dispose();
  _subscription?.cancel();
  super.dispose();
}
```

---

### 4. Missing Null Safety

**What it detects**: Accessing properties or methods on potentially null objects without checks.

**Why it's critical**: Null pointer exceptions crash the app.

**Patterns to detect**:
- Nullable variable accessed without check: `String? name; print(name.length);`
- Nullable return value used directly: `findUser().name`
- Map access without null check: `map['key'].toString()`

**Logic errors causing null issues**:
- Missing initialization
- Incorrect conditional logic
- Async timing issues

---

### 5. Logic Errors (Critical)

**What it detects**: Code logic that will cause crashes or incorrect behavior.

**Examples**:

**Incorrect conditionals**:
```dart
// BAD: Always true
if (value != null || value.isEmpty) { ... }

// Should be:
if (value != null && value.isEmpty) { ... }
```

**Missing error handling**:
```dart
// BAD: No error handling
final response = await http.get(url);
final data = jsonDecode(response.body);

// GOOD: Handle errors
try {
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
  } else {
    // Handle error
  }
} catch (e) {
  // Handle exception
}
```

**Infinite loops**:
```dart
// BAD: No termination condition
while (true) {
  processItem();
}

// BAD: Condition never changes
int i = 0;
while (i < 10) {
  print(i); // i never increments
}
```

**Race conditions**:
```dart
// BAD: Multiple async operations modifying same state
void loadData() async {
  setState(() => _loading = true);
  final data1 = await fetchData1();
  setState(() => _data = data1);
  final data2 = await fetchData2();
  setState(() => _data = data2); // Overwrites data1
}
```

---

## P1 Checks (Important)

### 1. avoid_collection_equality_checks

**What it detects**: Using equality operators (== or !=) to compare Lists, Maps, or Sets.

**Why it's important**: In Dart, `==` on collections checks reference equality, not content equality.

**Pattern to detect**:
```dart
List<int> a = [1, 2, 3];
List<int> b = [1, 2, 3];
if (a == b) { ... } // Always false! Different instances
```

**Suggested fixes**:
1. Use `package:collection`: `ListEquality().equals(a, b)`
2. Use `DeepCollectionEquality().equals(a, b)`
3. Compare individual elements if simple
4. For const collections, comparison works (same instance)

---

### 2. Code Complexity (Nesting >4)

**What it detects**: Deeply nested control structures (if/for/while/switch).

**Why it's important**: Reduces readability, increases cognitive load, harder to test.

**Pattern to detect**:
```dart
if (condition1) {
  if (condition2) {
    for (var item in list) {
      if (item.isValid) {
        while (processing) {
          // 5 levels deep - too complex
        }
      }
    }
  }
}
```

**Suggested fixes**:
1. Extract nested logic into separate methods
2. Use early returns to reduce nesting
3. Combine conditions where possible
4. Use guard clauses

**Example refactor**:
```dart
// BEFORE: Nested
if (user != null) {
  if (user.isActive) {
    if (user.hasPermission) {
      doSomething();
    }
  }
}

// AFTER: Early returns
if (user == null) return;
if (!user.isActive) return;
if (!user.hasPermission) return;
doSomething();
```

---

### 3. Long Methods (>100 lines)

**What it detects**: Methods exceeding 100 lines of code.

**Why it's important**: Violates Single Responsibility Principle, hard to understand and test.

**Suggested fix**: Break into smaller, focused methods with clear names.

---

### 4. Bloc Anti-patterns

**Only checked if `flutter_bloc` or `bloc` is in pubspec.yaml**

#### 4.1 Public Fields in BLoC

**Pattern to detect**:
```dart
class UserBloc extends Bloc<UserEvent, UserState> {
  String userName; // BAD: Public field
}
```

**Why**: Breaks encapsulation, allows external state modification.

**Fix**: Use private fields and expose through state.

#### 4.2 Public Methods in BLoC

**Pattern to detect**:
```dart
class UserBloc extends Bloc<UserEvent, UserState> {
  void updateUser(User user) { ... } // BAD: Public method
}
```

**Why**: BLoCs should only respond to events.

**Fix**: Create an event and use `add()`.

#### 4.3 Mutable Events

**Pattern to detect**:
```dart
class UpdateUserEvent extends UserEvent {
  String name; // BAD: Mutable
}
```

**Fix**:
```dart
@immutable
class UpdateUserEvent extends UserEvent {
  final String name;
  const UpdateUserEvent(this.name);
}
```

#### 4.4 Non-sealed States

**Pattern to detect**:
```dart
class UserState { ... } // BAD: Not sealed/final
```

**Fix**:
```dart
sealed class UserState {}
final class UserInitial extends UserState {}
final class UserLoaded extends UserState {}
```

---

### 5. Provider Anti-patterns

**Only checked if `provider` is in pubspec.yaml**

#### 5.1 context.read() in build

**Pattern to detect**:
```dart
@override
Widget build(BuildContext context) {
  final value = context.read<MyProvider>().value; // BAD
  return Text(value);
}
```

**Why**: Won't rebuild when provider changes.

**Fix**: Use `context.watch<MyProvider>()`

#### 5.2 Not Using Provider Extensions

**Pattern to detect**:
```dart
Provider.of<MyProvider>(context, listen: true) // OLD
```

**Fix**:
```dart
context.watch<MyProvider>() // NEW
context.read<MyProvider>()  // For non-rebuild access
```

#### 5.3 Missing Disposal in ChangeNotifier

**Pattern to detect**:
```dart
class MyProvider extends ChangeNotifier {
  final controller = TextEditingController();
  // Missing dispose
}
```

**Fix**:
```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

---

### 6. Logic Issues (Important)

**Incorrect comparison operators**:
```dart
// BAD: Using = instead of ==
if (status = 'active') { ... }

// BAD: Comparing incompatible types
if (intValue == 'string') { ... }
```

**Missing edge case handling**:
```dart
// BAD: No empty check
final first = list.first;

// GOOD
if (list.isEmpty) return;
final first = list.first;
```

**Off-by-one errors**:
```dart
// BAD: Index out of bounds
for (int i = 0; i <= list.length; i++) { ... }

// GOOD
for (int i = 0; i < list.length; i++) { ... }
```

---

## P2 Checks (Code Quality)

### 1. Magic Numbers

**What it detects**: Hardcoded numbers without context (except 0, 1, -1).

**Pattern to detect**:
```dart
if (status == 3) { ... } // What is 3?
Timer(Duration(seconds: 3600), ...); // What is 3600?
```

**Exceptions**:
- Widget dimensions/padding when obvious: `SizedBox(height: 16)`
- Common values: 0, 1, -1, 2 (for doubling)

**Suggested fix**:
```dart
const int statusActive = 3;
const int secondsInHour = 3600;
```

---

### 2. TODO/FIXME Comments

**What it detects**: Comments indicating incomplete work.

**Pattern to detect**:
- `// TODO: ...`
- `// FIXME: ...`
- `// HACK: ...`

**Why track**: Indicates areas needing attention before merge.

---

### 3. Long Classes (>500 lines)

**What it detects**: Classes exceeding 500 lines.

**Why it matters**: Violates Single Responsibility, hard to maintain.

**Suggested fix**: Split into multiple classes or mixins.

---

### 4. Moderate Nesting (3-4 levels)

**What it detects**: Nesting depth of 3-4 levels.

**Why note**: Not critical but consider simplification for readability.

---

## Detection Methodology

### How to Identify Issues

1. **Read the full file** to understand context
2. **Focus on git diff** - only check changed/added lines
3. **Understand the file type**:
   - Widget files: Check lifecycle, mounted, dispose
   - BLoC files: Check encapsulation, events, states
   - Provider files: Check disposal, context usage
   - Model files: Check immutability, equality
   - Service files: Check error handling, async patterns

4. **Look for patterns** using regex and code analysis:
   - Search for force unwrap operators
   - Search for `setState` and check mounted
   - Search for controller declarations and verify dispose
   - Count nesting levels
   - Count line numbers

5. **Verify with context** - don't flag false positives:
   - Is this in a test file? (more lenient)
   - Is this generated code? (skip)
   - Is there a good reason? (e.g., null check above)

---

## Priority Assignment Logic

**Assign P0 if**:
- Can cause app crash
- Can cause data loss
- Can cause security vulnerability
- Memory leak

**Assign P1 if**:
- Can cause logic bug
- Violates architectural pattern
- Significantly impacts readability
- Makes code hard to maintain

**Assign P2 if**:
- Code quality improvement
- Readability enhancement
- Best practice suggestion
- No immediate functional impact
