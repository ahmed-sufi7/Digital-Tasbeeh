import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'digital_tasbeeh.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tasbeehs table
    await db.execute('''
      CREATE TABLE tasbeehs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        target_count INTEGER,
        current_count INTEGER DEFAULT 0,
        round_number INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        last_used_at TEXT NOT NULL,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // Create count_history table
    await db.execute('''
      CREATE TABLE count_history (
        id TEXT PRIMARY KEY,
        tasbeeh_id TEXT NOT NULL,
        count INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        round_number INTEGER DEFAULT 1,
        FOREIGN KEY (tasbeeh_id) REFERENCES tasbeehs (id) ON DELETE CASCADE
      )
    ''');

    // Create notification_schedules table
    await db.execute('''
      CREATE TABLE notification_schedules (
        id TEXT PRIMARY KEY,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        weekdays TEXT NOT NULL,
        is_enabled INTEGER DEFAULT 1,
        message TEXT DEFAULT 'Time for dhikr! 🤲'
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_count_history_tasbeeh_id ON count_history(tasbeeh_id)',
    );
    await db.execute(
      'CREATE INDEX idx_count_history_timestamp ON count_history(timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_tasbeehs_last_used ON tasbeehs(last_used_at)',
    );
    await db.execute(
      'CREATE INDEX idx_tasbeehs_is_default ON tasbeehs(is_default)',
    );

    // Insert default Tasbeehs
    await _insertDefaultTasbeehs(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Example migration for version 2
      // await db.execute('ALTER TABLE tasbeehs ADD COLUMN new_column TEXT');
    }
  }

  Future<void> _insertDefaultTasbeehs(Database db) async {
    final now = DateTime.now().toIso8601String();

    final defaultTasbeehs = [
      {
        'id': 'default_sallallahu_alayhi_wasallam',
        'name': 'Sallallahu Alayhi Wasallam',
        'target_count': 100, // Changed from null to 100 to show progress
        'current_count': 0,
        'round_number': 1,
        'created_at': now,
        'last_used_at': now,
        'is_default': 1,
      },
      {
        'id': 'default_subhanallah',
        'name': 'SubhanAllah',
        'target_count': 33,
        'current_count': 0,
        'round_number': 1,
        'created_at': now,
        'last_used_at': now,
        'is_default': 0,
      },
      {
        'id': 'default_allahu_akbar',
        'name': 'Allahu Akbar',
        'target_count': 33,
        'current_count': 0,
        'round_number': 1,
        'created_at': now,
        'last_used_at': now,
        'is_default': 0,
      },
      {
        'id': 'default_alhamdulillah',
        'name': 'Alhamdulillah',
        'target_count': 33,
        'current_count': 0,
        'round_number': 1,
        'created_at': now,
        'last_used_at': now,
        'is_default': 0,
      },
      {
        'id': 'default_la_ilaha_illa_allah',
        'name': 'La ilaha illa Allah',
        'target_count': 100,
        'current_count': 0,
        'round_number': 1,
        'created_at': now,
        'last_used_at': now,
        'is_default': 0,
      },
    ];

    for (final tasbeeh in defaultTasbeehs) {
      await db.insert('tasbeehs', tasbeeh);
    }
  }

  // Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Reset database (for testing or factory reset)
  Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'digital_tasbeeh.db');

    await close();
    await deleteDatabase(path);
    _database = await _initDatabase();
  }

  // Get database path (for debugging)
  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, 'digital_tasbeeh.db');
  }

  // Check if database exists
  Future<bool> databaseExists() async {
    final path = await getDatabasePath();
    return await databaseFactory.databaseExists(path);
  }
}
