# Flutter Review - Code Examples

This document provides concrete code examples for each check, showing both problematic and correct patterns.

## P0 Examples (Critical)

### 1. avoid_non_null_assertion

#### ❌ Bad Examples

```dart
// Example 1: Force unwrap without check
class UserProfile extends StatelessWidget {
  final User? user;

  @override
  Widget build(BuildContext context) {
    return Text(user!.name); // Crash if user is null
  }
}

// Example 2: Chained force unwraps
final email = getUserById(id)!.profile!.email!; // Multiple crash points

// Example 3: Force unwrap in async callback
Future<void> loadData() async {
  final data = await fetchData();
  processData(data!.items); // data might be null
}
```

#### ✅ Good Examples

```dart
// Example 1: Null-aware operator
class UserProfile extends StatelessWidget {
  final User? user;

  @override
  Widget build(BuildContext context) {
    return Text(user?.name ?? 'Guest');
  }
}

// Example 2: Pattern matching
final email = switch (getUserById(id)) {
  User user => user.profile?.email ?? 'No email',
  null => 'No user',
};

// Example 3: Explicit null check before use
Future<void> loadData() async {
  final data = await fetchData();
  if (data == null) return;
  processData(data.items);
}

// Example 4: Acceptable use after type check
Object? value = getValue();
if (value is String) {
  print(value.length); // Safe, type checked
}
```

---

### 2. avoid_mounted_in_setstate

#### ❌ Bad Examples

```dart
// Example 1: setState after async without mounted check
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String _data = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await api.fetchData();
    setState(() {
      _data = data; // Crash if widget disposed during fetch
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_data);
  }
}

// Example 2: Multiple async operations
Future<void> processData() async {
  await step1();
  setState(() => _step1Complete = true); // Might be unmounted

  await step2();
  setState(() => _step2Complete = true); // Might be unmounted
}

// Example 3: Timer callback
void startTimer() {
  Timer(Duration(seconds: 5), () {
    setState(() {
      _timerComplete = true; // Widget might be disposed
    });
  });
}
```

#### ✅ Good Examples

```dart
// Example 1: Check mounted before setState
Future<void> loadData() async {
  final data = await api.fetchData();
  if (!mounted) return;
  setState(() {
    _data = data;
  });
}

// Example 2: Multiple checks in chain
Future<void> processData() async {
  await step1();
  if (!mounted) return;
  setState(() => _step1Complete = true);

  await step2();
  if (!mounted) return;
  setState(() => _step2Complete = true);
}

// Example 3: Cancel timer in dispose
class _MyWidgetState extends State<MyWidget> {
  Timer? _timer;

  void startTimer() {
    _timer = Timer(Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _timerComplete = true;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

---

### 3. dispose_class_fields

#### ❌ Bad Examples

```dart
// Example 1: Controller not disposed
class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: _nameController),
        TextField(controller: _emailController),
      ],
    );
  }
  // Missing dispose!
}

// Example 2: Stream subscription not cancelled
class DataWidget extends StatefulWidget {
  @override
  State<DataWidget> createState() => _DataWidgetState();
}

class _DataWidgetState extends State<DataWidget> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = dataStream.listen((data) {
      setState(() => _data = data);
    });
  }
  // Missing dispose!
}

// Example 3: Multiple resources not cleaned up
class ComplexWidget extends StatefulWidget {
  @override
  State<ComplexWidget> createState() => _ComplexWidgetState();
}

class _ComplexWidgetState extends State<ComplexWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _sub = stream.listen((_) {});
  }
  // Missing dispose for ALL resources!
}
```

#### ✅ Good Examples

```dart
// Example 1: Proper controller disposal
class _MyFormState extends State<MyForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: _nameController),
        TextField(controller: _emailController),
      ],
    );
  }
}

// Example 2: Stream subscription cancelled
class _DataWidgetState extends State<DataWidget> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = dataStream.listen((data) {
      setState(() => _data = data);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Example 3: All resources properly cleaned up
class _ComplexWidgetState extends State<ComplexWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _sub = stream.listen((_) {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _sub?.cancel();
    super.dispose();
  }
}
```

---

### 4. Logic Errors

#### ❌ Bad Examples

```dart
// Example 1: Incorrect boolean logic
void validateUser(User? user) {
  // BAD: OR instead of AND - always true if user != null
  if (user != null || user.isActive) {
    grantAccess();
  }
}

// Example 2: Missing error handling
Future<void> loadUserData(String userId) async {
  final response = await http.get(Uri.parse('$apiUrl/users/$userId'));
  final user = User.fromJson(jsonDecode(response.body)); // Crashes on error
  setState(() => _user = user);
}

// Example 3: Infinite loop
void processQueue() {
  while (queue.isNotEmpty) {
    print(queue.first); // Never removes from queue!
  }
}

// Example 4: Race condition
class DataScreen extends StatefulWidget {
  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  String _data = '';

  @override
  void initState() {
    super.initState();
    loadData();
    loadData(); // Called twice, race condition!
  }

  Future<void> loadData() async {
    final data = await fetchFromApi();
    if (!mounted) return;
    setState(() => _data = data); // Unpredictable which completes last
  }
}

// Example 5: Off-by-one error
void processList(List<int> items) {
  for (int i = 0; i <= items.length; i++) { // Should be <, not <=
    print(items[i]); // Crash on last iteration
  }
}
```

#### ✅ Good Examples

```dart
// Example 1: Correct boolean logic
void validateUser(User? user) {
  if (user != null && user.isActive) { // AND, not OR
    grantAccess();
  }
}

// Example 2: Proper error handling
Future<void> loadUserData(String userId) async {
  try {
    final response = await http.get(Uri.parse('$apiUrl/users/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load user');
    }

    final user = User.fromJson(jsonDecode(response.body));

    if (!mounted) return;
    setState(() => _user = user);
  } catch (e) {
    if (!mounted) return;
    setState(() => _error = e.toString());
  }
}

// Example 3: Proper loop termination
void processQueue() {
  while (queue.isNotEmpty) {
    print(queue.first);
    queue.removeAt(0); // Actually modify the queue
  }
}

// Example 4: Prevent race condition
class _DataScreenState extends State<DataScreen> {
  String _data = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (_isLoading) return; // Prevent concurrent loads

    setState(() => _isLoading = true);
    try {
      final data = await fetchFromApi();
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }
}

// Example 5: Correct loop bounds
void processList(List<int> items) {
  for (int i = 0; i < items.length; i++) { // <, not <=
    print(items[i]);
  }
}
```

---

## P1 Examples (Important)

### 1. avoid_collection_equality_checks

#### ❌ Bad Examples

```dart
// Example 1: List comparison
void checkLists() {
  List<int> a = [1, 2, 3];
  List<int> b = [1, 2, 3];

  if (a == b) { // Always false! Different instances
    print('Equal');
  } else {
    print('Not equal'); // Always prints this
  }
}

// Example 2: Map comparison
void checkMaps() {
  Map<String, int> map1 = {'a': 1, 'b': 2};
  Map<String, int> map2 = {'a': 1, 'b': 2};

  if (map1 == map2) { // False - reference equality
    print('Equal');
  }
}

// Example 3: In conditional logic
class TodoList extends StatelessWidget {
  final List<String> currentTodos;
  final List<String> previousTodos;

  Widget build(BuildContext context) {
    // BAD: This will always rebuild
    if (currentTodos != previousTodos) {
      return Text('Todos changed');
    }
    return Text('No change');
  }
}
```

#### ✅ Good Examples

```dart
import 'package:collection/collection.dart';

// Example 1: Use DeepCollectionEquality
void checkLists() {
  List<int> a = [1, 2, 3];
  List<int> b = [1, 2, 3];

  if (DeepCollectionEquality().equals(a, b)) {
    print('Equal'); // Correctly prints this
  }
}

// Example 2: Use ListEquality for lists
void checkLists() {
  List<int> a = [1, 2, 3];
  List<int> b = [1, 2, 3];

  if (ListEquality().equals(a, b)) {
    print('Equal');
  }
}

// Example 3: Use MapEquality for maps
void checkMaps() {
  Map<String, int> map1 = {'a': 1, 'b': 2};
  Map<String, int> map2 = {'a': 1, 'b': 2};

  if (MapEquality().equals(map1, map2)) {
    print('Equal');
  }
}

// Example 4: Manual comparison for simple cases
void checkSimpleList() {
  List<int> a = [1, 2, 3];
  List<int> b = [1, 2, 3];

  bool areEqual = a.length == b.length &&
                  List.generate(a.length, (i) => a[i] == b[i]).every((e) => e);
}

// Example 5: Const collections (reference equality works)
const list1 = [1, 2, 3];
const list2 = [1, 2, 3];
if (list1 == list2) { // This works! Same const instance
  print('Equal');
}
```

---

### 2. Code Complexity

#### ❌ Bad Examples

```dart
// Example 1: Deep nesting (5 levels)
void processOrder(Order order) {
  if (order.isValid) {
    if (order.items.isNotEmpty) {
      for (var item in order.items) {
        if (item.inStock) {
          if (item.price > 0) {
            // Do something - 5 levels deep!
            addToCart(item);
          }
        }
      }
    }
  }
}

// Example 2: Complex nested conditions
Widget buildUserProfile(User? user) {
  if (user != null) {
    if (user.isActive) {
      if (user.subscription != null) {
        if (user.subscription!.isValid) {
          if (user.subscription!.expiryDate.isAfter(DateTime.now())) {
            return PremiumProfile(user);
          } else {
            return ExpiredProfile(user);
          }
        }
      }
    }
  }
  return GuestProfile();
}
```

#### ✅ Good Examples

```dart
// Example 1: Early returns reduce nesting
void processOrder(Order order) {
  if (!order.isValid) return;
  if (order.items.isEmpty) return;

  for (var item in order.items) {
    if (!item.inStock) continue;
    if (item.price <= 0) continue;

    addToCart(item);
  }
}

// Example 2: Extract to methods
Widget buildUserProfile(User? user) {
  if (user == null) return GuestProfile();
  if (!user.isActive) return InactiveProfile(user);

  return _buildSubscriptionProfile(user);
}

Widget _buildSubscriptionProfile(User user) {
  final subscription = user.subscription;
  if (subscription == null) return BasicProfile(user);
  if (!subscription.isValid) return InvalidSubscriptionProfile(user);
  if (subscription.expiryDate.isBefore(DateTime.now())) {
    return ExpiredProfile(user);
  }

  return PremiumProfile(user);
}

// Example 3: Combine conditions
Widget buildUserProfile(User? user) {
  if (user == null || !user.isActive) {
    return GuestProfile();
  }

  final subscription = user.subscription;
  final isValidSubscription = subscription != null &&
                               subscription.isValid &&
                               subscription.expiryDate.isAfter(DateTime.now());

  return isValidSubscription ? PremiumProfile(user) : BasicProfile(user);
}
```

---

### 3. Long Build Methods

#### ❌ Bad Examples

```dart
// Example 1: 60-line build method with complex UI
class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section (15 lines)
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.avatar),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: TextStyle(fontSize: 24)),
                        Text(user.email, style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            // Stats section (15 lines)
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('${user.posts}', style: TextStyle(fontSize: 20)),
                      Text('Posts'),
                    ],
                  ),
                  Column(
                    children: [
                      Text('${user.followers}', style: TextStyle(fontSize: 20)),
                      Text('Followers'),
                    ],
                  ),
                  Column(
                    children: [
                      Text('${user.following}', style: TextStyle(fontSize: 20)),
                      Text('Following'),
                    ],
                  ),
                ],
              ),
            ),
            // Bio section (10 lines)
            Container(
              padding: EdgeInsets.all(16),
              child: Text(user.bio),
            ),
            // Posts grid (20+ lines)
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: user.posts.length,
              itemBuilder: (context, index) {
                return Image.network(
                  user.posts[index].imageUrl,
                  fit: BoxFit.cover,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

#### ✅ Good Examples

```dart
// Example 1: Extract to private build methods
class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Divider(),
            _buildStats(),
            _buildBio(),
            _buildPostsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(user.avatar),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: TextStyle(fontSize: 24)),
                Text(user.email, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('${user.posts}', 'Posts'),
          _buildStatColumn('${user.followers}', 'Followers'),
          _buildStatColumn('${user.following}', 'Following'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20)),
        Text(label),
      ],
    );
  }

  Widget _buildBio() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(user.bio),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: user.posts.length,
      itemBuilder: (context, index) {
        return Image.network(
          user.posts[index].imageUrl,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

// Example 2: Extract to separate widget files
class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [SettingsButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserProfileHeader(user),       // Separate file
            Divider(),
            UserStatsSection(user),        // Separate file
            UserBioSection(user),          // Separate file
            UserPostsGrid(user.posts),     // Separate file
          ],
        ),
      ),
    );
  }
}
```

---

### 4. Multiple Widgets Per File

#### ❌ Bad Examples

```dart
// user_profile.dart - BAD: Multiple widgets in one file
class UserProfile extends StatelessWidget {
  final User user;

  const UserProfile(this.user);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserCard(user),        // Should be in user_card.dart
        UserAvatar(user),      // Should be in user_avatar.dart
        UserBio(user),         // Should be in user_bio.dart
      ],
    );
  }
}

// BAD: Public widget in same file
class UserCard extends StatelessWidget {
  final User user;

  const UserCard(this.user);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
      ),
    );
  }
}

// BAD: Another public widget
class UserAvatar extends StatelessWidget {
  final User user;

  const UserAvatar(this.user);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: NetworkImage(user.avatar),
    );
  }
}

// BAD: Yet another public widget
class UserBio extends StatelessWidget {
  final User user;

  const UserBio(this.user);

  @override
  Widget build(BuildContext context) {
    return Text(user.bio);
  }
}
```

#### ✅ Good Examples

```dart
// user_profile.dart - GOOD: One main widget per file
class UserProfile extends StatelessWidget {
  final User user;

  const UserProfile(this.user);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserCard(user),        // Imported from user_card.dart
        UserAvatar(user),      // Imported from user_avatar.dart
        UserBio(user),         // Imported from user_bio.dart
      ],
    );
  }
}

// GOOD: Private helper widget in same file
class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader(this.user);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.person),
        Text(user.name),
      ],
    );
  }
}

// user_card.dart - GOOD: Separate file for UserCard
class UserCard extends StatelessWidget {
  final User user;

  const UserCard(this.user);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
      ),
    );
  }
}

// user_avatar.dart - GOOD: Separate file for UserAvatar
class UserAvatar extends StatelessWidget {
  final User user;

  const UserAvatar(this.user);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: NetworkImage(user.avatar),
    );
  }
}

// user_bio.dart - GOOD: Separate file for UserBio
class UserBio extends StatelessWidget {
  final User user;

  const UserBio(this.user);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(user.bio),
    );
  }
}
```

---

### 5. Avoid Late Keyword

#### ❌ Bad Examples

```dart
// Example 1: Late without initialization
class UserProfileScreen extends StatefulWidget {
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late String userName;              // BAD: No initialization
  late int userAge;                  // BAD: Crash if accessed before init
  late TextEditingController controller;  // BAD: Memory leak risk

  @override
  void initState() {
    super.initState();
    // Forgot to initialize userName and userAge!
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Text(userName);  // LateInitializationError!
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// Example 2: Late in class fields
class UserService {
  late final ApiClient apiClient;   // BAD: Runtime check
  late Database db;                  // BAD: Might forget to initialize

  void initialize() {
    apiClient = ApiClient();
    // Forgot to initialize db!
  }

  Future<User> getUser() async {
    return apiClient.get('/user');
    // If we use db here before initialize(), crash!
  }
}

// Example 3: Complex late initialization
class ConfigManager {
  late Map<String, dynamic> config;  // BAD: Complex init logic

  Future<void> loadConfig() async {
    try {
      config = await loadFromFile();
    } catch (e) {
      // If loading fails, config never initialized!
    }
  }

  String getConfigValue(String key) {
    return config[key];  // Crash if loadConfig failed
  }
}
```

#### ✅ Good Examples

```dart
// Example 1: Constructor initialization
class _UserProfileScreenState extends State<UserProfileScreen> {
  String userName = '';              // GOOD: Default value
  int userAge = 0;                   // GOOD: Default value
  final TextEditingController controller = TextEditingController();  // GOOD: Immediate init

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await fetchUser();
    setState(() {
      userName = user.name;
      userAge = user.age;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(userName);  // Safe, always initialized
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// Example 2: Nullable with null checks
class _UserProfileScreenState extends State<UserProfileScreen> {
  String? userName;                  // GOOD: Nullable
  int? userAge;                      // GOOD: Nullable
  TextEditingController? controller; // GOOD: Nullable

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Text(userName ?? 'Loading...');  // GOOD: Null check
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

// Example 3: Required parameters
class UserService {
  final ApiClient apiClient;         // GOOD: Required in constructor
  final Database db;                 // GOOD: Required in constructor

  UserService({
    required this.apiClient,
    required this.db,
  });

  Future<User> getUser() async {
    return apiClient.get('/user');   // Safe, always initialized
  }
}

// Example 4: Acceptable late use with DI
class UserRepository {
  late final Database db;  // OK: GetIt guarantees initialization

  @injectable
  UserRepository() {
    db = GetIt.instance<Database>();  // Framework guarantees this runs first
  }

  Future<User> getUser(String id) async {
    return db.query('users', where: 'id = ?', args: [id]);
  }
}

// Example 5: Lazy initialization with nullable
class ConfigManager {
  Map<String, dynamic>? _config;     // GOOD: Nullable

  Future<void> loadConfig() async {
    try {
      _config = await loadFromFile();
    } catch (e) {
      _config = {};  // Fallback to empty map
    }
  }

  String? getConfigValue(String key) {
    return _config?[key];  // GOOD: Safe access
  }

  bool get isLoaded => _config != null;
}
```

---

### 6. Bloc Anti-patterns

#### ❌ Bad Examples

```dart
// Example 1: Public fields
class UserBloc extends Bloc<UserEvent, UserState> {
  String userName = ''; // BAD: Public mutable field
  int loginCount = 0;   // BAD: Public mutable field

  UserBloc() : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
  }
}

// Example 2: Public methods
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial());

  // BAD: Public method - should use event
  void updateUserName(String name) {
    emit(UserLoaded(name));
  }
}

// Example 3: Mutable event
class UpdateUserEvent extends UserEvent {
  String name; // BAD: Mutable field

  UpdateUserEvent(this.name);
}

// Example 4: Non-sealed state
class UserState { // BAD: Not sealed or final
  final String name;
  UserState(this.name);
}

class UserInitial extends UserState {
  UserInitial() : super('');
}
```

#### ✅ Good Examples

```dart
// Example 1: Private fields, state-driven
class UserBloc extends Bloc<UserEvent, UserState> {
  String _userName = ''; // Private
  int _loginCount = 0;   // Private

  UserBloc() : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    _userName = event.userName;
    _loginCount++;
    emit(UserLoaded(_userName, _loginCount));
  }
}

// Example 2: Event-driven (no public methods)
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<UpdateUserName>(_onUpdateUserName);
  }

  void _onUpdateUserName(UpdateUserName event, Emitter<UserState> emit) {
    emit(UserLoaded(event.name));
  }
}

// Usage:
bloc.add(UpdateUserName('John')); // Use event, not method

// Example 3: Immutable event
@immutable
class UpdateUserEvent extends UserEvent {
  final String name; // Immutable

  const UpdateUserEvent(this.name);
}

// Example 4: Sealed state
sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserLoaded extends UserState {
  final String name;
  final int loginCount;

  UserLoaded(this.name, this.loginCount);
}

final class UserError extends UserState {
  final String message;

  UserError(this.message);
}
```

---

### 4. Provider Anti-patterns

#### ❌ Bad Examples

```dart
// Example 1: context.read() in build
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // BAD: Won't rebuild when counter changes
    final counter = context.read<CounterProvider>().count;

    return Text('Count: $counter');
  }
}

// Example 2: Old syntax
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // BAD: Old syntax
    final counter = Provider.of<CounterProvider>(context, listen: true);

    return Text('Count: ${counter.count}');
  }
}

// Example 3: Missing disposal in ChangeNotifier
class UserProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final StreamSubscription _subscription;

  UserProvider() {
    _subscription = stream.listen((data) {
      notifyListeners();
    });
  }

  // Missing dispose!
}
```

#### ✅ Good Examples

```dart
// Example 1: context.watch() in build
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // GOOD: Rebuilds when counter changes
    final counter = context.watch<CounterProvider>().count;

    return Text('Count: $counter');
  }
}

// Example 2: context.read() for actions only
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = context.watch<CounterProvider>().count;

    return Column(
      children: [
        Text('Count: $counter'),
        ElevatedButton(
          onPressed: () {
            // GOOD: read() for one-time action
            context.read<CounterProvider>().increment();
          },
          child: Text('Increment'),
        ),
      ],
    );
  }
}

// Example 3: Proper disposal in ChangeNotifier
class UserProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  late final StreamSubscription _subscription;

  UserProvider() {
    _subscription = stream.listen((data) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    _subscription.cancel();
    super.dispose();
  }
}

// Example 4: Select for performance
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // GOOD: Only rebuilds when name changes, not entire user
    final userName = context.select<UserProvider, String>(
      (provider) => provider.user.name
    );

    return Text('Hello, $userName');
  }
}
```

---

## P2 Examples (Code Quality)

### 1. Magic Numbers

#### ❌ Bad Examples

```dart
// Example 1: Status codes
void handleResponse(int statusCode) {
  if (statusCode == 200) { // What is 200?
    handleSuccess();
  } else if (statusCode == 404) { // What is 404?
    handleNotFound();
  } else if (statusCode == 500) { // What is 500?
    handleError();
  }
}

// Example 2: Timeouts
Future<void> loadData() async {
  await Future.delayed(Duration(seconds: 30)); // Why 30?
  // ...
}

// Example 3: Business logic
double calculateDiscount(double price) {
  if (price > 100) {
    return price * 0.15; // What is 15%?
  } else if (price > 50) {
    return price * 0.10; // What is 10%?
  }
  return 0;
}
```

#### ✅ Good Examples

```dart
// Example 1: Named constants
class HttpStatus {
  static const int ok = 200;
  static const int notFound = 404;
  static const int serverError = 500;
}

void handleResponse(int statusCode) {
  if (statusCode == HttpStatus.ok) {
    handleSuccess();
  } else if (statusCode == HttpStatus.notFound) {
    handleNotFound();
  } else if (statusCode == HttpStatus.serverError) {
    handleError();
  }
}

// Example 2: Named durations
const dataLoadTimeout = Duration(seconds: 30);

Future<void> loadData() async {
  await Future.delayed(dataLoadTimeout);
  // ...
}

// Example 3: Named business constants
class DiscountRates {
  static const double premiumThreshold = 100.0;
  static const double standardThreshold = 50.0;
  static const double premiumRate = 0.15;
  static const double standardRate = 0.10;
}

double calculateDiscount(double price) {
  if (price > DiscountRates.premiumThreshold) {
    return price * DiscountRates.premiumRate;
  } else if (price > DiscountRates.standardThreshold) {
    return price * DiscountRates.standardRate;
  }
  return 0;
}

// Example 4: Acceptable magic numbers (common widget values)
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(16), // OK: Common padding
    child: SizedBox(
      height: 48, // OK: Standard button height
      child: ElevatedButton(...),
    ),
  );
}
```

---

### 2. Long Methods/Classes

#### ❌ Bad Example

```dart
// Example: 150+ line method
class OrderService {
  Future<void> processOrder(Order order) async {
    // Validate order (20 lines)
    if (order.items.isEmpty) throw Exception('Empty order');
    if (order.customer == null) throw Exception('No customer');
    // ... 15 more validation lines

    // Calculate totals (25 lines)
    double subtotal = 0;
    for (var item in order.items) {
      subtotal += item.price * item.quantity;
    }
    // ... 20 more calculation lines

    // Apply discounts (30 lines)
    double discount = 0;
    if (order.customer.isPremium) {
      discount = subtotal * 0.15;
    }
    // ... 25 more discount lines

    // Process payment (40 lines)
    final paymentResult = await paymentGateway.charge(
      amount: subtotal - discount,
      customer: order.customer,
    );
    // ... 35 more payment lines

    // Update inventory (35 lines)
    for (var item in order.items) {
      await inventory.reduceStock(item.id, item.quantity);
    }
    // ... 30 more inventory lines

    // Send notifications (20 lines)
    await emailService.sendOrderConfirmation(order);
    // ... 15 more notification lines
  }
}
```

#### ✅ Good Example

```dart
// Extract into focused methods
class OrderService {
  Future<void> processOrder(Order order) async {
    _validateOrder(order);

    final totals = _calculateTotals(order);
    final discount = _calculateDiscount(order, totals.subtotal);
    final finalAmount = totals.subtotal - discount;

    await _processPayment(order, finalAmount);
    await _updateInventory(order);
    await _sendNotifications(order);
  }

  void _validateOrder(Order order) {
    if (order.items.isEmpty) throw Exception('Empty order');
    if (order.customer == null) throw Exception('No customer');
    // ... validation logic
  }

  OrderTotals _calculateTotals(Order order) {
    double subtotal = 0;
    for (var item in order.items) {
      subtotal += item.price * item.quantity;
    }
    return OrderTotals(subtotal: subtotal);
  }

  double _calculateDiscount(Order order, double subtotal) {
    if (order.customer.isPremium) {
      return subtotal * 0.15;
    }
    return 0;
  }

  Future<void> _processPayment(Order order, double amount) async {
    final result = await paymentGateway.charge(
      amount: amount,
      customer: order.customer,
    );
    // ... payment logic
  }

  Future<void> _updateInventory(Order order) async {
    for (var item in order.items) {
      await inventory.reduceStock(item.id, item.quantity);
    }
  }

  Future<void> _sendNotifications(Order order) async {
    await emailService.sendOrderConfirmation(order);
    // ... notification logic
  }
}

class OrderTotals {
  final double subtotal;
  OrderTotals({required this.subtotal});
}
```

---

## Summary

These examples demonstrate the patterns to look for during code review. Focus on:
- **Safety first**: P0 issues can crash the app
- **Correctness**: P1 issues cause bugs or violate patterns
- **Quality**: P2 issues improve maintainability

Always provide context-specific suggestions with code examples when flagging issues.
