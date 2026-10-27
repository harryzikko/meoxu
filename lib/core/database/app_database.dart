import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/user_profile.dart';
import '../../models/transaction_item.dart';
import '../../models/fixed_expense.dart';
import '../../models/cat_state.dart';
import '../../models/streak_state.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('meoxu.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. User Profile Table
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        user_name TEXT,
        cat_name TEXT,
        cat_breed TEXT,
        monthly_income REAL,
        monthly_work_hours REAL,
        saving_percentage REAL,
        currency TEXT,
        reminder_time TEXT,
        show_work_hours INTEGER,
        is_dark_mode INTEGER,
        pin_code TEXT,
        is_onboarded INTEGER
      )
    ''');

    // 2. Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        note TEXT,
        date_time TEXT NOT NULL,
        emotion TEXT,
        is_fixed INTEGER NOT NULL,
        source TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // 3. Fixed Expenses Table
    await db.execute('''
      CREATE TABLE fixed_expenses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        day_of_month INTEGER NOT NULL
      )
    ''');

    // 4. Keyword Rules Table
    await db.execute('''
      CREATE TABLE keyword_rules (
        keyword TEXT PRIMARY KEY,
        category_id TEXT NOT NULL
      )
    ''');

    // 5. Cat State Table
    await db.execute('''
      CREATE TABLE cat_state (
        id INTEGER PRIMARY KEY,
        level INTEGER NOT NULL,
        fish_points INTEGER NOT NULL,
        unlocked_accessories TEXT,
        equipped_accessories TEXT,
        unlocked_furniture TEXT,
        equipped_furniture TEXT,
        current_mood TEXT
      )
    ''');

    // 6. Streak Table
    await db.execute('''
      CREATE TABLE streak_state (
        id INTEGER PRIMARY KEY,
        current_streak INTEGER NOT NULL,
        record_streak INTEGER NOT NULL,
        freeze_cards_left INTEGER NOT NULL,
        last_record_date TEXT
      )
    ''');

    // Insert initial default profile & states
    await db.insert('user_profile', const UserProfile(id: 'default_user').toMap());
    await db.insert('cat_state', {'id': 1, ...const CatState().toMap()});
    await db.insert('streak_state', {'id': 1, ...const StreakState().toMap()});
  }

  // --- Profile Operations ---
  Future<UserProfile> getProfile() async {
    final db = await database;
    final maps = await db.query('user_profile', limit: 1);
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    const defaultProfile = UserProfile(id: 'default_user');
    await db.insert('user_profile', defaultProfile.toMap());
    return defaultProfile;
  }

  Future<void> updateProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Transactions Operations ---
  Future<List<TransactionItem>> getAllTransactions() async {
    final db = await database;
    final results = await db.query('transactions', orderBy: 'date_time DESC');
    return results.map((e) => TransactionItem.fromMap(e)).toList();
  }

  Future<List<TransactionItem>> getRecentTransactions({int limit = 5}) async {
    final db = await database;
    final results = await db.query(
      'transactions',
      orderBy: 'date_time DESC',
      limit: limit,
    );
    return results.map((e) => TransactionItem.fromMap(e)).toList();
  }

  Future<void> insertTransaction(TransactionItem item) async {
    final db = await database;
    await db.insert(
      'transactions',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTransaction(TransactionItem item) async {
    final db = await database;
    await db.update(
      'transactions',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Fixed Expenses Operations ---
  Future<List<FixedExpense>> getFixedExpenses() async {
    final db = await database;
    final results = await db.query('fixed_expenses', orderBy: 'day_of_month ASC');
    return results.map((e) => FixedExpense.fromMap(e)).toList();
  }

  Future<void> insertFixedExpense(FixedExpense item) async {
    final db = await database;
    await db.insert(
      'fixed_expenses',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFixedExpense(String id) async {
    final db = await database;
    await db.delete('fixed_expenses', where: 'id = ?', whereArgs: [id]);
  }

  // --- Cat State & Streak ---
  Future<CatState> getCatState() async {
    final db = await database;
    final maps = await db.query('cat_state', where: 'id = 1');
    if (maps.isNotEmpty) {
      return CatState.fromMap(maps.first);
    }
    return const CatState();
  }

  Future<void> updateCatState(CatState state) async {
    final db = await database;
    await db.update('cat_state', state.toMap(), where: 'id = 1');
  }

  Future<StreakState> getStreakState() async {
    final db = await database;
    final maps = await db.query('streak_state', where: 'id = 1');
    if (maps.isNotEmpty) {
      return StreakState.fromMap(maps.first);
    }
    return const StreakState();
  }

  Future<void> updateStreakState(StreakState state) async {
    final db = await database;
    await db.update('streak_state', state.toMap(), where: 'id = 1');
  }

  // --- Keyword Rules (Machine Learning / Learning parser) ---
  Future<Map<String, String>> getKeywordRules() async {
    final db = await database;
    final results = await db.query('keyword_rules');
    final Map<String, String> rules = {};
    for (final r in results) {
      rules[r['keyword'].toString()] = r['category_id'].toString();
    }
    return rules;
  }

  Future<void> saveKeywordRule(String keyword, String categoryId) async {
    final db = await database;
    await db.insert(
      'keyword_rules',
      {'keyword': keyword.toLowerCase().trim(), 'category_id': categoryId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
